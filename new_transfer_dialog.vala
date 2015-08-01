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

        var database = main_window.get_database();
        try {
            foreach (var user in database.get_users()) {
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
            foreach (var contact in database.get_contacts()) {
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
        var database = this.main_window.get_database();

        Gtk.TreeIter iter;
        account_combobox.get_active_iter(out iter);

        User user;
        Account account;
        accounts_liststore.get(iter, 1, out user, 2, out account);

        this.main_window.get_banking().send_transfer(user, account, database,
            name_entry.get_text(), bic_entry.get_text(), iban_entry.get_text(),
            reference_entry.get_text(), "%.2f".printf(amount_spinbutton.get_value()));

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
