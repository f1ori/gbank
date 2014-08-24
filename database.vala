
public class User : Object {
    public int id;
    public string user_id;
    public string customer_id;
    public string bank_code;
    public string bank_name;
    public string country;
    public string token_type;
    public string server_url;
    public int hbci_version;
    public int http_version_major;
    public int http_version_minor;
    public static const string columns = "id, user_id, customer_id, bank_code, bank_name, country, token_type, server_url, hbci_version, http_version_major, http_version_minor";

    public static User from_iter(Gda.DataModelIter iter) {
        User user = new User();
        user.id          = iter.get_value_for_field( "id" ).get_int();
        user.user_id     = iter.get_value_for_field( "user_id" ).get_string();
        user.customer_id = iter.get_value_for_field( "customer_id" ).get_string();
        user.bank_code   = iter.get_value_for_field( "bank_code" ).get_string();
        user.bank_name   = iter.get_value_for_field( "bank_name" ).get_string();
        user.country     = iter.get_value_for_field( "country" ).get_string();
        user.token_type  = iter.get_value_for_field( "token_type" ).get_string();
        user.server_url  = iter.get_value_for_field( "server_url" ).get_string();
        user.hbci_version       = iter.get_value_for_field( "hbci_version" ).get_int();
        user.http_version_major = iter.get_value_for_field( "http_version_major" ).get_int();
        user.http_version_minor = iter.get_value_for_field( "http_version_minor" ).get_int();
        return user;
    }

    public void set_fields(Gda.SqlBuilder builder) {
        builder.add_field_value_as_gvalue( "user_id", this.user_id );
        builder.add_field_value_as_gvalue( "customer_id", this.customer_id );
        builder.add_field_value_as_gvalue( "country", this.country );
        builder.add_field_value_as_gvalue( "bank_code", this.bank_code );
        builder.add_field_value_as_gvalue( "bank_name", this.bank_name );
        builder.add_field_value_as_gvalue( "token_type", this.token_type );
        builder.add_field_value_as_gvalue( "server_url", this.server_url );
        builder.add_field_value_as_gvalue( "hbci_version", this.hbci_version );
        builder.add_field_value_as_gvalue( "http_version_major", this.http_version_major );
        builder.add_field_value_as_gvalue( "http_version_minor", this.http_version_minor );
    }
}

public class Account : Object {
    public static const string columns = "id, user_id, account_type, owner_name, account_number, bank_code, balance, currency";
    public int id;
    public int user_id;
    public string account_type;
    public string owner_name;
    public string account_number;
    public string bank_code;
    public string balance;
    public string currency;

    public static Account from_iter(Gda.DataModelIter iter) {
        Account account = new Account();
        account.id           = iter.get_value_for_field( "id" ).get_int();
        account.user_id      = iter.get_value_for_field( "user_id" ).get_int();
        account.account_type = iter.get_value_for_field( "account_type" ).get_string();
        account.owner_name   = iter.get_value_for_field( "owner_name" ).get_string();
        account.account_number  = iter.get_value_for_field( "account_number" ).get_string();
        account.bank_code    = iter.get_value_for_field( "bank_code" ).get_string();
        account.balance      = iter.get_value_for_field( "balance" ).get_string();
        account.currency     = iter.get_value_for_field( "currency" ).get_string();
        return account;
    }

    public void set_fields(Gda.SqlBuilder builder) {
        builder.add_field_value_as_gvalue( "user_id", this.user_id );
        builder.add_field_value_as_gvalue( "account_type", this.account_type );
        builder.add_field_value_as_gvalue( "owner_name", this.owner_name );
        builder.add_field_value_as_gvalue( "account_number", this.account_number );
        builder.add_field_value_as_gvalue( "bank_code", this.bank_code );
        builder.add_field_value_as_gvalue( "balance", this.balance );
        builder.add_field_value_as_gvalue( "currency", this.currency );
    }
}

public class Transaction : Object {
    public static const string columns = "id, account_id, transaction_type, date, valuta_date, amount, currency, purpose, other_name, other_account_number";
    public int id;
    public int account_id;
    public string transaction_type;
    public Date date;
    public Date valuta_date;
    public double amount;
    public string currency;
    public string purpose;
    public string other_name;
    public string other_account_number;

    public static Transaction from_iter(Gda.DataModelIter iter) {
        Date date = Date();
        date.set_parse(iter.get_value_for_field( "date" ).get_string());
        Date valuta_date = Date();
        valuta_date.set_parse(iter.get_value_for_field( "valuta_date" ).get_string());

        Transaction transaction = new Transaction();
        transaction.id           = iter.get_value_for_field( "id" ).get_int();
        transaction.account_id   = iter.get_value_for_field( "account_id" ).get_int();
        transaction.transaction_type  = iter.get_value_for_field( "transaction_type" ).get_string();
        transaction.date         = date;
        transaction.valuta_date  = valuta_date;
        transaction.amount       = iter.get_value_for_field( "amount" ).get_double();
        transaction.currency     = iter.get_value_for_field( "currency" ).get_string();
        transaction.purpose      = iter.get_value_for_field( "purpose" ).get_string();
        transaction.other_name   = iter.get_value_for_field( "other_name" ).get_string();
        transaction.other_account_number = iter.get_value_for_field( "other_account_number" ).get_string();
        return transaction;
    }

    public void set_fields(Gda.SqlBuilder builder) {
        builder.add_field_value_as_gvalue( "account_id", account_id );
        builder.add_field_value_as_gvalue( "transaction_type", "" );
        builder.add_field_value_as_gvalue( "date", date );
        builder.add_field_value_as_gvalue( "valuta_date", valuta_date );
        builder.add_field_value_as_gvalue( "amount", amount );
        builder.add_field_value_as_gvalue( "currency", currency );
        builder.add_field_value_as_gvalue( "purpose", purpose );
        builder.add_field_value_as_gvalue( "other_name", other_name );
        builder.add_field_value_as_gvalue( "other_account_number", other_account_number );
    }
}


public class GBankDatabase : Object {
    private Gda.Connection connection;

    public GBankDatabase() throws Error {
        this.connection = Gda.Connection.open_from_string (null, "SQLite://DB_DIR=.;DB_NAME=gbank.db", null, Gda.ConnectionOptions.NONE);
        create_tables();
    }

    public User get_user(int id) throws Error {

        Gda.DataModel user_data = this.connection.execute_select_command("SELECT %s FROM users WHERE id = %d;".printf(User.columns, id));
        Gda.DataModelIter user_iter = user_data.create_iter();

        user_iter.move_next();

        return User.from_iter(user_iter);
    }

    public List<User> get_users() throws Error {

        Gda.DataModel user_data = this.connection.execute_select_command("SELECT %s FROM users;".printf(User.columns));
        Gda.DataModelIter user_iter = user_data.create_iter();

        List<User> list = new List<User>();
        while ( user_iter.move_next() ) {
            list.append( User.from_iter(user_iter) );
        }

        return list;
    }

    public void insert_user(ref User user) throws Error {
        var b = new Gda.SqlBuilder(Gda.SqlStatementType.INSERT);
        b.set_table("users");
        user.set_fields( b );

        Gda.Set inserted_row;
        var result = this.connection.statement_execute_non_select(b.get_statement(), null, out inserted_row );
        user.id = inserted_row.get_holder_value("+0").get_int();
        stdout.printf( "create user result %d %d\n", result, user.id );
    }

    public void insert_account(ref Account account) throws Error {
        var b = new Gda.SqlBuilder(Gda.SqlStatementType.INSERT);
        b.set_table("accounts");
        account.set_fields( b );

        var result = this.connection.statement_execute_non_select(b.get_statement(), null, null);
        stdout.printf( "create account result %d\n", result );
    }

    public Account get_account(int id) throws Error {

        Gda.DataModel account_data = this.connection.execute_select_command("SELECT %s FROM accounts WHERE id = %d;".printf(Account.columns, id));
        Gda.DataModelIter account_iter = account_data.create_iter();

        account_iter.move_next();

        return Account.from_iter(account_iter);
    }

    public List<Account> get_accounts_for_user(User user) throws Error {
        Gda.DataModel account_data = this.connection.execute_select_command("SELECT %s FROM accounts WHERE user_id = %d;".printf(Account.columns, user.id));
        Gda.DataModelIter account_iter = account_data.create_iter();

        List<Account> list = new List<Account>();
        while ( account_iter.move_next() ) {
            list.append( Account.from_iter(account_iter) );
        }

        return list;
    }

    public List<Transaction> get_transactions_for_account(Account account) {
        Gda.DataModel transaction_data = this.connection.execute_select_command("SELECT %s FROM transactions WHERE account_id = %d;".printf(Transaction.columns, account.id));
        Gda.DataModelIter transaction_iter = transaction_data.create_iter();

        List<Transaction> list = new List<Transaction>();
        while ( transaction_iter.move_next() ) {
            list.append( Transaction.from_iter(transaction_iter) );
        }

        return list;
    }

    public void insert_transaction(Transaction transaction) throws Error {
        var b = new Gda.SqlBuilder(Gda.SqlStatementType.INSERT);
        b.set_table("transactions");
        transaction.set_fields(b);
        this.connection.statement_execute_non_select(b.get_statement(), null, null);
    }

    public void create_tables() throws Error {
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS version (version);");
        this.connection.execute_non_select_command("INSERT OR IGNORE INTO version (version) VALUES (1);");
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id, customer_id, bank_code, bank_name, country, token_type, server_url, hbci_version, http_version_major, http_version_minor);");
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id, account_type, owner_name, account_number, bank_code, balance, currency);");
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, account_id, transaction_type, date, valuta_date, amount, currency, purpose, other_name, other_account_number);");
        this.connection.execute_non_select_command("INSERT OR IGNORE INTO users (id, user_id, customer_id, bank_code, bank_name, country, token_type, server_url, hbci_version, http_version_major, http_version_minor) VALUES(1, '***REMOVED***', '***REMOVED***', '***REMOVED***', '***REMOVED***', 'de', 'pintan', 'https://***REMOVED***', 300, 1, 1);");
        this.connection.execute_non_select_command("INSERT OR IGNORE INTO accounts (id, user_id, account_type, owner_name, account_number, bank_code, balance, currency) VALUES (1, 1, 'bank', 'Florian Richter', '***REMOVED***', '***REMOVED***', '1000,00', 'EUR');");
    }


}
