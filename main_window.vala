
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
    private double balance;

    public AccountRow( int db_id, string account_name, string account_number, double balance ) {
        this.db_id = db_id;
        this.account_name = account_name;
        this.account_number = account_number;
        this.balance = balance;

        var balance_color = balance < 0 ? "red": "black";

        Gtk.Label name_label = new Gtk.Label( null );
        name_label.set_markup( GLib.Markup.printf_escaped( "<b>%s</b>" , account_name) );

        Gtk.Label number_label = new Gtk.Label( null );
        number_label.set_markup( GLib.Markup.printf_escaped( "<i>%s</i>" , account_number) );

        Gtk.Label balance_label = new Gtk.Label( null );
        balance_label.set_markup( GLib.Markup.printf_escaped( "<span color='%s'><big>%.2f €</big></span>", balance_color, balance) );

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

    public int get_id () {
        return this.db_id;
    }
}

[GtkTemplate (ui = "/de/f1ori/gbank/ui/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {

    [GtkChild]
    private Gtk.ListBox account_list;

    [GtkChild]
    private Gtk.ListStore transactions_liststore;

    [GtkChild]
    private Gtk.ListBoxRow all_accounts_row;

    [GtkChild]
    private Gtk.Statusbar statusbar;

    [GtkChild]
    private Gtk.Button update_all_button;
    [GtkChild]
    private Gtk.Image update_all_image;
    [GtkChild]
    private Gtk.Spinner update_all_spinner;

    [GtkChild]
    private Gtk.Image open_progress_image;
    [GtkChild]
    private Gtk.Image close_progress_image;

    private BankJobWindow bank_job_window;
    private Banking banking;
    private GBankDatabase database;

    public MainWindow (Gtk.Application app) {
        Object (application: app);

        database = new GBankDatabase();

        bank_job_window = new BankJobWindow(this);

        banking = new Banking(bank_job_window);
        banking.status_message.connect(on_status_message);

        update_account_list();
        fill_transactions(1);

        // add about action
        var about_action = new SimpleAction ("about", null);
        about_action.activate.connect (about_cb);
        this.add_action (about_action);
    }

    public unowned Banking get_banking () {
        return this.banking;
    }

    public unowned GBankDatabase get_database () {
        return this.database;
    }

    public void update_account_list() {
        foreach(var row in account_list.get_children()) {
            if (row != this.all_accounts_row)
                row.destroy();
        }
        try {
            foreach (var user in database.get_users()) {
                account_list.add( new BankRow(
                    user.id,
                    user.bank_name
                ) );
                foreach (var account in database.get_accounts_for_user(user) ) {
                    account_list.add( new AccountRow(
                        account.id,
                        account.account_type,
                        account.account_number,
                        double.parse(account.balance)
                    ) );
                }
            }
            account_list.show_all();
        } catch (Error e) {
            stderr.printf("ERROR: '%s'\n", e.message);
        }
    }

    public void fill_transactions(int account_id) {
        try {
            transactions_liststore.clear();

            var account = database.get_account(account_id);

            double balance = double.parse(account.balance);

            foreach (var transaction in database.get_transactions_for_account(account)) {
                GHbci.Statement.prettify_statement(transaction);
                var amount_color  = transaction.amount < 0 ? "red": "black";
                var balance_color = balance < 0 ? "red": "black";
                string date = "%d.%d.%d".printf(transaction.date.get_day(), transaction.date.get_month(), transaction.date.get_year());
                string valuta_date = "%d.%d.%d".printf(transaction.valuta_date.get_day(), transaction.valuta_date.get_month(), transaction.valuta_date.get_year());

                Gtk.TreeIter iter ;
                transactions_liststore.append(out iter);
                transactions_liststore.set (iter,
                    0, GLib.Markup.printf_escaped( "<b>%s</b>\n%s", date, valuta_date),
                    1, GLib.Markup.printf_escaped( "<b>%s</b>\n%s", transaction.transaction_type, transaction.other_name),
                    2, GLib.Markup.escape_text(transaction.reference),
                    3, GLib.Markup.printf_escaped( "<span color='%s' weight='bold'>%.2f €</span>", amount_color, transaction.amount ),
                    4, GLib.Markup.printf_escaped( "<span color='%s' weight='bold'>%.2f €</span>", balance_color, balance ) );

                balance -= transaction.amount;
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

    async void update_accounts() {
        foreach (var user in database.get_users() ) {
            foreach (var account in database.get_accounts_for_user(user)) {
                yield banking.fetch_transactions(user, account, database);
                yield banking.get_balance(user, account, database);
            }
        }
    }

    [GtkCallback]
    void on_update_accounts () {
        update_all_button.set_image (update_all_spinner);
        update_all_button.set_sensitive (false);
        statusbar.push(statusbar.get_context_id("hbci"), "Connecting...");
        update_accounts.begin ((obj, res) => {
            // TODO: properly update lists
            var row = account_list.get_selected_row ();
            if (row is AccountRow) {
                var account_row = row as AccountRow;
                fill_transactions (account_row.get_id());
            }
            update_all_button.set_image (update_all_image);
            update_all_button.set_sensitive (true);
        });
    }

    [GtkCallback]
    void on_create_user () {
        new CreateUserWizard(this);
    }

    [GtkCallback]
    void on_row_activated(Gtk.ListBoxRow row) {
        if (row is AccountRow) {
            var account_row = row as AccountRow;
            fill_transactions(account_row.get_id());
        }
    }

    [GtkCallback]
    void on_open_progress_button_toggled(Gtk.ToggleButton toggle_button) {
        if (toggle_button.get_active()) {
            bank_job_window.show();
            toggle_button.set_image(close_progress_image);
        } else {
            bank_job_window.hide();
            toggle_button.set_image(open_progress_image);
        }
    }

    void on_status_message(string message) {
        stdout.printf("statuuuuuuuuuuus: %s\n", message);
        uint context_id = statusbar.get_context_id( "hbci" );
        statusbar.remove_all( context_id );
        statusbar.push( context_id, message );
    }
}
