[GtkTemplate (ui = "/de/f1ori/gbank/ui/statement-dialog.ui")]
public class StatementDialog : Gtk.Dialog {
    private MainWindow main_window;

    [GtkChild]
    private Gtk.Entry type_entry;
    [GtkChild]
    private Gtk.Entry booking_date_entry;
    [GtkChild]
    private Gtk.Entry valuta_date_entry;
    [GtkChild]
    private Gtk.Entry other_name_entry;
    [GtkChild]
    private Gtk.Entry iban_entry;
    [GtkChild]
    private Gtk.Entry bic_entry;
    [GtkChild]
    private Gtk.Entry amount_entry;
    [GtkChild]
    private Gtk.Entry eref_entry;
    [GtkChild]
    private Gtk.Entry mref_entry;
    [GtkChild]
    private Gtk.Entry creditor_id_entry;
    [GtkChild]
    private Gtk.TextView reference_textview;


    public StatementDialog(MainWindow main_window, Transaction transaction) {
        this.main_window = main_window;
        this.set_transient_for (main_window);

        string date = "%d.%d.%d".printf(transaction.date.get_day(), transaction.date.get_month(), transaction.date.get_year());
        string valuta_date = "%d.%d.%d".printf(transaction.valuta_date.get_day(), transaction.valuta_date.get_month(), transaction.valuta_date.get_year());
        string amount = "%.2f".printf(transaction.amount);

        type_entry.set_text(transaction.transaction_type);
        booking_date_entry.set_text(date);
        valuta_date_entry.set_text(valuta_date);
        other_name_entry.set_text(transaction.other_name);
        iban_entry.set_text(transaction.other_iban);
        bic_entry.set_text(transaction.other_bic);
        amount_entry.set_text(amount);
        eref_entry.set_text(transaction.eref);
        mref_entry.set_text(transaction.mref);
        creditor_id_entry.set_text(transaction.cred);
        reference_textview.buffer.text = transaction.reference;

        this.show_all();
    }

    [GtkCallback]
    public void on_close_button_clicked() {
        destroy();
    }

}
