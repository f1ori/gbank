

public class Banking : Object {
    public GHbci.Context ghbci_context;
    private static unowned BankJobWindow bank_job_window;
    public User? current_user;

    string on_ghbci_callback (int64 reason, string message, string optional) {
        if (current_user == null) {
            warning("No user defined to answer: %s", message);
            return "";
        }
        debug("reason: %Iu, %s\n", reason, message);
        switch(reason) {
            case GHbci.Reason.NEED_COUNTRY:
                return "DE";
            case GHbci.Reason.NEED_BLZ:
                return current_user.bank_code;
            case GHbci.Reason.NEED_USERID:
                return current_user.user_id;
            case GHbci.Reason.NEED_CUSTOMERID:
                return current_user.customer_id;
            case GHbci.Reason.NEED_HOST:
                return current_user.host;
            case GHbci.Reason.NEED_PORT:
                return current_user.port;
            case GHbci.Reason.NEED_FILTER:
                return "Base64";
            // TODO: encrypt everything with a master password
            case GHbci.Reason.NEED_PASSPHRASE_LOAD:
                return "42";
            case GHbci.Reason.NEED_PASSPHRASE_SAVE:
                return "42";
            case GHbci.Reason.NEED_PT_PIN:
                return get_password();
            case GHbci.Reason.NEED_PT_SECMECH:
                stdout.printf("sec mech: %s\n", optional);
                return "962";
        }
        return "";
    }

    public string? get_password () {
        PasswordDialog dialog = new PasswordDialog(bank_job_window);
        switch (dialog.run()) {
            case Gtk.ResponseType.OK:
                var password = dialog.password_entry.text;
                dialog.destroy();
                return password;
            case Gtk.ResponseType.CANCEL:
                dialog.destroy();
                return null;
        }
        return null;
    }


    public Banking (BankJobWindow bank_job_window) {

        Banking.bank_job_window = bank_job_window;
        ghbci_context = new GHbci.Context();

        ghbci_context.callback.connect( on_ghbci_callback );
        ghbci_context.log.connect( (message, level) => {stdout.printf("ghbci-log: %s\n", message);} );
        current_user = null;
    }

    public bool check_user( User user, ref List<Account> accounts ) {

        bank_job_window.show_all();

        current_user = user;
        ghbci_context.add_passport(user.bank_code, user.user_id);

        var account_list = ghbci_context.get_accounts(user.bank_code, user.user_id);
        foreach (var account in account_list) {
            Account db_account = new Account();
            db_account.id = -1;
            db_account.account_type = "bank";
            db_account.account_number = account.number;
            db_account.bank_code = account.blz;
            db_account.owner_name = account.name;
            db_account.balance = "0";
            db_account.currency = account.currency;
            accounts.append( db_account );
        }
        current_user = null;
        bank_job_window.close();
        return true;
    }

    public void fetch_transactions(User user, Account account, GBankDatabase db) throws Error {

        current_user = user;
        ghbci_context.add_passport(user.bank_code, user.user_id);

        var statements = ghbci_context.get_statements(user.bank_code, user.user_id, account.account_number);

        foreach (GHbci.Statement statement in statements) {
            Transaction db_transaction = new Transaction();
            db_transaction.id = -1;
            db_transaction.account_id = account.id;
            db_transaction.transaction_type = "";
            db_transaction.date = statement.booking_date;
            db_transaction.valuta_date = statement.valuta;
            db_transaction.amount = double.parse(statement.value);
            db_transaction.currency = "EUR";
            db_transaction.other_name = statement.other_name;
            db_transaction.other_account_number = statement.other_iban;
            db_transaction.purpose = statement.reference;
            db.insert_transaction(db_transaction);
        }
        current_user = null;
    }

}
