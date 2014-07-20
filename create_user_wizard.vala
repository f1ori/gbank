
public class BankListRow : Gtk.ListBoxRow {
    private AqBanking.BankInfo bankinfo;

    public BankListRow(AqBanking.BankInfo bankinfo) {
        this.bankinfo = bankinfo.dup();
        var box = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 5 );
        box.add( new Gtk.Label( bankinfo.bank_id ) );
        box.add( new Gtk.Label( bankinfo.bank_name ) );
        this.add( box );
    }

    public bool filter(string search) {
        return true;
    }
}

public class CreateUserWizard : Gtk.Assistant {
    private Gtk.Box type_page;
    private Gtk.Box bank_page;
    private Gtk.Grid login_details_box;
    private Gtk.Entry login_id;
    private Gtk.Entry bank_search;
    private Gtk.TreeView bank_list;
    private Gtk.TreeModelFilter bank_list_filtered;
    private MainWindow main_window;

    public CreateUserWizard(MainWindow main_window) {
        this.main_window = main_window;
        this.set_default_size (500, 500);
        this.set_transient_for (main_window);
        this.set_modal(true);
        this.close.connect(this.on_close);
        this.cancel.connect(this.on_cancel);

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

        // select bank
        bank_page = new Gtk.Box( Gtk.Orientation.VERTICAL, 5 );
        var bank_label = new Gtk.Label( "Select your bank" );
        bank_search = new Gtk.Entry();
        bank_search.set_icon_from_icon_name( Gtk.EntryIconPosition.SECONDARY, "search" );
        bank_search.changed.connect(this.on_bank_search_changed);

        var bank_listmodel = new Gtk.ListStore (2, typeof (string), typeof (string));
        bank_list_filtered = new Gtk.TreeModelFilter(bank_listmodel, null);

        var bankinfo_template = new AqBanking.BankInfo();
        var bank_info_list = new AqBanking.BankInfoList();

        // fill bank list model
        main_window.banking.banking.get_bank_info_by_template( "de", bankinfo_template, bank_info_list );
        var bankinfo_iterator = bank_info_list.first();
        unowned AqBanking.BankInfo bankinfo = bankinfo_iterator.data();
        while(bankinfo != null) {
            Gtk.TreeIter iter;
            bank_listmodel.append(out iter);
            bank_listmodel.set (iter,
                0, bankinfo.bank_id,
                1, bankinfo.bank_name );

            bankinfo = bankinfo_iterator.next();
        }
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

        // enter login information
        login_details_box = new Gtk.Grid( );
        login_details_box.set_row_spacing(4);
        login_details_box.set_column_spacing(4);

        login_details_box.attach(new Gtk.Label( "Enter Bank Account Number or Login Id:" ), 0, 0, 2, 1);

        login_id = new Gtk.Entry ();
        login_id.changed.connect(this.on_login_id_changed);
        login_details_box.attach( new Gtk.Label("Login Id"), 0, 1, 1, 1);
        login_details_box.attach(login_id, 1, 1, 1, 1);

        var test_button = new Gtk.Button.with_label("Test");
        test_button.clicked.connect(this.on_test_button_clicked);
        login_details_box.attach(test_button, 1, 2, 1, 1);

        this.append_page (login_details_box);
        this.set_page_title (login_details_box, "Enter Login Id");
        this.set_page_type (login_details_box, Gtk.AssistantPageType.CONTENT);
        this.set_page_complete (login_details_box, false);

        // summary page
        var select_account_box = new Gtk.Box( Gtk.Orientation.VERTICAL, 5 );
        var select_account_label = new Gtk.Label( "Following accounts will be created:" );
        select_account_box.pack_start(select_account_label, false, false);
        var account_list = new Gtk.ListBox();
        var test_row_box = new Gtk.Box( Gtk.Orientation.HORIZONTAL, 4 );
        var test_row_checkbox = new Gtk.CheckButton();
        test_row_checkbox.set_active(true);
        test_row_box.pack_start(test_row_checkbox, false, false);
        var test_row_label = new Gtk.Label("5406066893");
        test_row_box.pack_start(test_row_label, true, true);
        var test_row = new Gtk.ListBoxRow();
        test_row.add(test_row_box);
        account_list.add(test_row);
        select_account_box.pack_start(account_list, true, true);

        this.append_page (select_account_box);
        this.set_page_title (select_account_box, "Choose Bank Accounts");
        this.set_page_type (select_account_box, Gtk.AssistantPageType.CONFIRM);
        this.set_page_complete (select_account_box, true);

        this.show_all();
    }

    public void on_cancel() {
        destroy();
    }

    public void on_close() {
        destroy();
        // TODO save
    }

    public void on_login_id_changed() {
        this.set_page_complete( login_details_box, this.login_id.get_text() != "" );
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
        stdout.printf("test");
        this.set_page_complete (login_details_box, true);
    }

}
