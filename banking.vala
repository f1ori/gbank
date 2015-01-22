

public class Banking : Object {
    public AqBanking.Banking banking;
    private static unowned BankJobWindow bank_job_window;
    private static uint64 progress_total = 1;
    private static HashTable<string, string> password_cache;
    private HashTable<int, weak AqBanking.User> user_cache;
    private HashTable<int, weak AqBanking.Account> account_cache;

    public static int check_cert (Gwenhywfar.Gui gui, Gwenhywfar.SSLCertDescription cert, Gwenhywfar.SyncIO sio, int32 guiid) {
        return 0;
    }

    public static int get_password (Gwenhywfar.Gui gui, int flags, string token, string title, string text, string buffer, int min_len, int max_len, int32 guiid) {
        unowned string password = password_cache.lookup(token);
        if (password != null) {
            Posix.strcpy(buffer, password);
            return 0;
        }
        PasswordDialog dialog = new PasswordDialog(bank_job_window);
        dialog.password_entry.max_length = max_len;
        switch (dialog.run()) {
            case Gtk.ResponseType.OK:
                password_cache.insert(token, dialog.password_entry.text);
                Posix.strcpy(buffer, dialog.password_entry.text);
                dialog.destroy();
                stdout.printf(token);
                stdout.printf(" password provided!!\n");
                return 0;
            case Gtk.ResponseType.CANCEL:
                dialog.destroy();
                return 1;
        }
        return 1;
    }

    public static int set_password_status (Gwenhywfar.Gui gui, string token, string pin, Gwenhywfar.Gui.PasswordStatus status, int32 guiid) {
        stdout.printf("%d status!\n", status);
        return 0;
    }

    public static int progress_log(Gwenhywfar.Gui gui, int id, Gwenhywfar.LoggerLevel level, string text) {
        bank_job_window.add_log_line( text );
        MainContext.default().iteration( false );
        return 0;
    }

    public static int progress_start(Gwenhywfar.Gui gui, int progressFlags, string title, string text, uint64 total, uint32 guiid) {
        progress_total = total;
        MainContext.default().iteration( false );
        return 0;
    }

    public static int progress_advance (Gwenhywfar.Gui gui, uint32 id, uint64 progress) {
        //stdout.printf( "%" + uint64.FORMAT + " / %" +  uint64.FORMAT + " \n", progress, progress_total );
        bank_job_window.set_fraction( 1.0 * progress / progress_total );
        MainContext.default().iteration( false );
        return 0;
    }

    public static int progress_set_total (Gwenhywfar.Gui gui, uint32 id, uint64 total) {
        progress_total = total;
        MainContext.default().iteration( false );
        return 0;
    }

    public Banking (BankJobWindow bank_job_window) {
        user_cache = new HashTable<int, AqBanking.User>.full(direct_hash, direct_equal, null, null);
        account_cache = new HashTable<int, AqBanking.Account>.full(direct_hash, direct_equal, null, null);

        Gwenhywfar.init();
        Banking.bank_job_window = bank_job_window;
        banking = new AqBanking.Banking("gbank", "/tmp/gbank-aqbanking", 0);

        Gwenhywfar.Gui gui = Gwenhywfar.Gui.new_cgui();
        gui.add_flags( Gwenhywfar.Gui.GuiFlags.NONINTERACTIVE );
        Gwenhywfar.Gui.setGui ( gui );
        gui.set_get_password_function( get_password );
        gui.set_set_password_status_function( set_password_status );
        gui.set_check_cert_function( check_cert );
        gui.set_progress_log_function( progress_log );
        gui.set_progress_start_function( progress_start );
        gui.set_progress_advance_function( progress_advance );
        gui.set_progress_set_total_function( progress_set_total );

        Gwenhywfar.Logger_set_level("aqhbci", Gwenhywfar.LoggerLevel.Debug);
        Gwenhywfar.Logger_set_level("aqbanking", Gwenhywfar.LoggerLevel.Debug);
        Gwenhywfar.Logger_set_level("gwenhywfar", Gwenhywfar.LoggerLevel.Debug);
        banking.init ();
        banking.online_init ();
        password_cache = new HashTable<string, string> (str_hash, str_equal);
    }

    public Transaction to_db_transaction(Account account, AqBanking.Transaction aq_transaction) {
        string remote_name = "";
        unowned Gwenhywfar.StringListEntry remote_name_entry = aq_transaction.remote_name.first_entry();
        while (remote_name_entry != null) {
            remote_name = "%s\n%s".printf(remote_name, remote_name_entry.data);
            remote_name_entry = remote_name_entry.next();
        }
        remote_name._strip();

        string purpose_text = "";
        unowned Gwenhywfar.StringListEntry purpose = aq_transaction.purpose.first_entry();
        while (purpose != null) {
            purpose_text = "%s\n%s".printf(purpose_text, purpose.data);
            purpose = purpose.next();
        }
        purpose_text._strip();

        Transaction db_transaction = new Transaction();
        db_transaction.id = -1;
        db_transaction.account_id = account.id;
        db_transaction.transaction_type = "";
        db_transaction.date = Date();
        db_transaction.date.set_time_t(aq_transaction.date.to_time_t());
        db_transaction.valuta_date = Date();
        db_transaction.valuta_date.set_time_t(aq_transaction.valuta_date.to_time_t());
        db_transaction.amount = aq_transaction.value.get_value_as_double();
        db_transaction.currency = aq_transaction.value.get_currency();
        db_transaction.other_name = remote_name;
        db_transaction.other_account_number = aq_transaction.remote_account_number;
        db_transaction.purpose = purpose_text;
        return db_transaction;
    }

    public bool check_user( User user, ref List<Account> accounts ) {

        bank_job_window.show_all();

        unowned AqBanking.User aq_user = to_aq_user( user );

        unowned AqBanking.Provider provider = banking.get_provider( AqBanking.AH_PROVIDER_NAME );
        AqBanking.ImExporterContext context = new AqBanking.ImExporterContext();
        // TODO: check return values
        stdout.printf("cert\n");
        if (provider.get_cert( aq_user, context, false, false, false ) != 0) {
            return false;
        }
        stdout.printf("sys_id\n");
        if (provider.get_sys_id( aq_user, context, false, false, false ) != 0) {
            return false;
        }
        //stdout.printf("user_keys");
        //provider.send_user_keys2( aq_user, context, false, false, false );
        stdout.printf("fertig\n");

        var list = banking.get_accounts();
        if( list != null ) {
            var iter = list.first();
            unowned AqBanking.Account? aq_account = iter.data();

            while( aq_account != null ) {
                if ( aq_account.get_first_selected_user() == aq_user) {
                    Account account = new Account();
                    account.id = -1;
                    account.account_type = "bank";
                    account.account_number = aq_account.account_number;
                    account.bank_code = aq_account.bank_code;
                    account.owner_name = aq_account.owner_name;
                    account.balance = "0";
                    account.currency = aq_account.currency;
                    accounts.append( account );
                    aq_account = iter.next();
                }
            }
        }
        bank_job_window.close();
        return true;
    }

    public void fetch_transactions(User user, Account account, GBankDatabase db) throws Error {

        unowned AqBanking.User aq_user = to_aq_user(user);

        unowned AqBanking.Provider provider = banking.get_provider(AqBanking.AH_PROVIDER_NAME);
        AqBanking.ImExporterContext context = new AqBanking.ImExporterContext();
        provider.get_cert(aq_user, context, false, false, false);
        provider.get_sys_id(aq_user, context, false, false, false);
        provider.send_user_keys2(aq_user, context, false, false, false);

        unowned AqBanking.Account aq_account = to_aq_account(user, account);

        var job = AqBanking.Job.new_get_transactions(aq_account);
        int result = job.check_availability();
        if (result != 0) {
            stdout.printf("Not available (%d)\n", result);
            return;
        }

        var joblist = new AqBanking.JobList();
        joblist.push_back(job);

        result = banking.execute_jobs(joblist, context);

        if (result != 0) {
            stderr.printf("Error in execute queue\n");
            return;
        }

        unowned AqBanking.AccountInfo account_info = context.get_first_account_info();
        while (account_info != null) {
            unowned AqBanking.Transaction transaction = account_info.get_first_transaction();

            while (transaction != null) {
                db.insert_transaction(to_db_transaction(account, transaction));
                transaction = account_info.get_next_transaction();
            }
            account_info = context.get_next_account_info();
        }
        password_cache.remove_all();
    }

    public unowned AqBanking.User to_aq_user(User user) {
        weak AqBanking.User aq_user = user_cache[user.id];
        if (aq_user != null) {
            return aq_user;
        }

        aq_user = banking.create_user (AqBanking.AH_PROVIDER_NAME);
        aq_user.username    = "gbank-%d".printf(user.id);
        aq_user.user_id     = user.user_id;
        aq_user.customer_id = user.customer_id;
        aq_user.country     = user.country;
        aq_user.bank_code   = user.bank_code;
        aq_user.token_type  = user.token_type;
        //user.rdh_type = 1;
        aq_user.crypt_mode = AqBanking.CryptMode.Pintan;
        aq_user.server_url         = Gwenhywfar.url_from_string ( user.server_url );
        aq_user.hbci_version       = user.hbci_version;
        aq_user.http_version_major = user.http_version_major;
        aq_user.http_version_minor = user.http_version_minor;
        aq_user.status = AqBanking.UserStatus.Enabled;
        //user.set
        int result = banking.add_user (aq_user);
        if (result != 0) {
            stdout.printf("Could not add user (%d)\n", result);
        }
        if ( user.id != -1 ) {
            user_cache[user.id] = aq_user;
        }
        return aq_user;
    }

    public unowned AqBanking.Account to_aq_account(User user, Account account) {
        weak AqBanking.Account aq_account = account_cache[account.id];
        if (aq_account != null) {
            return aq_account;
        }

        unowned AqBanking.User aq_user = to_aq_user(user);

        aq_account = banking.create_account (AqBanking.AH_PROVIDER_NAME);
        aq_account.owner_name     = account.owner_name;
        aq_account.account_type   = AqBanking.AccountType.Bank;
        aq_account.account_number = account.account_number;
        aq_account.bank_code      = account.bank_code;
        aq_account.set_user (aq_user);
        aq_account.set_selected_user (aq_user);
        int result = banking.add_account (aq_account);
        if (result != 0) {
            stdout.printf("Could not add account (%d)\n", result);
        }
        account_cache[account.id] = aq_account;
        return aq_account;
    }

    ~Banking() {
        banking.online_finish();
        banking.finish();
        Gwenhywfar.finish();
    }
}
