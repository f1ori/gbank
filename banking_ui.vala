public class BankingUI : Object, IBankingUI {

    private HashTable<string, string> password_cache;
    private MainWindow main_window;

    public BankingUI(MainWindow main_window) {
        this.password_cache = new HashTable<string, string>(str_hash, str_equal);
        this.main_window = main_window;
    }

    public string get_password(User user) {
        string key = "%s+%s".printf(user.bank_code, user.user_id);
        if (password_cache.contains(key)) {
            return password_cache.get(key);
        }
        string prompt = "Please enter password for %s:".printf(user.bank_name);
        string password = run_password_dialog(prompt);
        password_cache.insert(key, password);
        return password;
    }

    public string get_tan(string hint){
        string prompt = "Please enter tan (%s):".printf(hint);
        return run_password_dialog(prompt);
    }

    public void wrong_password(User user) {
        string key = "%s+%s".printf(user.bank_code, user.user_id);
        password_cache.remove(key);
    }

    private string run_password_dialog(string prompt) {
        string password = null;
        
        PasswordDialog dialog = new PasswordDialog(main_window, prompt);
        switch (dialog.run()) {
            case Gtk.ResponseType.OK:
                password = dialog.password_entry.text;
                dialog.destroy();
                break;
            case Gtk.ResponseType.CANCEL:
                dialog.destroy();
                break;
        }
        return password;
    }

    public void reset_password_cache() {
        password_cache.remove_all();
    }
}