[GtkTemplate (ui = "/de/f1ori/gbank/ui/new-transfer-dialog.ui")]
public class NewTransferDialog : Gtk.Dialog {
    private MainWindow main_window;

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
    private Gtk.Entry amount_entry;
    [GtkChild]
    private Gtk.Entry reference_entry;

    private Account account;


    public NewTransferDialog(MainWindow main_window, Account account) {
        this.main_window = main_window;
        this.set_transient_for (main_window);

        this.account = account;

        this.show_all();
    }

    [GtkCallback]
    public void on_send_button_clicked() {
        var db = main_window.get_database();
        var user = db.get_user(account.user_id);

        this.main_window.get_banking().send_transfer(user, account, db,
            name_entry.get_text(), bic_entry.get_text(), iban_entry.get_text(),
            reference_entry.get_text(), amount_entry.get_text());

        destroy();
    }

    [GtkCallback]
    public void on_cancel_button_clicked() {
        destroy();
    }

}
