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
  * Wizard leading through the configuration of a User account at a bank
  * and associated bank accounts
  */

 [GtkTemplate (ui = "/de/f1ori/gbank/ui/create-user-wizard.ui")]
public class CreateUserWizard : Gtk.Assistant {
    private MainWindow main_window;

    // assistant pages
    [GtkChild]
    private Gtk.Box bank_page;
    [GtkChild]
    private Gtk.Grid login_page;

    [GtkChild]
    private Gtk.Entry login_id_entry;
    [GtkChild]
    private Gtk.Entry bank_search;
    [GtkChild]
    private Gtk.TreeView bank_list;
    [GtkChild]
    private Gtk.TreeModelFilter bank_liststore_filtered;
    private bool login_ok;
    [GtkChild]
    private Gtk.Stack login_ok_stack;
    [GtkChild]
    private Gtk.Button test_button;
    [GtkChild]
    private Gtk.ListStore bank_liststore;
    [GtkChild]
    private Gtk.ListStore accounts_liststore;

    // user to be created
    private User user;

    private enum AccountListColumns {
        TOGGLE,
        TEXT,
        ACCOUNT,
        N_COLUMNS
    }

    public CreateUserWizard(MainWindow main_window) {
        this.main_window = main_window;
        this.set_transient_for (main_window);

        var banking = (this.main_window.application as GBank).getBanking();

        banking.get_bank_list().foreach( (blz) => {
            var bank_name = banking.get_name_for_blz(blz);
            Gtk.TreeIter iter;
            bank_liststore.append(out iter);
            bank_liststore.set (iter,
                0, blz,
                1, bank_name);
        });

        bank_liststore_filtered.set_visible_func(this.on_filter_bank_list);

        this.show_all();
    }

    [GtkCallback]
    public void on_cancel() {
        destroy();
    }

    [GtkCallback]
    public void on_close() {
        var database = (this.main_window.application as GBank).getDatabase();
        // save
        database.insert_user(ref user);

        Gtk.TreeIter iter;
        for (bool next = accounts_liststore.get_iter_first (out iter); next; next = accounts_liststore.iter_next (ref iter)) {
            Value active;
            accounts_liststore.get_value (iter, AccountListColumns.TOGGLE, out active);
            if (active.get_boolean()) {
                Value gvalue_account;
                accounts_liststore.get_value (iter, AccountListColumns.ACCOUNT, out gvalue_account);
                Account account = gvalue_account.get_object() as Account;
                account.user_id = user.id;
                database.insert_account( ref account );
            }
        }
        main_window.update_account_list();
        // TODO update balance
        destroy();
    }

    [GtkCallback]
    public void on_login_id_changed() {
        this.login_ok = false;
        this.login_ok_stack.set_visible_child_name( "none" );
        this.set_page_complete( login_page, false );
    }

    [GtkCallback]
    public void on_bank_search_changed() {
        this.bank_liststore_filtered.refilter();
    }

    public bool on_filter_bank_list( Gtk.TreeModel model, Gtk.TreeIter iter ) {
        string blz, name;
        model.get( iter, 0, out blz );
        model.get( iter, 1, out name );

        string search_string = this.bank_search.get_text().down();
        foreach ( string keyword in search_string.split( " " ) ) {
            if ( !blz.down().contains( keyword ) && !name.down().contains( keyword ) )
                return false;
        }
        return true;
    }

    [GtkCallback]
    public void on_bank_list_selection_changed() {
        var is_complete = this.bank_list.get_selection().count_selected_rows() == 1;
        this.set_page_complete (bank_page, is_complete);
    }

    [GtkCallback]
    public void on_bank_list_row_activated(Gtk.TreePath path, Gtk.TreeViewColumn column) {
        this.next_page();
    }

    [GtkCallback]
    public void on_test_button_clicked() {
        var banking = (this.main_window.application as GBank).getBanking();

        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        this.bank_list.get_selection().get_selected(out model, out iter);
        string blz, bank_name;
        model.get( iter, 0, out blz );
        model.get( iter, 1, out bank_name );

        this.login_ok_stack.set_visible_child_name( "progress" );
        this.test_button.set_sensitive( false );

        // be sure to keep a reference to bank_info while iterating the services
        //var bank_info = main_window.banking.banking.get_bank_info("de", "", blz);
        //unowned AqBanking.BankInfoServiceList services = bank_info.get_services();
        //unowned AqBanking.BankInfoService? service = services.first();
        //while(service != null && service.mode != "PINTAN") {
        //   service = service.next();
        //}
        //if (service == null) {
        //    // TODO hint url unknown!!
        //    stdout.printf("url not found\n");
        //    this.login_ok_image.set_from_icon_name("gtk-no", Gtk.IconSize.BUTTON); 
        //    this.set_page_complete ( login_page, false );
        //    return;
        //}

        string url = banking.get_pin_tan_url_for_blz(blz);
        // TODO: ask user, if unknown
        if (url.length > 8) {
            // remove https://
            url = url.substring(8);
        }

        user = new User();
        user.id = -1;
        user.user_id = this.login_id_entry.get_text();
        user.customer_id = this.login_id_entry.get_text();
        user.country = "DE";
        user.bank_code = blz;
        user.bank_name = bank_name;
        user.token_type = "pintan";
        user.host = url;
        user.port = "443";
        user.hbci_version = 300;
        user.sec_mech = "962";

        accounts_liststore.clear();

        banking.check_user.begin( user , (obj, res) => {
            Gee.List<Account> accounts;
            var result = banking.check_user.end(res, out accounts);
            foreach ( Account account in accounts ) {
                stdout.printf( "%s\n", account.account_number );

                accounts_liststore.append (out iter);
                accounts_liststore.set (iter, AccountListColumns.TOGGLE, true, AccountListColumns.TEXT, account.account_number, AccountListColumns.ACCOUNT, account);
            }
            login_ok = result;
            if( login_ok ) {
                this.login_ok_stack.set_visible_child_name( "ok" );
            } else {
                this.login_ok_stack.set_visible_child_name( "bad" );
            }
            this.set_page_complete ( login_page, result );
            this.test_button.set_sensitive( true );

            main_window.get_banking_ui().reset_password_cache();
        });
    }

}
