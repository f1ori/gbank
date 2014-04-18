
public class CreateUserWizard : Gtk.Assistant {
    private Gtk.Box type_box;
    private Gtk.Grid details_box;
    private Gtk.Entry bank_code;
    private Gtk.Entry login_id;

    public CreateUserWizard(Gtk.Window parent) {
        this.set_default_size (500, 500);
        this.set_transient_for (parent);
        this.set_modal(true);
        this.close.connect(this.on_close);
        this.cancel.connect(this.on_cancel);

        type_box = new Gtk.Box( Gtk.Orientation.VERTICAL, 5 );
        var type_label = new Gtk.Label( "Choose the type of user you want to create:" );
        var type_radiobutton_hbci = new Gtk.RadioButton.with_label_from_widget (null, "HBCI User");
        var type_radiobutton_ebics = new Gtk.RadioButton.with_label_from_widget (type_radiobutton_hbci, "EBICS User");
        type_radiobutton_hbci.set_active(true);
        type_box.pack_start(type_label, false, true);
        type_box.pack_start(type_radiobutton_hbci, false, true);
        type_box.pack_start(type_radiobutton_ebics, false, true);

        this.append_page (type_box);
        this.set_page_title (type_box, "Select Type");
        this.set_page_type (type_box, Gtk.AssistantPageType.CONTENT);
        this.set_page_complete (type_box, true);

        details_box = new Gtk.Grid( );

        details_box.attach(new Gtk.Label( "Enter Bank Code and Login Id:" ), 0, 0, 2, 1);

        bank_code = new Gtk.Entry ();
        bank_code.changed.connect(this.on_bank_code_changed);
        details_box.attach( new Gtk.Label("Bank code"), 0, 1, 1, 1 );
        details_box.attach( bank_code, 1, 1, 1, 1 );

        login_id = new Gtk.Entry ();
        details_box.attach( new Gtk.Label("Login Id"), 0, 2, 1, 1);
        details_box.attach(login_id, 1, 2, 1, 1);

        this.append_page (details_box);
        this.set_page_title (details_box, "Account Details");
        this.set_page_type (details_box, Gtk.AssistantPageType.CONTENT);
        this.set_page_complete (details_box, false);

        var summary_box = new Gtk.Box( Gtk.Orientation.VERTICAL, 5 );
        var summary_label = new Gtk.Label( "Enter Bank Code and Login Id:" );
        summary_box.pack_start(summary_label, false, false);

        this.append_page (summary_box);
        this.set_page_title (summary_box, "Summary");
        this.set_page_type (summary_box, Gtk.AssistantPageType.SUMMARY);
        this.set_page_complete (summary_box, true);

        this.show_all();
    }

    public void on_cancel() {
        destroy();
    }

    public void on_close() {
        destroy();
        // TODO save
    }

    public void on_bank_code_changed() {
        this.set_page_complete (details_box, true);
    }

}