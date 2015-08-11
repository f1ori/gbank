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
 * Dialog to showing details for bank access
 */

[GtkTemplate (ui = "/de/f1ori/gbank/ui/user-dialog.ui")]
public class UserDialog : Gtk.Dialog {
    private MainWindow main_window;
    private User user;

    [GtkChild]
    private Gtk.ListStore tan_methods_liststore;
    [GtkChild]
    private Gtk.Entry name_entry;
    [GtkChild]
    private Gtk.Entry bic_entry;
    [GtkChild]
    private Gtk.ComboBox tan_method_combobox;


    public UserDialog(MainWindow main_window, User user) {
        this.main_window = main_window;
        this.set_transient_for (main_window);
        this.user = user;

        var database = main_window.get_database();

        this.name_entry.text = user.bank_name;
        this.bic_entry.text = user.bank_code;

        this.show_all();

        this.on_update_tan_methods_button_clicked();
    }

    [GtkCallback]
    public void on_close_button_clicked() {
        destroy();
    }

    [GtkCallback]
    public void on_value_changed() {
        var database = main_window.get_database();

        Gtk.TreeIter iter;
        if (tan_method_combobox.get_active_iter(out iter)) {
            string tan_method;
            tan_methods_liststore.get(iter, 0, out tan_method);
            user.sec_mech = tan_method;
        }

        user.bank_name = name_entry.text;
        database.save_user(user);
        this.main_window.update_account_list();
    }

    [GtkCallback]
    public void on_update_tan_methods_button_clicked() {

        var banking = main_window.get_banking();
        banking.get_tan_methods.begin(user, (obj, res) => {
                var tan_methods = banking.get_tan_methods.end(res);
                tan_methods_liststore.clear();
                Gtk.TreeIter iter;
                foreach(string key in tan_methods.get_keys()) {
                    tan_methods_liststore.append(out iter);
                    tan_methods_liststore.set(iter, 0, key, 1, tan_methods[key]);
                    if (user.sec_mech == key) {
                        tan_method_combobox.set_active_iter(iter);
                    }
                }
            });
    }
}
