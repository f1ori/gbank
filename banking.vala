
interface Job : Object {
    public abstract void run(Banking banking, GHbci.Context ghbci_context);
}

class CheckUserJob : Object, Job {
    private User user;
    private unowned Gee.ArrayList<Account> accounts;
    private SourceFunc callback;

    public CheckUserJob(User user, ref Gee.ArrayList<Account> accounts, owned SourceFunc callback) {
        this.user = user;
        this.accounts = accounts;
        this.callback = (owned) callback;
    }

    public void run(Banking banking, GHbci.Context ghbci_context) {
        banking.current_user = user;
        ghbci_context.add_passport(user.bank_code, user.user_id);
        var account_list = ghbci_context.get_accounts(user.bank_code, user.user_id);
        foreach (var account in account_list) {
            Account db_account = new Account();
            db_account.id = -1;
            db_account.account_type = "bank";
            db_account.account_number = account.number;
            db_account.bank_code = account.blz;
            db_account.owner_name = account.name;
            db_account.balance = "0";
            db_account.currency = account.currency;
            accounts.add( db_account );
        }
        banking.current_user = null;

        // Schedule callback
        Idle.add((owned) callback);
    }
}

class GetStatementsJob : Object, Job {
    private User user;
    private Account account;
    private AsyncQueue<Gee.LinkedList<GHbci.Statement>> result_queue;
    private SourceFunc callback;

    public GetStatementsJob(User user, Account account, AsyncQueue<Gee.LinkedList<GHbci.Statement>> result_queue, owned SourceFunc callback) {
        this.user = user;
        this.account = account;
        this.result_queue = result_queue;
        this.callback = (owned) callback;
    }

    public void run(Banking banking, GHbci.Context ghbci_context) {
        banking.current_user = user;
        ghbci_context.add_passport(user.bank_code, user.user_id);

        var statements = ghbci_context.get_statements(user.bank_code, user.user_id, account.account_number);
        Gee.LinkedList<GHbci.Statement> statements_list = new Gee.LinkedList<GHbci.Statement> ();
        foreach(GHbci.Statement statement in statements)
            statements_list.add (statement);

        banking.current_user = null;

        result_queue.push( (owned) statements_list );

        // Schedule callback
        Idle.add( (owned) callback );
    }
}

class ListBanksJob : Object, Job {
    private unowned AsyncQueue<List<string>> result_queue;

    public ListBanksJob( AsyncQueue<List<string>> result_queue ) {
        this.result_queue = result_queue;
    }

    public void run( Banking banking, GHbci.Context ghbci_context ) {

        List<string> banks = new List<string>();

        ghbci_context.blz_foreach( (blz) => {banks.append(blz);} );

        result_queue.push( (owned) banks );
    }
}

class GetBankNameJob : Object, Job {
    private unowned AsyncQueue<string> result_queue;
    private string blz;

    public GetBankNameJob( string blz, AsyncQueue<string> result_queue ) {
        this.blz = blz;
        this.result_queue = result_queue;
    }

    public void run( Banking banking, GHbci.Context ghbci_context ) {
        result_queue.push( ghbci_context.get_name_for_blz( blz ) );
    }
}

class GetPinTanUrlJob : Object, Job {
    private unowned AsyncQueue<string> result_queue;
    private string blz;

    public GetPinTanUrlJob( string blz, AsyncQueue<string> result_queue ) {
        this.blz = blz;
        this.result_queue = result_queue;
    }

    public void run( Banking banking, GHbci.Context ghbci_context ) {
        result_queue.push( ghbci_context.get_pin_tan_url_for_blz( blz ) );
    }
}

public class Banking {
    public Thread<bool> thread;
    private BankJobWindow bank_job_window;
    GHbci.Context ghbci_context;
    public User? current_user;
    AsyncQueue<Job> jobs = new AsyncQueue<Job> ();
    public signal void log(string message, int64 level);
    public signal void status_message(string message);


    public Banking(BankJobWindow bank_job_window) {
        this.bank_job_window = bank_job_window;
        current_user = null;
        jobs = new AsyncQueue<Job>();
        thread = new Thread<bool>("banking", run);
    }

    void on_ghbci_log (string message, int64 level) {
        MainContext.default().invoke( () => {
            bank_job_window.add_log_line(message);
            stdout.printf("log: %s\n", message);
            return Source.REMOVE;
        });
        return;
    }

    string on_ghbci_callback (int64 reason, string message, string optional) {
        if (current_user == null) {
            warning("No user defined to answer: %s", message);
            return "";
        }
        debug("reason: %Iu, %s\n", reason, message);
        switch(reason) {
            case GHbci.Reason.NEED_COUNTRY:
                return "DE";
            case GHbci.Reason.NEED_BLZ:
                return current_user.bank_code;
            case GHbci.Reason.NEED_USERID:
                return current_user.user_id;
            case GHbci.Reason.NEED_CUSTOMERID:
                return current_user.customer_id;
            case GHbci.Reason.NEED_HOST:
                return current_user.host;
            case GHbci.Reason.NEED_PORT:
                return current_user.port;
            case GHbci.Reason.NEED_FILTER:
                return "Base64";
            // TODO: encrypt everything with a master password
            case GHbci.Reason.NEED_PASSPHRASE_LOAD:
                return "42";
            case GHbci.Reason.NEED_PASSPHRASE_SAVE:
                return "42";
            case GHbci.Reason.NEED_PT_PIN:
                return get_password();
            case GHbci.Reason.NEED_PT_SECMECH:
                stdout.printf("sec mech: %s\n", optional);
                return "962";
        }
        return "";
    }

    void on_ghbci_status (int64 tag, string message) {
        MainContext.default().invoke( () => {
            string description = "";
            switch (tag) {
                case GHbci.StatusTag.SEND_TASK:          description = "Send Task"; break;
                case GHbci.StatusTag.SEND_TASK_DONE:     description = "Send Task Done"; break;
                case GHbci.StatusTag.INST_BPD_INIT:      description = "Inst bpd init"; break;
                case GHbci.StatusTag.INST_BPD_INIT_DONE: description = "Inst bpd init done"; break;  
                case GHbci.StatusTag.INST_GET_KEYS:      description = "Get Keys"; break;
                case GHbci.StatusTag.INST_GET_KEYS_DONE: description = "Get Keys done"; break;
                case GHbci.StatusTag.SEND_KEYS:          description = "Send Keys"; break;
                case GHbci.StatusTag.SEND_KEYS_DONE:     description = "Send Keys done"; break;
                case GHbci.StatusTag.INIT_SYSID:         description = "Init Sysid"; break;
                case GHbci.StatusTag.INIT_SYSID_DONE:    description = "Init Sysid Done"; break;
                case GHbci.StatusTag.INIT_UPD:           description = "Init UPD"; break;
                case GHbci.StatusTag.INIT_UPD_DONE:      description = "Init UPD done"; break;
                case GHbci.StatusTag.LOCK_KEYS:          description = "Lock keys"; break;
                case GHbci.StatusTag.LOCK_KEYS_DONE:     description = "Lock Keys done"; break;
                case GHbci.StatusTag.INIT_SIGID:         description = "Init sigid"; break;
                case GHbci.StatusTag.INIT_SIGID_DONE:    description = "init sigid done"; break;
                case GHbci.StatusTag.DIALOG_INIT:        description = "dialog init"; break;
                case GHbci.StatusTag.DIALOG_INIT_DONE:   description = "dialog init done"; break;
                case GHbci.StatusTag.DIALOG_END:         description = "dialog end"; break;
                case GHbci.StatusTag.DIALOG_END_DONE:    description = "dialog end done"; break;
            }
            if (description != "") {
                status_message(description);
                bank_job_window.add_status_line(description);
                stdout.printf("status: %s\n", description);
            }
            return Source.REMOVE;
        });
        return;
    }


    public string get_password() {
        // TODO: move gui stuff out of this module
        AsyncQueue<string?> result = new AsyncQueue<string?>();
        MainContext.default().invoke( () => {
            string password = null;
            PasswordDialog dialog = new PasswordDialog(bank_job_window);
            switch (dialog.run()) {
                case Gtk.ResponseType.OK:
                    password = dialog.password_entry.text;
                    dialog.destroy();
                    break;
                case Gtk.ResponseType.CANCEL:
                    dialog.destroy();
                    break;
            }
            result.push(password);
            return Source.REMOVE;
        });

        return result.pop();
    }

    private bool run() {
        ghbci_context = new GHbci.Context();

        ghbci_context.callback.connect( on_ghbci_callback );
        ghbci_context.log.connect( on_ghbci_log );
        ghbci_context.status.connect( on_ghbci_status );

        while(true) {
            Job job = jobs.pop ();
            job.run(this, ghbci_context);
        }
    }

    public async bool check_user( User user, out Gee.ArrayList<Account> accounts) {
        Gee.ArrayList<Account> local_accounts = new Gee.ArrayList<Account>();

        jobs.push(new CheckUserJob(user, ref local_accounts, this.check_user.callback));

        yield;
        accounts = (owned) local_accounts;
        return true;
    }

    public List<string> get_bank_list() {
        AsyncQueue<List<string>> result_queue = new AsyncQueue<List<string>>();

        jobs.push( new ListBanksJob( result_queue ) );

        return result_queue.pop();
    }

    public string get_pin_tan_url_for_blz(string blz) {
        AsyncQueue<string> result_queue = new AsyncQueue<string>();

        jobs.push( new GetPinTanUrlJob( blz, result_queue ) );

        return result_queue.pop();
    }

    public string get_name_for_blz(string blz) {
        AsyncQueue<string> result_queue = new AsyncQueue<string>();

        jobs.push( new GetBankNameJob( blz, result_queue ) );

        return result_queue.pop();
    }

    public async void fetch_transactions(User user, Account account, GBankDatabase db) throws Error {
        var result_queue = new AsyncQueue<Gee.LinkedList<GHbci.Statement>>();

        jobs.push( new GetStatementsJob( user, account, result_queue, fetch_transactions.callback ) );

        yield;
        Gee.LinkedList<GHbci.Statement> statements = result_queue.pop();

        foreach (GHbci.Statement statement in statements) {
            Transaction db_transaction = new Transaction();
            db_transaction.id = -1;
            db_transaction.account_id = account.id;
            db_transaction.transaction_type = "";
            db_transaction.date = statement.booking_date;
            db_transaction.valuta_date = statement.valuta;
            db_transaction.amount = double.parse(statement.value);
            db_transaction.currency = "EUR";
            db_transaction.other_name = statement.other_name;
            db_transaction.other_account_number = statement.other_iban;
            db_transaction.purpose = statement.reference;
            db.insert_transaction(db_transaction);
        }
    }
}