
public class PasswordDialog : Gtk.Dialog {
    public Gtk.Entry password_entry;

    public PasswordDialog(Gtk.Window parent) {
        this.title = "Enter Password";
        this.set_transient_for (parent);
        this.set_modal (true);
        this.border_width = 5;
        set_default_size (500, 180);
        var label = new Gtk.Label ("Please enter password:");
        password_entry = new Gtk.Entry();
        password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
        password_entry.set_visibility (false);
        password_entry.set_activates_default(true);

        var content = get_content_area () as Gtk.Box;
        content.pack_start (label, false, true);
        content.pack_start (password_entry, false, true);
        content.spacing = 10;

        add_button ("Cancel", Gtk.ResponseType.CANCEL);
        var ok_button = add_button ("OK", Gtk.ResponseType.OK);
        set_default_response (Gtk.ResponseType.OK);
        ok_button.can_default = true;
        set_default (ok_button);
        show_all();
    }

}
