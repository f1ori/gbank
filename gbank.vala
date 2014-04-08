using Gtk;


public class GBankDatabase : Object {
    private Gda.Connection connection;
    private HashTable<int, weak AqBanking.User> user_cache;
    private HashTable<int, weak AqBanking.Account> account_cache;

    public GBankDatabase() {
        user_cache = new HashTable<int, AqBanking.User>.full(direct_hash, direct_equal, null, null);
        account_cache = new HashTable<int, AqBanking.Account>.full(direct_hash, direct_equal, null, null);

        this.connection = Gda.Connection.open_from_string (null, "SQLite://DB_DIR=.;DB_NAME=gbank.db", null, Gda.ConnectionOptions.NONE);
        create_tables();
    }

    public void create_tables() {
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS version (version);");
        this.connection.execute_non_select_command("INSERT OR IGNORE INTO version (version) VALUES (1);");
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id, customer_id, bank_code, bank_name, country, token_type, server_url, hbci_version, http_version_major, http_version_minor);");
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id, account_type, owner_name, account_number, bank_code, balance, currency);");
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, account_id, transaction_type, date, valuta_date, amount, currency, purpose, other_name, other_account_number);");
        this.connection.execute_non_select_command("INSERT OR IGNORE INTO users (id, user_id, customer_id, bank_code, bank_name, country, token_type, server_url, hbci_version, http_version_major, http_version_minor) VALUES(1, '***REMOVED***', '***REMOVED***', '***REMOVED***', '***REMOVED***', 'de', 'pintan', 'https://***REMOVED***', 300, 1, 1);");
        this.connection.execute_non_select_command("INSERT OR IGNORE INTO accounts (id, user_id, account_type, owner_name, account_number, bank_code, balance, currency) VALUES (1, 1, 'bank', 'Florian Richter', '***REMOVED***', '***REMOVED***', '1000,00', 'EUR');");
    }

    public void fill_account_list(ListBox account_list) {
        Gda.DataModel user_data = this.connection.execute_select_command("SELECT id, bank_name, bank_code FROM users;");
        Gda.DataModelIter user_iter = user_data.create_iter();

        while ( user_iter.move_next() ) {
            int user_id = user_iter.get_value_for_field( "id").get_int();
            account_list.add( new BankRow(
                user_id,
                user_iter.get_value_for_field( "bank_name").get_string()
            ) );

            Gda.DataModel account_data = this.connection.execute_select_command("SELECT id, account_type, account_number, balance FROM accounts WHERE user_id = %d;".printf(user_id));
            Gda.DataModelIter account_iter = account_data.create_iter();

            while ( account_iter.move_next() ) {
                account_list.add( new AccountRow( 
                    account_iter.get_value_for_field( "id" ).get_int(),
                    account_iter.get_value_for_field( "account_type" ).get_string(),
                    account_iter.get_value_for_field( "account_number" ).get_string(),
                    account_iter.get_value_for_field( "balance" ).get_string()
                ) );
            }
        }
    }

    public unowned AqBanking.User get_aqbanking_user(AqBanking.Banking banking, int user_id) {
        weak AqBanking.User user = user_cache[user_id];
        if (user != null) {
            return user;
        }

        Gda.DataModel user_data = this.connection.execute_select_command("SELECT user_id, customer_id, bank_code, bank_name, country, token_type, server_url, hbci_version, http_version_major, http_version_minor FROM users WHERE id = %d;".printf(user_id));
        Gda.DataModelIter user_iter = user_data.create_iter();

        user_iter.move_next();

        user = banking.create_user (AqBanking.AH_PROVIDER_NAME);
        user.username    = "gbank-%d".printf(user_id);
        user.user_id     = user_iter.get_value_for_field( "user_id" ).get_string();
        user.customer_id = user_iter.get_value_for_field( "customer_id" ).get_string();
        user.country     = user_iter.get_value_for_field( "country" ).get_string();
        user.bank_code   = user_iter.get_value_for_field( "bank_code" ).get_string();
        user.token_type  = user_iter.get_value_for_field( "token_type" ).get_string();
        stdout.printf("token type: %s\n", user.token_type);
        //user.rdh_type = 1;
        user.crypt_mode = AqBanking.CryptMode.Pintan;
        var url = user_iter.get_value_for_field( "server_url" ).get_string();
        user.server_url         = Gwenhywfar.url_from_string ( url );
        user.hbci_version       = user_iter.get_value_for_field( "hbci_version" ).get_int();
        user.http_version_major = user_iter.get_value_for_field( "http_version_major" ).get_int();
        user.http_version_minor = user_iter.get_value_for_field( "http_version_minor" ).get_int();
        user.status = AqBanking.UserStatus.Enabled;
        //user.set
        int result = banking.add_user (user);
        if (result != 0) {
            stdout.printf("Could not add user (%d)\n", result);
        }
        user_cache[user_id] = user;
        return user;
    }

    public int create_user(AqBanking.User user) {

        var b = new Gda.SqlBuilder(Gda.SqlStatementType.INSERT);
        b.set_table("accounts");
        b.add_field_value_as_gvalue( "customer_id", user.customer_id );
        b.add_field_value_as_gvalue( "country", user.country );
        b.add_field_value_as_gvalue( "bank_code", user.bank_code );
        b.add_field_value_as_gvalue( "token_type", user.token_type );
        b.add_field_value_as_gvalue( "server_url", user.server_url );
        b.add_field_value_as_gvalue( "hbci_version", user.hbci_version );
        b.add_field_value_as_gvalue( "http_version_major", user.http_version_major );
        b.add_field_value_as_gvalue( "http_version_minor", user.http_version_minor );

        var result = this.connection.statement_execute_non_select(b.get_statement(), null, null);
        stdout.printf( "create user result %d\n", result );
    }

    public unowned AqBanking.Account get_aqbanking_account(AqBanking.Banking banking, int account_id) {
        weak AqBanking.Account account = account_cache[account_id];
        if (account != null) {
            return account;
        }

        var account_data = this.connection.execute_select_command("SELECT user_id, account_type, owner_name, account_number, bank_code FROM accounts WHERE id = %d;".printf(account_id));
        var account_iter = account_data.create_iter();

        account_iter.move_next();

        int user_id = account_iter.get_value_for_field( "user_id" ).get_int();
        unowned AqBanking.User user = get_aqbanking_user(banking, user_id);

        account = banking.create_account (AqBanking.AH_PROVIDER_NAME);
        account.owner_name   = account_iter.get_value_for_field( "owner_name" ).get_string();
        account.account_type = AqBanking.AccountType.Bank;
        account.account_number = account_iter.get_value_for_field( "account_number" ).get_string();
        account.bank_code = account_iter.get_value_for_field( "bank_code" ).get_string();
        account.set_user (user);
        account.set_selected_user (user);
        int result = banking.add_account (account);
        if (result != 0) {
            stdout.printf("Could not add account (%d)\n", result);
        }
        account_cache[account_id] = account;
        return account;
    }

    public void insert_transaction(int user_id, int account_id, AqBanking.Transaction transaction) {
        string remote_name = "";
        unowned Gwenhywfar.StringListEntry remote_name_entry = transaction.remote_name.first_entry();
        while (remote_name_entry != null) {
            remote_name = "%s\n%s".printf(remote_name, remote_name_entry.data);
            remote_name_entry = remote_name_entry.next();
        }
        remote_name._strip();

        string purpose_text = "";
        unowned Gwenhywfar.StringListEntry purpose = transaction.purpose.first_entry();
        while (purpose != null) {
            purpose_text = "%s\n%s".printf(purpose_text, purpose.data);
            purpose = purpose.next();
        }
        purpose_text._strip();

        Date date = new Date();
        date.set_time_t(transaction.date.to_time_t());
        Date valuta_date = new Date();
        valuta_date.set_time_t(transaction.date.to_time_t());

        var b = new Gda.SqlBuilder(Gda.SqlStatementType.INSERT);
        b.set_table("transactions");
        b.add_field_value_as_gvalue( "account_id", account_id );
        b.add_field_value_as_gvalue( "transaction_type", "" );
        b.add_field_value_as_gvalue( "date", date );
        b.add_field_value_as_gvalue( "valuta_date", valuta_date );
        b.add_field_value_as_gvalue( "amount", transaction.value.get_value_as_double() );
        b.add_field_value_as_gvalue( "currency", transaction.value.get_currency() );
        b.add_field_value_as_gvalue( "other_name", remote_name );
        b.add_field_value_as_gvalue( "other_account_number", transaction.remote_account_number );
        b.add_field_value_as_gvalue( "purpose", purpose_text );

        var result = this.connection.statement_execute_non_select(b.get_statement(), null, null);
        stdout.printf( "result %d\n", result );

        ///stdout.printf( "%f %s, %s\n", transaction.value.get_value_as_double(), transaction.value.get_currency(), purpose_text );
    }

    public void update_liststore(int account_id, ListStore liststore) {
        Gda.DataModel transactions_data = this.connection.execute_select_command("SELECT transaction_type, date, valuta_date, amount, currency, purpose, other_name, other_account_number FROM transactions WHERE account_id = %d;".printf(account_id));
        Gda.DataModelIter transactions_iter = transactions_data.create_iter();

        liststore.clear();

        while (transactions_iter.move_next()) {
            Date date = Date();
            date.set_parse(transactions_iter.get_value_for_field( "date" ).get_string());
            Date valuta_date = Date();
            valuta_date.set_parse(transactions_iter.get_value_for_field( "valuta_date" ).get_string());

            double balance = transactions_iter.get_value_for_field( "amount" ).get_double();
            var balance_color = balance < 0 ? "red": "black";

            TreeIter iter ;
            liststore.append(out iter);
            liststore.set (iter,
                0, "<b>%d.%d.%d</b>\n%d.%d.%d".printf(date.get_day(), date.get_month(), date.get_year(), valuta_date.get_day(), valuta_date.get_month(), valuta_date.get_year()),
                1, transactions_iter.get_value_for_field( "other_name" ).get_string(),
                2, transactions_iter.get_value_for_field( "purpose" ).get_string(),
                3, "<span color='%s' weight='bold'>%.2f €</span>".printf( balance_color, balance ) );
        }
    }
}


public class Banking : Object {
    private AqBanking.Banking banking;
    private static unowned Gtk.Window mainwindow;
    private static HashTable<string, string> password_cache;

    public static int check_cert (Gwenhywfar.Gui gui, Gwenhywfar.SSLCertDescription cert, Gwenhywfar.SyncIO sio, int32 guiid) {
        return 0;
    }

    public static int get_password (Gwenhywfar.Gui gui, int flags, string token, string title, string text, string buffer, int min_len, int max_len, int32 guiid) {
        unowned string password = password_cache.lookup(token);
        if (password != null) {
            Posix.strcpy(buffer, password);
            return 0;
        }
        PasswordDialog dialog = new PasswordDialog(mainwindow);
        dialog.password_entry.max_length = max_len;
        switch (dialog.run()) {
            case ResponseType.OK:
                password_cache.insert(token, dialog.password_entry.text);
                Posix.strcpy(buffer, dialog.password_entry.text);
                dialog.destroy();
                stdout.printf(token);
                stdout.printf(" password provided!!\n");
                return 0;
            case ResponseType.CANCEL:
                dialog.destroy();
                return 1;
        }
        return 1;
    }

    public static int set_password_status (Gwenhywfar.Gui gui, string token, string pin, Gwenhywfar.Gui.PasswordStatus status, int32 guiid) {
        stdout.printf("%d status!\n", status);
        return 0;
    }

    public Banking (Gtk.Window mainwindow) {
        Gwenhywfar.init();
        Banking.mainwindow = mainwindow;
        banking = new AqBanking.Banking("gbank", "/tmp/gbank-aqbanking", 0);

        Gwenhywfar.Gui gui = Gwenhywfar.Gui.new_cgui();
        gui.add_flags(Gwenhywfar.Gui.GuiFlags.NONINTERACTIVE);
        Gwenhywfar.Gui.setGui (gui);
        gui.set_get_password_function(get_password);
        gui.set_set_password_status_function(set_password_status);
        gui.set_check_cert_function(check_cert);

        // Gwenhywfar.Logger_set_level("aqhbci", Gwenhywfar.LoggerLevel.Debug);
        // Gwenhywfar.Logger_set_level("aqbanking", Gwenhywfar.LoggerLevel.Debug);
        // Gwenhywfar.Logger_set_level("gwenhywfar", Gwenhywfar.LoggerLevel.Debug);
        banking.init ();
        banking.online_init ();
        password_cache = new HashTable<string, string> (str_hash, str_equal);
    }

    public void fetch_transactions(GBankDatabase db, ListStore listmodel) {

        unowned AqBanking.User user = db.get_aqbanking_user(banking, 1);

        unowned AqBanking.Provider provider = banking.get_provider(AqBanking.AH_PROVIDER_NAME);
        AqBanking.ImExporterContext context = new AqBanking.ImExporterContext();
        provider.get_cert(user, context, false, false, false);
        provider.get_sys_id(user, context, false, false, false);
        provider.send_user_keys2(user, context, false, false, false);

        unowned AqBanking.Account account = db.get_aqbanking_account(banking, 1);

        var job = AqBanking.Job.new_get_transactions(account);
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
                db.insert_transaction(1, 1, transaction);
                transaction = account_info.get_next_transaction();
            }
            account_info = context.get_next_account_info();
        }
        password_cache.remove_all();
        db.update_liststore(1, listmodel);
    }

    ~Banking() {
        banking.online_finish();
        banking.finish();
        Gwenhywfar.finish();
    }
}

public class PasswordDialog : Dialog {
    public Gtk.Entry password_entry;

    public PasswordDialog(Window parent) {
        this.title = "Enter Password";
        this.set_transient_for (parent);
        this.set_modal (true);
        this.border_width = 5;
        set_default_size (500, 180);
        var label = new Gtk.Label ("Please enter password:");
        password_entry = new Gtk.Entry();
        password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
        password_entry.set_visibility (false);
        password_entry.set_activates_default(true);

        var content = get_content_area () as Box;
        content.pack_start (label, false, true);
        content.pack_start (password_entry, false, true);
        content.spacing = 10;

        add_button (Gtk.Stock.CANCEL, ResponseType.CANCEL);
        var ok_button = add_button (Gtk.Stock.OK, ResponseType.OK);
        set_default_response (ResponseType.OK);
        ok_button.can_default = true;
        set_default (ok_button);
        show_all();
    }

}

public class CreateUserWizard : Gtk.Assistant {
    private Gtk.Box type_box;
    private Gtk.Grid details_box;
    private Gtk.Entry bank_code;
    private Gtk.Entry login_id;

    public CreateUserWizard(Window parent) {
        this.set_default_size (500, 500);
        this.set_transient_for (parent);
        this.set_modal(true);
        this.close.connect(this.on_close);
        this.cancel.connect(this.on_cancel);

        type_box = new Gtk.Box( Orientation.VERTICAL, 5 );
        var type_label = new Gtk.Label( "Choose the type of user you want to create:" );
        var type_radiobutton_hbci = new Gtk.RadioButton.with_label_from_widget (null, "HBCI User");
        var type_radiobutton_ebics = new Gtk.RadioButton.with_label_from_widget (type_radiobutton_hbci, "EBICS User");
        type_radiobutton_hbci.set_active(true);
        type_box.pack_start(type_label, false, true);
        type_box.pack_start(type_radiobutton_hbci, false, true);
        type_box.pack_start(type_radiobutton_ebics, false, true);

        this.append_page (type_box);
        this.set_page_title (type_box, "Select Type");
        this.set_page_type (type_box, Gtk.AssistantPageType.CONTENT);
        this.set_page_complete (type_box, true);

        details_box = new Gtk.Grid( );

        details_box.attach(new Gtk.Label( "Enter Bank Code and Login Id:" ), 0, 0, 2, 1);

        bank_code = new Gtk.Entry ();
        bank_code.changed.connect(this.on_bank_code_changed);
        details_box.attach( new Gtk.Label("Bank code"), 0, 1, 1, 1 );
        details_box.attach( bank_code, 1, 1, 1, 1 );

        login_id = new Gtk.Entry ();
        details_box.attach( new Gtk.Label("Login Id"), 0, 2, 1, 1);
        details_box.attach(login_id, 1, 2, 1, 1);

        this.append_page (details_box);
        this.set_page_title (details_box, "Account Details");
        this.set_page_type (details_box, Gtk.AssistantPageType.CONTENT);
        this.set_page_complete (details_box, false);

        var summary_box = new Gtk.Box( Orientation.VERTICAL, 5 );
        var summary_label = new Gtk.Label( "Enter Bank Code and Login Id:" );
        summary_box.pack_start(summary_label, false, false);

        this.append_page (summary_box);
        this.set_page_title (summary_box, "Summary");
        this.set_page_type (summary_box, Gtk.AssistantPageType.SUMMARY);
        this.set_page_complete (summary_box, true);

        this.show_all();
    }

    public void on_cancel() {
        destroy();
    }

    public void on_close() {
        destroy();
        var user = banking.create_user (AqBanking.AH_PROVIDER_NAME);
        user.username    = "gbank-test";
        user.user_id     = this.bank_code.get_text();
        user.customer_id = this.bank_code.get_text();
        user.country     = "de";
        user.bank_code   = this.bank_code.get_text();
        user.token_type  = "pintan";
        user.crypt_mode  = AqBanking.CryptMode.Pintan;
        user.server_url         = Gwenhywfar.url_from_string ( "https://***REMOVED***" );
        user.hbci_version       = 300;
        user.http_version_major = 1;
        user.http_version_minor = 1;
        user.status = AqBanking.UserStatus.Enabled;

        int result = banking.add_user (user);
        if (result != 0) {
            stdout.printf("Could not add user (%d)\n", result);
        }
    }

    public void on_bank_code_changed() {
        this.set_page_complete (details_box, true);
    }

}

class BankRow : Gtk.ListBoxRow {
    private int db_id;
    private string bank_name;

    public BankRow( int db_id, string bank_name ) {
        this.db_id = db_id;
        this.bank_name = bank_name;

        Gtk.Label bank_name_label = new Gtk.Label( null );
        bank_name_label.set_markup( GLib.Markup.printf_escaped( "<b>%s</b>" , bank_name) );

        Gtk.Button edit_button = new Gtk.Button.from_icon_name( "document-properties", Gtk.IconSize.MENU );

        Gtk.Box box = new Gtk.Box( Orientation.HORIZONTAL, 5 );
        box.pack_start( bank_name_label, false, false );
        box.pack_end( edit_button , false, false );

        this.add(box);
    }
}

class AccountRow : Gtk.ListBoxRow {
    private int db_id;
    private string account_name;
    private string account_number;
    private string balance;

    public AccountRow( int db_id, string account_name, string account_number, string balance ) {
        this.db_id = db_id;
        this.account_name = account_name;
        this.account_number = account_number;
        this.balance = balance;

        Gtk.Label name_label = new Gtk.Label( null );
        name_label.set_markup( GLib.Markup.printf_escaped( "<b>%s</b>" , account_name) );

        Gtk.Label number_label = new Gtk.Label( null );
        number_label.set_markup( GLib.Markup.printf_escaped( "<i>%s</i>" , account_number) );

        Gtk.Label balance_label = new Gtk.Label( null );
        balance_label.set_markup( GLib.Markup.printf_escaped( "<big>%s</big>" , balance) );

        //Gtk.Button edit_button = new Gtk.Button.from_icon_name( "list-remove", Gtk.IconSize.BUTTON );

        Gtk.Box vbox = new Gtk.Box( Orientation.VERTICAL, 2 );
        vbox.pack_start( name_label, false, false );
        vbox.pack_start( number_label, false, false);

        Gtk.Box box = new Gtk.Box( Orientation.HORIZONTAL, 5 );
        box.pack_start( new Gtk.Arrow(Gtk.ArrowType.RIGHT, Gtk.ShadowType.ETCHED_IN), false, false );
        box.pack_start( vbox, false, false );
        box.pack_end( balance_label , false, false );

        this.add(box);
    }
}

public class MainWindow : Gtk.ApplicationWindow {

    private ListStore transaction_listmodel;
    private Banking banking;
    private GBankDatabase db;

    public MainWindow (Gtk.Application app) {
        Object (application: app, title: "Gmenu Example");

        db = new GBankDatabase();

        banking = new Banking(this);

        this.set_default_size ( 800, 600 );
        //this.icon = IconTheme.get_default ().load_icon ("my-app", 48, 0);

        var about_action = new SimpleAction ("about", null);
        about_action.activate.connect (this.about_cb);
        this.add_action (about_action);
        
        Gtk.HeaderBar headerBar = new Gtk.HeaderBar ();
        headerBar.set_title ("GBank");
        headerBar.set_show_close_button (true);
        
        var update_all_button = new Gtk.Button.from_icon_name ( "mail-send-receive-symbolic", Gtk.IconSize.LARGE_TOOLBAR );
        update_all_button.clicked.connect (this.on_update_accounts);
        headerBar.pack_start (update_all_button);

        var entry = new Gtk.Entry ();
        entry.set_icon_from_icon_name (Gtk.EntryIconPosition.PRIMARY, "system-search");
        headerBar.pack_end (entry);
        this.set_titlebar (headerBar);

        var account_list = new Gtk.ListBox();
        account_list.width_request = 230;
        var all_accounts_row = new Gtk.ListBoxRow();
        var all_accounts = new Gtk.Box( Orientation.HORIZONTAL, 20 );
        var create_account_button = new Gtk.Button.from_icon_name( "list-add", Gtk.IconSize.MENU );
        create_account_button.clicked.connect(this.on_create_user);
        all_accounts.margin = 5;
        all_accounts.pack_start( new Gtk.Label( "All Accounts" ), false, false );
        all_accounts.pack_end( create_account_button , false, false );
        all_accounts_row.add( all_accounts );
        account_list.add( all_accounts_row );

        Gtk.ScrolledWindow treeview_scrolled = new Gtk.ScrolledWindow(null, null);

        transaction_listmodel = new ListStore (4, typeof (string), typeof (string), typeof (string), typeof (string));
        TreeView treeview = new TreeView ();
        treeview.set_model (transaction_listmodel);
        treeview.insert_column_with_attributes (-1, "Datum", new CellRendererText(), "markup", 0);
        treeview.insert_column_with_attributes (-1, "Type", new CellRendererText(), "markup", 1);
        treeview.insert_column_with_attributes (-1, "Purpose", new CellRendererText(), "markup", 2);
        treeview.insert_column_with_attributes (-1, "Balance", new CellRendererText(), "markup", 3);

        db.fill_account_list( account_list );
        db.update_liststore( 1, transaction_listmodel );

        Gtk.Statusbar statusbar = new Gtk.Statusbar();

        Gtk.Button transfer_button = new Gtk.Button.with_label("New Transfer");
        Gtk.Button standing_orders_button = new Gtk.Button.with_label("Standing Orders");

        Gtk.Label balance_label = new Gtk.Label(null);
        balance_label.set_markup( GLib.Markup.printf_escaped( "<big>%s</big>" , "10,00 €") );

        var window_box = new Box (Orientation.VERTICAL, 0);
        var mainbox = new Box (Orientation.HORIZONTAL, 5);
        var account_header_box = new Box (Orientation.HORIZONTAL, 5);
        account_header_box.margin = 5;
        var account_box = new Box (Orientation.VERTICAL, 0);

        account_header_box.pack_start(transfer_button, false, false);
        account_header_box.pack_start(standing_orders_button, false, false);
        account_header_box.pack_end(balance_label, false, false);
        account_box.pack_start(account_header_box, false, false);
        treeview_scrolled.add(treeview);
        account_box.pack_start(treeview_scrolled);
        mainbox.pack_start(account_list, false);
        mainbox.pack_start(account_box, true);
        window_box.pack_start(mainbox);
        window_box.pack_end(statusbar, false, false);
        this.add(window_box);
        this.show_all ();
    }

    void about_cb (SimpleAction simple, Variant? parameter) {
        string[] authors = {"Florian Richter"};
        Gtk.show_about_dialog (this,
            "program-name", ("GBank"),
            "comments", "Simple Online Banking Programm",
            "version", "0.1",
            "copyright", ("Copyright © 2014 Florian Richter"),
            "authors", authors,
            "website", "http://gbank.github.com/",
            "website-label", ("Website"),
            "license", "GPL"
        );
    }

    void on_update_accounts () {
        banking.fetch_transactions(this.db, transaction_listmodel);
    }

    void on_create_user () {
        var assistant = new CreateUserWizard(this);
    }
}


class GBank : Gtk.Application {
    public GBank () {
        Object (application_id: "com.github.gbank", flags: ApplicationFlags.FLAGS_NONE);
    }

    /* Override the 'startup' signal of GLib.Application. */
    protected override void startup () {
        base.startup ();

        var menu = new GLib.Menu ();
        menu.append ("About", "win.about");
        menu.append ("Quit", "app.quit");
        this.app_menu = menu;

        var quit_action = new SimpleAction ("quit", null);
        quit_action.activate.connect (this.quit);
        this.add_action (quit_action);
    }

    protected override void activate () {
        new MainWindow (this);
    }
}

int main (string[] args) {
    return new GBank ().run (args);
}