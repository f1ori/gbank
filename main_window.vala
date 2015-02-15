
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

    private Banking banking;
    private GBankDatabase database;

    public MainWindow (Gtk.Application app) {
        Object (application: app);

        database = new GBankDatabase();

        banking = new Banking(new BankJobWindow(this));

        update_account_list();
        fill_transactions(1);
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
                        account.balance
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

            foreach (var transaction in database.get_transactions_for_account(database.get_account(account_id))) {
                var amount_color = transaction.amount < 0 ? "red": "black";
                string date = "%d.%d.%d".printf(transaction.date.get_day(), transaction.date.get_month(), transaction.date.get_year());
                string valuta_date = "%d.%d.%d".printf(transaction.valuta_date.get_day(), transaction.valuta_date.get_month(), transaction.valuta_date.get_year());

                Gtk.TreeIter iter ;
                transactions_liststore.append(out iter);
                transactions_liststore.set (iter,
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

    [GtkCallback]
    void on_update_accounts () {
        foreach (var user in database.get_users() ) {
            foreach (var account in database.get_accounts_for_user(user)) {
                banking.fetch_transactions(user, account, database);
            }
        }
        fill_transactions(1); // TODO: show last
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
}
