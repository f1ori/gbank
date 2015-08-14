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
 * main application window
 */

/**
 * ListBoxRow for a bank entry in the sidebar
 */
class BankRow : Gtk.ListBoxRow {
    private User user;

    public BankRow( MainWindow main_window, User user ) {
        this.user = user;

        Gtk.Label bank_name_label = new Gtk.Label( null );
        bank_name_label.set_markup( GLib.Markup.printf_escaped( "<b>%s</b>" , user.bank_name) );

        Gtk.Button edit_button = new Gtk.Button.from_icon_name( "document-properties", Gtk.IconSize.MENU );
        edit_button.clicked.connect(() => {
                new UserDialog(main_window, user);
            });

        Gtk.Box box = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 5 );
        box.pack_start( bank_name_label, false, false );
        box.pack_end( edit_button , false, false );

        this.add(box);
    }
}

/**
 * ListBoxRow for a bank account in the sidebar
 */
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
        box.pack_start( new Gtk.Image.from_icon_name("pan-end-symbolic", Gtk.IconSize.MENU), false, false);
        box.pack_start( vbox, false, false );
        box.pack_end( balance_label , false, false );

        this.add(box);
    }

    public int get_id () {
        return this.db_id;
    }
}

/**
 * main application window
 */
[GtkTemplate (ui = "/de/f1ori/gbank/ui/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {

    [GtkChild]
    private Gtk.ListBox account_list;

    [GtkChild]
    private Gtk.ListStore transactions_liststore;

    [GtkChild]
    private Gtk.TreeModelFilter transactions_liststore_filtered;

    [GtkChild]
    private Gtk.ListBoxRow all_accounts_row;

    [GtkChild]
    private Gtk.Button update_all_button;
    [GtkChild]
    private Gtk.Image update_all_image;
    [GtkChild]
    private Gtk.Spinner update_all_spinner;

    [GtkChild]
    private Gtk.SearchEntry searchentry;

    [GtkChild]
    private Gtk.Overlay overlay;

    private NotificationQueue notification_queue;

    private BankJobWindow bank_job_window;
    private BankingUI banking_ui;
    private Banking banking;
    private GBankDatabase database;

    private Account current_account = null;

    public MainWindow (Gtk.Application app) {
        Object (application: app);

        this.set_default_icon_name("gbank");

        notification_queue = new NotificationQueue();
        overlay.add_overlay(notification_queue.widget);

        database = new GBankDatabase();

        bank_job_window = new BankJobWindow(this);
        banking_ui = new BankingUI(this);

        banking = new Banking(banking_ui, bank_job_window);
        banking.status_message.connect(on_status_message);

        update_account_list();
        fill_transactions(1);

        transactions_liststore_filtered.set_visible_func(this.on_filter_transactions);

        // add about action
        var about_action = new SimpleAction ("about", null);
        about_action.activate.connect (about_cb);
        this.add_action (about_action);
    }

    public unowned Banking get_banking () {
        return this.banking;
    }

    public unowned BankingUI get_banking_ui () {
        return this.banking_ui;
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
            foreach (var user in database.get_all_users()) {
                account_list.add( new BankRow(this, user) );
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
                    4, GLib.Markup.printf_escaped( "<span color='%s' weight='bold'>%.2f €</span>", balance_color, balance ),
                    5, transaction);

                balance -= transaction.amount;
            }

            this.current_account = account;
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
            "website", "http://gbank.f1ori.de/",
            "website-label", ("Website"),
            "license-type", Gtk.License.GPL_3_0,
            "logo-icon-name", "gbank"
        );
    }

    async void update_accounts() {
        var notification = new SpinnerNotification("Update accounts...");
        this.notification_queue.add_notification(notification);

        foreach (var user in database.get_all_users() ) {
            foreach (var account in database.get_accounts_for_user(user)) {

                var text = "Fetch balance from %s %s".printf(user.bank_name, account.account_type);
                notification.set_label(text);
                yield banking.get_balance(user, account, database);
                update_account_list();

                text = "Fetch transactions from %s %s".printf(user.bank_name, account.account_type);
                notification.set_label(text);
                yield banking.fetch_transactions(user, account, database);

                // update transaction list
                var row = account_list.get_selected_row();
                if (row is AccountRow) {
                    var account_row = row as AccountRow;
                    if (account_row.get_id() == account.id) {
                        fill_transactions (account.id);
                    }
                }
            }
        }
        notification.close();
        banking_ui.reset_password_cache();
    }

    [GtkCallback]
    void on_update_accounts () {
        update_all_button.set_image (update_all_spinner);
        update_all_button.set_sensitive (false);

        update_accounts.begin ((obj, res) => {
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

    void on_status_message(string message) {
        stdout.printf("statuuuuuuuuuuus: %s\n", message);
    }

    [GtkCallback]
    void on_transactions_treeview_row_activated(Gtk.TreeView tree_view, Gtk.TreePath path, Gtk.TreeViewColumn column) {
        Gtk.TreeModel model = tree_view.get_model();
        Gtk.TreeIter iter;
        model.get_iter(out iter, path);

        Transaction transaction;
        model.get(iter, 5, out transaction);

        new StatementDialog(this, transaction);
    }

    public bool on_filter_transactions( Gtk.TreeModel model, Gtk.TreeIter iter ) {
        Transaction transaction;
        model.get( iter, 5, out transaction );

        string search_string = this.searchentry.get_text().down();
        foreach ( string keyword in search_string.split( " " ) ) {
            if ( !transaction.reference.down().contains( keyword )
                    && !transaction.other_name.down().contains( keyword )
                    && !transaction.other_iban.down().contains( keyword )
                    && !transaction.other_bic.down().contains( keyword ) )
                return false;
        }
        return true;
    }

    [GtkCallback]
    public void on_search_changed() {
        this.transactions_liststore_filtered.refilter();
    }

    [GtkCallback]
    public void on_transfer_button_clicked() {
        new NewTransferDialog(this, current_account);
    }
}
