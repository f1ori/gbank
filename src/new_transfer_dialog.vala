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
 * Dialog to issue new transfers
 */

[GtkTemplate (ui = "/de/f1ori/gbank/ui/new-transfer-dialog.ui")]
public class NewTransferDialog : Gtk.Dialog {
    private MainWindow main_window;

    [GtkChild]
    private Gtk.ListStore accounts_liststore;
    [GtkChild]
    private Gtk.ListStore contacts_liststore;
    [GtkChild]
    private Gtk.ComboBox account_combobox;
    [GtkChild]
    private Gtk.Entry name_entry;
    [GtkChild]
    private Gtk.Entry bic_entry;
    [GtkChild]
    private Gtk.Entry iban_entry;
    [GtkChild]
    private Gtk.Entry bank_entry;
    [GtkChild]
    private Gtk.SpinButton amount_spinbutton;
    [GtkChild]
    private Gtk.Entry reference_entry;


    public NewTransferDialog(MainWindow main_window, Account current_account) {
        this.main_window = main_window;
        this.set_transient_for (main_window);

        var database = (main_window.application as GBank).getDatabase();
        try {
            foreach (var user in database.get_all_users()) {
                foreach (var account in database.get_accounts_for_user(user) ) {
                    Gtk.TreeIter iter ;
                    accounts_liststore.append(out iter);
                    accounts_liststore.set (iter,
                        0, GLib.Markup.printf_escaped( "%s <b>%s</b> (%s)", user.bank_name, account.account_type, account.account_number),
                        1, user,
                        2, account);
                    if (account.id == current_account.id) {
                        account_combobox.set_active_iter(iter);
                    }
                }
            }
        } catch (Error e) {
            stderr.printf("ERROR: '%s'\n", e.message);
        }

        try {
            foreach (var contact in database.get_all_contacts()) {
                Gtk.TreeIter iter ;
                contacts_liststore.append(out iter);
                contacts_liststore.set (iter,
                    0, contact.name,
                    1, contact.iban,
                    2, contact.bic,
                    3, "%s %s".printf(contact.name, contact.iban));
            }
        } catch (Error e) {
            stderr.printf("ERROR: '%s'\n", e.message);
        }

        this.show_all();
    }

    [GtkCallback]
    public void on_send_button_clicked() {
        var database = (this.main_window.application as GBank).getDatabase();
        var banking = (this.main_window.application as GBank).getBanking();

        Gtk.TreeIter iter;
        account_combobox.get_active_iter(out iter);

        User user;
        Account account;
        accounts_liststore.get(iter, 1, out user, 2, out account);

        char[] buffer = new char[15];
        string amount = amount_spinbutton.get_value().format(buffer, "%.2f");

        banking.send_transfer.begin(user, account, database,
            name_entry.get_text(), bic_entry.get_text(), iban_entry.get_text(),
            reference_entry.get_text(), amount);

        this.main_window.get_banking_ui().reset_password_cache();

        destroy();
    }

    [GtkCallback]
    public void on_cancel_button_clicked() {
        destroy();
    }

    [GtkCallback]
    public bool on_name_entrycompletion_match_selected(Gtk.TreeModel model, Gtk.TreeIter iter) {
        string name, iban, bic;
        model.get(iter, 0, out name);
        model.get(iter, 1, out iban);
        model.get(iter, 2, out bic);

        name_entry.set_text(name);
        iban_entry.set_text(iban);
        bic_entry.set_text(bic);

        amount_spinbutton.grab_focus();

        return true;
    }

}
