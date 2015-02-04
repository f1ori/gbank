
class BankRow : Gtk.ListBoxRow {
    private int db_id;
    private string bank_name;

    public BankRow( int db_id, string bank_name ) {
        this.db_id = db_id;
        this.bank_name = bank_name;

        Gtk.Label bank_name_label = new Gtk.Label( null );
        bank_name_label.set_markup( GLib.Markup.printf_escaped( "<b>%s</b>" , bank_name) );

        Gtk.Button edit_button = new Gtk.Button.from_icon_name( "document-properties", Gtk.IconSize.MENU );

        Gtk.Box box = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 5 );
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

        Gtk.Box vbox = new Gtk.Box( Gtk.Orientation.VERTICAL, 2 );
        vbox.pack_start( name_label, false, false );
        vbox.pack_start( number_label, false, false);

        Gtk.Box box = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 5 );
        box.pack_start( new Gtk.Arrow(Gtk.ArrowType.RIGHT, Gtk.ShadowType.ETCHED_IN), false, false );
        box.pack_start( vbox, false, false );
        box.pack_end( balance_label , false, false );

        this.add(box);
    }
}

public class MainWindow : Gtk.ApplicationWindow {

    private Gtk.ListBox account_list;
    private Gtk.ListStore transaction_listmodel;
    private Gtk.ListBoxRow all_accounts_row;
    public Banking banking;
    public GBankDatabase db;

    public MainWindow (Gtk.Application app) {
        Object (application: app, title: "Gmenu Example");

        db = new GBankDatabase();

        banking = new Banking(new BankJobWindow(this));

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

        account_list = new Gtk.ListBox();
        account_list.width_request = 230;
        all_accounts_row = new Gtk.ListBoxRow();
        var all_accounts = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 20 );
        var create_account_button = new Gtk.Button.from_icon_name( "list-add", Gtk.IconSize.MENU );
        create_account_button.clicked.connect(this.on_create_user);
        all_accounts.margin = 5;
        all_accounts.pack_start( new Gtk.Label( "All Accounts" ), false, false );
        all_accounts.pack_end( create_account_button , false, false );
        all_accounts_row.add( all_accounts );
        account_list.add( all_accounts_row );

        Gtk.ScrolledWindow treeview_scrolled = new Gtk.ScrolledWindow(null, null);

        transaction_listmodel = new Gtk.ListStore (4, typeof (string), typeof (string), typeof (string), typeof (string));
        Gtk.TreeView treeview = new Gtk.TreeView ();
        treeview.set_model (transaction_listmodel);
        treeview.insert_column_with_attributes (-1, "Datum", new Gtk.CellRendererText(), "markup", 0);
        treeview.insert_column_with_attributes (-1, "Type", new Gtk.CellRendererText(), "markup", 1);
        treeview.insert_column_with_attributes (-1, "Purpose", new Gtk.CellRendererText(), "markup", 2);
        treeview.insert_column_with_attributes (-1, "Balance", new Gtk.CellRendererText(), "markup", 3);

        update_account_list();
        fill_transactions();

        Gtk.Statusbar statusbar = new Gtk.Statusbar();

        Gtk.Button transfer_button = new Gtk.Button.with_label("New Transfer");
        Gtk.Button standing_orders_button = new Gtk.Button.with_label("Standing Orders");

        Gtk.Label balance_label = new Gtk.Label(null);
        balance_label.set_markup( GLib.Markup.printf_escaped( "<big>%s</big>" , "10,00 €") );

        var window_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        var mainbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        var account_header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        account_header_box.margin = 5;
        var account_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

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

    public void update_account_list() {
        foreach(var row in account_list.get_children()) {
            if (row != this.all_accounts_row)
                row.destroy();
        }
        try {
            foreach (var user in db.get_users()) {
                account_list.add( new BankRow(
                    user.id,
                    user.bank_name
                ) );
                foreach (var account in db.get_accounts_for_user(user) ) {
                    account_list.add( new AccountRow( 
                        account.id,
                        account.account_type,
                        account.account_number,
                        account.balance
                    ) );
                }
            }
            account_list.show_all();
        } catch (Error e) {
            stderr.printf("ERROR: '%s'\n", e.message);
        }
    }

    public void fill_transactions() {
        try {
            transaction_listmodel.clear();

            foreach (var transaction in db.get_transactions_for_account(db.get_account(1))) {
                var amount_color = transaction.amount < 0 ? "red": "black";
                string date = "%d.%d.%d".printf(transaction.date.get_day(), transaction.date.get_month(), transaction.date.get_year());
                string valuta_date = "%d.%d.%d".printf(transaction.valuta_date.get_day(), transaction.valuta_date.get_month(), transaction.valuta_date.get_year());

                Gtk.TreeIter iter ;
                transaction_listmodel.append(out iter);
                transaction_listmodel.set (iter,
                    0, GLib.Markup.printf_escaped( "<b>%s</b>\n%s", date, valuta_date),
                    1, GLib.Markup.escape_text(transaction.other_name),
                    2, GLib.Markup.escape_text(transaction.purpose),
                    3, GLib.Markup.printf_escaped( "<span color='%s' weight='bold'>%.2f €</span>", amount_color, transaction.amount ) );
            }
        } catch (Error e) {
            stderr.printf("ERROR: '%s'\n", e.message);
        }
    }

    void about_cb (SimpleAction simple, Variant? parameter) {
        string[] authors = {"Florian Richter"};
        Gtk.show_about_dialog (this,
            "program-name", ("GBank"),
            "comments", "Simple Online Banking Application",
            "version", "0.1",
            "copyright", ("Copyright © 2015 Florian Richter"),
            "authors", authors,
            "website", "http://gbank.github.com/",
            "website-label", ("Website"),
            "license", "GPL"
        );
    }

    void on_update_accounts () {
        foreach (var user in db.get_users() ) {
            foreach (var account in db.get_accounts_for_user(user)) {
                banking.fetch_transactions(user, account, db);
            }
        }
        fill_transactions();
    }

    void on_create_user () {
        new CreateUserWizard(this);
    }
}