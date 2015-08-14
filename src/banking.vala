/*  This file is part of gbank, a Gtk+ Online Banking Software using HBCI
 *  Copyright (C) 2015 Florian Richter
 *
 *  gbank is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  gbank is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with gbank.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * This module handles interactions with hbci4java-glib,
 * especially of loading into a seperate thread
 */

/**
 * generic job interface to be executed in a seperate thread
 */
interface Job : Object {
    /** user to be used for callbacks */
    public abstract User? get_user();
    /** execute job */
    public abstract void run(Banking banking, GHbci.Context ghbci_context);
}

/**
 * callbacks requiring UI interaction
 */
public interface IBankingUI : Object {
    public abstract string get_password(User user);
    public abstract string get_tan(string hint);
    public abstract string get_flicker_tan(string hint, string flicker_code);
    public abstract void wrong_password(User user);
}

/**
 * job verifying that user account exists and fetch list of bank accounts
 */
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
        ghbci_context.add_passport(user.bank_code, user.user_id);
        var account_list = ghbci_context.get_accounts(user.bank_code, user.user_id);
        foreach (var account in account_list) {
            Account db_account = new Account();
            db_account.id = -1;
            db_account.account_type = account.account_type;
            db_account.account_number = account.number;
            db_account.bank_code = account.blz;
            db_account.owner_name = account.owner_name;
            db_account.bic = account.bic;
            db_account.iban = account.iban;
            db_account.balance = "0";
            db_account.currency = account.currency;
            accounts.add( db_account );
        }

        // Schedule callback
        Idle.add((owned) callback);
    }

    public User? get_user() {
        return this.user;
    }
}

/**
 * job retrieving supported tan methods
 */
class GetTanMethodsJob : Object, Job {
    private User user;
    private HashTable<string, string>? tan_methods = null;
    private SourceFunc callback;

    public GetTanMethodsJob(User user, owned SourceFunc callback) {
        this.user = user;
        this.callback = (owned) callback;
    }

    public void run(Banking banking, GHbci.Context ghbci_context) {
        ghbci_context.add_passport(user.bank_code, user.user_id);
        tan_methods = ghbci_context.get_tan_methods(user.bank_code, user.user_id);

        // Schedule callback
        Idle.add((owned) callback);
    }

    public User? get_user() {
        return this.user;
    }

    public HashTable<string, string>? get_result() {
        return tan_methods;
    }
}

/**
 * job to fetch all statements of a bank account
 */
class GetStatementsJob : Object, Job {
    private User user;
    private Account account;
    private unowned Gee.LinkedList<GHbci.Statement> statements;
    private SourceFunc callback;

    public GetStatementsJob(User user, Account account, ref Gee.LinkedList<GHbci.Statement> statements, owned SourceFunc callback) {
        this.user = user;
        this.account = account;
        this.statements = statements;
        this.callback = (owned) callback;
    }

    public void run(Banking banking, GHbci.Context ghbci_context) {
        ghbci_context.add_passport(user.bank_code, user.user_id);

        var statements_list = ghbci_context.get_statements(user.bank_code, user.user_id, account.account_number);
        foreach(GHbci.Statement statement in statements_list)
            statements.add (statement);

        // Schedule callback
        Idle.add( (owned) callback );
    }

    public User? get_user() {
        return this.user;
    }
}

/**
 * job to fetch the balance of a bank account
 */
class GetBalanceJob : Object, Job {
    private User user;
    private Account account;
    private unowned StringBuilder balance;
    private SourceFunc callback;

    public GetBalanceJob(User user, Account account, ref StringBuilder balance, owned SourceFunc callback) {
        this.user = user;
        this.account = account;
        this.balance = balance;
        this.callback = (owned) callback;
    }

    public void run(Banking banking, GHbci.Context ghbci_context) {
        ghbci_context.add_passport(user.bank_code, user.user_id);

        balance.assign(ghbci_context.get_balances(user.bank_code, user.user_id, account.account_number));

        // Schedule callback
        Idle.add( (owned) callback );
    }

    public User? get_user() {
        return this.user;
    }
}

/**
 * job to send a transfer
 */
class SendTransferJob : Object, Job {
    private User user;
    private Account account;
    private Value result;
    private SourceFunc callback;
    private string destination_name;
    private string destination_bic;
    private string destination_iban;
    private string reference;
    private string amount;

    public SendTransferJob(User user, Account account, ref Value result, owned SourceFunc callback,
            string destination_name, string destination_bic, string destination_iban,
            string reference, string amount) {
        this.user = user;
        this.account = account;
        this.result = result;
        this.callback = (owned) callback;

        this.destination_name = destination_name;
        this.destination_bic = destination_bic;
        this.destination_iban = destination_iban;
        this.reference = reference;
        this.amount = amount;
    }

    public void run(Banking banking, GHbci.Context ghbci_context) {
        ghbci_context.add_passport(user.bank_code, user.user_id);

        var success = ghbci_context.send_transfer(user.bank_code, user.user_id, account.account_number,
            account.owner_name, account.bic, account.iban,
            destination_name, destination_bic, destination_iban, reference, amount);

        result.set_boolean(success);

        // Schedule callback
        Idle.add( (owned) callback );
    }

    public User? get_user() {
        return this.user;
    }
}

/**
 * job to assemble the complete list of banks and bank codes
 *
 * no network connection required
 */
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

    public User? get_user() {
        return null;
    }
}

/**
 * job: resolve bank name for bank code
 *
 * no network connection required
 */
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

    public User? get_user() {
        return null;
    }
}

/**
 * job: get url for online banking of the bank with the specified bank code
 *
 * no network connection required
 */
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

    public User? get_user() {
        return null;
    }
}

/**
 * sentinel to stop job processing for shutdown
 */
class StopJob : Object, Job {

    public StopJob() {
    }

    public void run( Banking banking, GHbci.Context ghbci_context ) {
    }

    public User? get_user() {
        return null;
    }
}

/**
 * Capsules a hbci4java-glib context
 *
 * Provides async and sync methods for online banking and handles callbacks.
 * All hbci4java-glib calls are dispatched to a seperate thread
 */
public class Banking {
    private Thread<bool> thread;
    private BankJobWindow bank_job_window;
    private IBankingUI banking_ui;
    private GHbci.Context ghbci_context;
    private User? current_user;
    private AsyncQueue<Job> jobs = new AsyncQueue<Job> ();

    public signal void log(string message, int64 level);
    public signal void status_message(string message);


    public Banking(IBankingUI banking_ui, BankJobWindow bank_job_window) {
        this.banking_ui = banking_ui;
        this.bank_job_window = bank_job_window;
        current_user = null;
        jobs = new AsyncQueue<Job>();
        thread = new Thread<bool>("banking", run);
    }

    public void stop() {
        jobs.push(new StopJob());
        thread.join();
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
        stdout.printf("reason: %Iu, '%s'\n", reason, message);
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
                string password = null;
                var result = new AsyncQueue<int>();
                MainContext.default().invoke( () => {
                    password = banking_ui.get_password(current_user);
                    result.push(1);
                    return Source.REMOVE;
                });
                result.pop();
                return password;
            case GHbci.Reason.NEED_PT_SECMECH:
                stdout.printf("sec mech: %s\n", optional);
                return current_user.sec_mech;
            case GHbci.Reason.NEED_PT_TAN:
                stdout.printf("optional: '%s'\n", optional);
                var hint = new StringBuilder();
                foreach(var word in message.split_set("\n \t")) {
                    if (word.length > 0) {
                        hint.append(word);
                        hint.append(" ");
                    }
                }
                string hint_str = hint.str.replace("<br>", "\n");
                string password = null;
                var result = new AsyncQueue<int>();
                MainContext.default().invoke( () => {
                    if (optional != "") {
                        password = banking_ui.get_flicker_tan(hint_str, optional);
                    } else {
                        password = banking_ui.get_tan(hint_str);
                    }
                    result.push(1);
                    return Source.REMOVE;
                });
                result.pop();
                return password;
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

    private bool run() {
        ghbci_context = new GHbci.Context(Environment.get_tmp_dir());

        ghbci_context.callback.connect( on_ghbci_callback );
        ghbci_context.log.connect( on_ghbci_log );
        ghbci_context.status.connect( on_ghbci_status );

        while(true) {
            Job job = jobs.pop ();
            if (job is StopJob) {
                break;
            }
            this.current_user = job.get_user();
            job.run(this, ghbci_context);
            this.current_user = null;
        }
        ghbci_context = null;
        return true;
    }

    public async bool check_user( User user, out Gee.ArrayList<Account> accounts) {
        Gee.ArrayList<Account> local_accounts = new Gee.ArrayList<Account>();

        jobs.push(new CheckUserJob(user, ref local_accounts, this.check_user.callback));

        yield;
        accounts = (owned) local_accounts;
        return true;
    }

    public async HashTable<string, string> get_tan_methods( User user ) {
        var job = new GetTanMethodsJob(user, this.get_tan_methods.callback);
        jobs.push(job);

        yield;
        return job.get_result();
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
        var statements = new Gee.LinkedList<GHbci.Statement>();

        jobs.push( new GetStatementsJob( user, account, ref statements, fetch_transactions.callback ) );

        yield;

        foreach (GHbci.Statement statement in statements) {
            Transaction db_transaction = new Transaction();
            db_transaction.id = -1;
            db_transaction.account_id = account.id;
            db_transaction.transaction_type = statement.transaction_type;
            db_transaction.date = statement.booking_date;
            db_transaction.valuta_date = statement.valuta;
            db_transaction.amount = double.parse(statement.value);
            db_transaction.currency = "EUR";
            db_transaction.other_name = statement.other_name;
            db_transaction.other_iban = statement.other_iban;
            db_transaction.other_bic = statement.other_bic;
            db_transaction.reference = statement.reference;
            db.insert_transaction(db_transaction);
        }
    }

    public async void get_balance(User user, Account account, GBankDatabase db) throws Error {
        var balance = new StringBuilder();
        jobs.push( new GetBalanceJob( user, account, ref balance, get_balance.callback ) );

        yield;
        account.balance = balance.str;
        db.save_account(account);
    }

    public async void send_transfer(User user, Account account, GBankDatabase db,
            string destination_name, string destination_bic, string destination_iban,
            string reference, string amount) throws Error {
        Value result = Value(typeof(bool));
        jobs.push( new SendTransferJob( user, account, ref result, send_transfer.callback,
                destination_name, destination_bic, destination_iban, reference, amount) );

        yield;
    }
}