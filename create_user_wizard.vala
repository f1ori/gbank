public class CreateUserWizard : Gtk.Assistant {
    private Gtk.Box type_page;
    private Gtk.Box bank_page;
    private Gtk.Grid login_details_box;
    private Gtk.Entry login_id;
    private Gtk.Entry bank_search;
    private Gtk.TreeView bank_list;
    private Gtk.TreeModelFilter bank_list_filtered;
    private MainWindow main_window;
    private bool login_ok;
    private Gtk.Image login_ok_image;
    private User user;
    private Gtk.ListStore account_list_store;
    private Gtk.TreeView account_list_view;

    private enum AccountListColumns {
        TOGGLE,
        TEXT,
        ACCOUNT,
        N_COLUMNS
    }

    public CreateUserWizard(MainWindow main_window) {
        this.main_window = main_window;
        this.set_default_size (500, 500);
        this.set_transient_for (main_window);
        this.set_modal(true);
        this.close.connect(this.on_close);
        this.cancel.connect(this.on_cancel);

        this.setup_type_page();
        this.setup_bank_page();
        this.setup_login_page();
        this.setup_accounts_page();

        this.show_all();
    }

    private void setup_type_page() {
        // select account type
        type_page = new Gtk.Box( Gtk.Orientation.VERTICAL, 5 );
        var type_label = new Gtk.Label( "Choose the type of user you want to create:" );
        var type_radiobutton_hbci = new Gtk.RadioButton.with_label_from_widget (null, "HBCI User");
        var type_radiobutton_ebics = new Gtk.RadioButton.with_label_from_widget (type_radiobutton_hbci, "EBICS User");
        type_radiobutton_hbci.set_active(true);
        type_radiobutton_ebics.set_sensitive(false);
        type_page.pack_start(type_label, false, true);
        type_page.pack_start(type_radiobutton_hbci, false, true);
        type_page.pack_start(type_radiobutton_ebics, false, true);

        this.append_page (type_page);
        this.set_page_title (type_page, "Choose Type");
        this.set_page_type (type_page, Gtk.AssistantPageType.CONTENT);
        this.set_page_complete (type_page, true);
    }

    private void setup_bank_page() {
        // select bank
        bank_page = new Gtk.Box( Gtk.Orientation.VERTICAL, 5 );
        var bank_label = new Gtk.Label( "Select your bank" );
        bank_search = new Gtk.Entry();
        bank_search.set_icon_from_icon_name( Gtk.EntryIconPosition.SECONDARY, "search" );
        bank_search.changed.connect(this.on_bank_search_changed);

        var bank_listmodel = new Gtk.ListStore (2, typeof (string), typeof (string));
        bank_list_filtered = new Gtk.TreeModelFilter(bank_listmodel, null);

        main_window.banking.ghbci_context.blz_foreach((blz) => {
            var bank_name = main_window.banking.ghbci_context.get_name_for_blz(blz);
            Gtk.TreeIter iter;
            bank_listmodel.append(out iter);
            bank_listmodel.set (iter,
                0, blz,
                1, bank_name);
        });
        bank_list_filtered.set_visible_func(this.on_filter_bank_list);

        // prepare bank list widget
        bank_list = new Gtk.TreeView ();
        bank_list.set_model( bank_list_filtered );
        bank_list.insert_column_with_attributes( -1, "BLZ", new Gtk.CellRendererText(), "text", 0 );
        bank_list.insert_column_with_attributes( -1, "Name", new Gtk.CellRendererText(), "text", 1 );
        bank_list.get_selection().changed.connect( this.on_bank_list_selection_changed );
        bank_list.row_activated.connect( this.on_bank_list_row_activated );

        var bank_list_scrolled = new Gtk.ScrolledWindow (null, null);
        bank_list_scrolled.add(bank_list);

        bank_page.pack_start( bank_label, false, false );
        bank_page.pack_start( bank_search, false, false );
        bank_page.pack_start( bank_list_scrolled, true, true );

        this.append_page ( bank_page );
        this.set_page_title ( bank_page, "Choose Bank" );
        this.set_page_type ( bank_page, Gtk.AssistantPageType.CONTENT );
        this.set_page_complete ( bank_page, false );
    }

    private void setup_login_page() {
        // enter login information
        login_details_box = new Gtk.Grid( );
        login_details_box.set_row_spacing(4);
        login_details_box.set_column_spacing(4);

        login_details_box.attach(new Gtk.Label( "Enter Bank Account Number or Login Id:" ), 0, 0, 2, 1);

        login_id = new Gtk.Entry ();
        login_id.changed.connect(this.on_login_id_changed);
        login_ok = false;
        login_ok_image = new Gtk.Image();
        login_details_box.attach( new Gtk.Label("Login Id"), 0, 1, 1, 1);
        login_details_box.attach(login_id, 1, 1, 1, 1);
        login_details_box.attach(login_ok_image, 2, 1, 1, 1);

        var test_button = new Gtk.Button.with_label("Test");
        test_button.clicked.connect(this.on_test_button_clicked);
        login_details_box.attach(test_button, 1, 2, 1, 1);

        this.append_page (login_details_box);
        this.set_page_title (login_details_box, "Enter Login Id");
        this.set_page_type (login_details_box, Gtk.AssistantPageType.CONTENT);
        this.set_page_complete (login_details_box, false);
    }

    private void setup_accounts_page() {
        // select accounts page
        var select_account_box = new Gtk.Box( Gtk.Orientation.VERTICAL, 5 );
        var select_account_label = new Gtk.Label( "Following accounts will be created:" );
        select_account_box.pack_start(select_account_label, false, false);
        account_list_store = new Gtk.ListStore(AccountListColumns.N_COLUMNS, typeof (bool), typeof (string), typeof(Account));
        account_list_view = new Gtk.TreeView.with_model (account_list_store);

        var toggle = new Gtk.CellRendererToggle ();
        toggle.toggled.connect ((toggle, path) => {
            var tree_path = new Gtk.TreePath.from_string (path);
            Gtk.TreeIter iter;
            account_list_store.get_iter (out iter, tree_path);
            account_list_store.set (iter, AccountListColumns.TOGGLE, !toggle.active);
        });

        var column = new Gtk.TreeViewColumn ();
        column.pack_start (toggle, false);
        column.add_attribute (toggle, "active", AccountListColumns.TOGGLE);
        account_list_view.append_column (column);

        var text = new Gtk.CellRendererText ();
        column = new Gtk.TreeViewColumn ();
        column.pack_start (text, true);
        column.add_attribute (text, "text", AccountListColumns.TEXT);
        account_list_view.append_column (column);

        account_list_view.set_headers_visible (false);

        select_account_box.pack_start(account_list_view, true, true);

        this.append_page (select_account_box);
        this.set_page_title (select_account_box, "Choose Bank Accounts");
        this.set_page_type (select_account_box, Gtk.AssistantPageType.CONFIRM);
        this.set_page_complete (select_account_box, true);
    }

    public void on_cancel() {
        destroy();
    }

    public void on_close() {
        // save
        main_window.db.insert_user(ref user);

        Gtk.TreeIter iter;
        for (bool next = account_list_store.get_iter_first (out iter); next; next = account_list_store.iter_next (ref iter)) {
            Value active;
            account_list_store.get_value (iter, AccountListColumns.TOGGLE, out active);
            if (active.get_boolean()) {
                Value gvalue_account;
                account_list_store.get_value (iter, AccountListColumns.ACCOUNT, out gvalue_account);
                Account account = gvalue_account.get_object() as Account;
                account.user_id = user.id;
                main_window.db.insert_account( ref account );
            }
        }
        main_window.update_account_list();
        // TODO update balance
        destroy();
    }

    public void on_login_id_changed() {
        this.login_ok = false;
        this.login_ok_image.clear();
        this.set_page_complete( login_details_box, false );
    }

    public void on_bank_search_changed() {
        this.bank_list_filtered.refilter();
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

    public void on_bank_list_selection_changed() {
        var is_complete = this.bank_list.get_selection().count_selected_rows() == 1;
        this.set_page_complete (bank_page, is_complete);
    }

    public void on_bank_list_row_activated(Gtk.TreePath path, Gtk.TreeViewColumn column) {
        this.next_page();
    }

    public void on_test_button_clicked() {
        stdout.printf( "test" );
        List<Account> accounts = new List<Account>();

        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        this.bank_list.get_selection().get_selected(out model, out iter);
        string blz, bank_name;
        model.get( iter, 0, out blz );
        model.get( iter, 1, out bank_name );

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
        //    this.set_page_complete ( login_details_box, false );
        //    return;
        //}

        string url = main_window.banking.ghbci_context.get_pin_tan_url_for_blz(blz);
        // TODO: ask user, if unknown
        if (url.length > 8) {
            // remove https://
            url = url.substring(8);
        }

        user = new User();
        user.id = -1;
        user.user_id = this.login_id.get_text();
        user.customer_id = this.login_id.get_text();
        user.country = "DE";
        user.bank_code = blz;
        user.bank_name = bank_name;
        user.token_type = "pintan";
        user.host = url;
        user.port = "443";
        user.hbci_version = 300;
        user.sec_mech = "962";

        account_list_store.clear();

        var result = this.main_window.banking.check_user( user , ref accounts );
        stdout.printf( "num accounts %u\n", accounts.length() );
        foreach ( Account account in accounts ) {
            stdout.printf( "%s\n", account.account_number );

            account_list_store.append (out iter);
            account_list_store.set (iter, AccountListColumns.TOGGLE, true, AccountListColumns.TEXT, account.account_number, AccountListColumns.ACCOUNT, account);
        }
        login_ok = result;
        if( login_ok ) {
            this.login_ok_image.set_from_icon_name("gtk-yes", Gtk.IconSize.BUTTON);
        } else {
            this.login_ok_image.set_from_icon_name("gtk-no", Gtk.IconSize.BUTTON);
        }
        this.set_page_complete ( login_details_box, result );
    }

}
