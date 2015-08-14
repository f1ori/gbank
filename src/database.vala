/*  This file is part of gbank, a Gtk+ Online Banking Software using HBCI
 *  Copyright (C) 2015 Florian Richter
 *
 *  gbank is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  gbank is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with gbank.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * This module handles all database interaction.
 */

/**
 * a User account at a bank (wrapper for database)
 */
public class User : Object {
    public int id;
    public string user_id;
    public string customer_id;
    public string bank_code;
    public string bank_name;
    public string bic;
    public string country;
    public string token_type;
    public string host;
    public string port;
    public string sec_mech;
    public int hbci_version;
    public static const string columns = "id, user_id, customer_id, bank_code, bank_name, bic, country, token_type, host, port, hbci_version, sec_mech";

    public User.from_iter(Gda.DataModelIter iter) {
        this.id          = iter.get_value_for_field( "id" ).get_int();
        this.user_id     = iter.get_value_for_field( "user_id" ).get_string();
        this.customer_id = iter.get_value_for_field( "customer_id" ).get_string();
        this.bank_code   = iter.get_value_for_field( "bank_code" ).get_string();
        this.bank_name   = iter.get_value_for_field( "bank_name" ).get_string();
        this.bic         = iter.get_value_for_field( "bic" ).get_string();
        this.country     = iter.get_value_for_field( "country" ).get_string();
        this.token_type  = iter.get_value_for_field( "token_type" ).get_string();
        this.host        = iter.get_value_for_field( "host" ).get_string();
        this.port        = iter.get_value_for_field( "port" ).get_string();
        this.hbci_version = iter.get_value_for_field( "hbci_version" ).get_int();
        this.sec_mech    = iter.get_value_for_field( "sec_mech" ).get_string();
    }

    public void set_fields(Gda.SqlBuilder builder) {
        builder.add_field_value_as_gvalue( "user_id", this.user_id );
        builder.add_field_value_as_gvalue( "customer_id", this.customer_id );
        builder.add_field_value_as_gvalue( "country", this.country );
        builder.add_field_value_as_gvalue( "bank_code", this.bank_code );
        builder.add_field_value_as_gvalue( "bank_name", this.bank_name );
        builder.add_field_value_as_gvalue( "bic", this.bic );
        builder.add_field_value_as_gvalue( "token_type", this.token_type );
        builder.add_field_value_as_gvalue( "host", this.host );
        builder.add_field_value_as_gvalue( "port", this.port );
        builder.add_field_value_as_gvalue( "hbci_version", this.hbci_version );
        builder.add_field_value_as_gvalue( "sec_mech", this.sec_mech );
    }
}

/**
 * Bank account belonging to a user account at a bank (wrapper for database)
 */
public class Account : Object {
    public static const string columns = "id, user_id, account_type, owner_name, account_number, bank_code, bic, iban, balance, currency";
    public int id;
    public int user_id;
    public string account_type;
    public string owner_name;
    public string account_number;
    public string bank_code;
    public string bic;
    public string iban;
    public string balance;
    public string currency;

    public Account.from_iter(Gda.DataModelIter iter) {
        this.id           = iter.get_value_for_field( "id" ).get_int();
        this.user_id      = iter.get_value_for_field( "user_id" ).get_int();
        this.account_type = iter.get_value_for_field( "account_type" ).dup_string();
        this.owner_name   = iter.get_value_for_field( "owner_name" ).dup_string();
        this.account_number  = iter.get_value_for_field( "account_number" ).dup_string();
        this.bank_code    = iter.get_value_for_field( "bank_code" ).dup_string();
        this.bic          = iter.get_value_for_field( "bic" ).dup_string();
        this.iban         = iter.get_value_for_field( "iban" ).dup_string();
        this.balance      = iter.get_value_for_field( "balance" ).dup_string();
        this.currency     = iter.get_value_for_field( "currency" ).dup_string();
    }

    public void set_fields(Gda.SqlBuilder builder) {
        builder.add_field_value_as_gvalue( "user_id", this.user_id );
        builder.add_field_value_as_gvalue( "account_type", this.account_type );
        builder.add_field_value_as_gvalue( "owner_name", this.owner_name );
        builder.add_field_value_as_gvalue( "account_number", this.account_number );
        builder.add_field_value_as_gvalue( "bank_code", this.bank_code );
        builder.add_field_value_as_gvalue( "bic", this.bic );
        builder.add_field_value_as_gvalue( "iban", this.iban );
        builder.add_field_value_as_gvalue( "balance", this.balance );
        builder.add_field_value_as_gvalue( "currency", this.currency );
    }
}

/**
 * Transaction / bank statement
 */
public class Transaction : Object {
    public static const string columns = "id, account_id, transaction_type, date, valuta_date, amount, currency, reference, other_name, other_iban, other_bic";
    public int id;
    public int account_id;
    public string transaction_type;
    public Date date { get; set; }
    public Date valuta_date { get; set; }
    public double amount { get; set; }
    public string currency { get; set; }
    public string reference { get; set; }
    public string other_name { get; set; }
    public string other_iban { get; set; }
    public string other_bic { get; set; }
    // SEPA fields, not saved in database
    public string eref { get; set; }
    public string mref { get; set; }
    public string cred { get; set; }

    public Transaction.from_iter(Gda.DataModelIter iter) {
        Date date = Date();
        date.set_parse(iter.get_value_for_field( "date" ).dup_string());
        Date valuta_date = Date();
        valuta_date.set_parse(iter.get_value_for_field( "valuta_date" ).dup_string());

        this.id           = iter.get_value_for_field( "id" ).get_int();
        this.account_id   = iter.get_value_for_field( "account_id" ).get_int();
        this.transaction_type  = iter.get_value_for_field( "transaction_type" ).dup_string();
        this.date         = date;
        this.valuta_date  = valuta_date;
        this.amount       = iter.get_value_for_field( "amount" ).get_double();
        this.currency     = iter.get_value_for_field( "currency" ).dup_string();
        this.reference    = iter.get_value_for_field( "reference" ).dup_string();
        this.other_name   = iter.get_value_for_field( "other_name" ).dup_string();
        this.other_iban   = iter.get_value_for_field( "other_iban" ).dup_string();
        this.other_bic    = iter.get_value_for_field( "other_bic" ).dup_string();
    }

    private Gda.SqlBuilderId set_select_field(Gda.SqlBuilder builder, string name, Value value) {
        return builder.add_cond(
            Gda.SqlOperatorType.EQ,
            builder.add_field_id(name, "transactions"), 
            builder.add_expr_value(null, value),
            0);
    }

    public void set_select_fields(Gda.SqlBuilder builder) {
        var fields = new Gda.SqlBuilderId[10];

        fields[0] = set_select_field( builder, "account_id", account_id );
        fields[1] = set_select_field( builder, "transaction_type", transaction_type );
        fields[2] = set_select_field( builder, "date", date );
        fields[3] = set_select_field( builder, "valuta_date", valuta_date );
        fields[4] = set_select_field( builder, "amount", amount );
        fields[5] = set_select_field( builder, "currency", currency );
        fields[6] = set_select_field( builder, "reference", reference );
        fields[7] = set_select_field( builder, "other_name", other_name );
        fields[8] = set_select_field( builder, "other_iban", other_iban );
        fields[9] = set_select_field( builder, "other_bic", other_bic );

        var where = builder.add_cond_v(Gda.SqlOperatorType.AND, fields);
        builder.set_where(where);
    }

    public void set_fields(Gda.SqlBuilder builder) {
        builder.add_field_value_as_gvalue( "account_id", account_id );
        builder.add_field_value_as_gvalue( "transaction_type", transaction_type );
        builder.add_field_value_as_gvalue( "date", date );
        builder.add_field_value_as_gvalue( "valuta_date", valuta_date );
        builder.add_field_value_as_gvalue( "amount", amount );
        builder.add_field_value_as_gvalue( "currency", currency );
        builder.add_field_value_as_gvalue( "reference", reference );
        builder.add_field_value_as_gvalue( "other_name", other_name );
        builder.add_field_value_as_gvalue( "other_iban", other_iban );
        builder.add_field_value_as_gvalue( "other_bic", other_bic );
    }
}

/**
 * Contact with name, iban and bic, used for transfers
 */
public class Contact : Object {
    public string name;
    public string iban;
    public string bic;

    /**
     * create contact from other_* fields of a transaction
     */
    public Contact.from_iter(Gda.DataModelIter iter) {
        this.name = iter.get_value_for_field( "other_name" ).dup_string();
        this.iban = iter.get_value_for_field( "other_iban" ).dup_string();
        this.bic  = iter.get_value_for_field( "other_bic" ).dup_string();
    }
}

/**
 * Provides database access
 */
public class GBankDatabase : Object {
    private Gda.Connection connection;

    public GBankDatabase() throws Error {
        var dir = Path.build_filename(Environment.get_user_config_dir(), "gbank");
        var file = File.new_for_path(dir);
        if (file.query_file_type(FileQueryInfoFlags.NOFOLLOW_SYMLINKS) != FileType.DIRECTORY) {
            file.make_directory();
        }
        this.connection = Gda.Connection.open_from_string (null, "SQLite://DB_DIR=%s;DB_NAME=gbank".printf(dir), null, Gda.ConnectionOptions.NONE);
        create_tables();
    }

    public User get_user(int id) throws Error {

        Gda.DataModel user_data = this.connection.execute_select_command("SELECT %s FROM users WHERE id = %d;".printf(User.columns, id));
        Gda.DataModelIter user_iter = user_data.create_iter();

        user_iter.move_next();

        return new User.from_iter(user_iter);
    }

    public List<User> get_all_users() throws Error {

        Gda.DataModel user_data = this.connection.execute_select_command("SELECT %s FROM users;".printf(User.columns));
        Gda.DataModelIter user_iter = user_data.create_iter();

        List<User> list = new List<User>();
        while ( user_iter.move_next() ) {
            list.append( new User.from_iter(user_iter) );
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

        return new Account.from_iter(account_iter);
    }

    public List<Account> get_accounts_for_user(User user) throws Error {
        Gda.DataModel account_data = this.connection.execute_select_command("SELECT %s FROM accounts WHERE user_id = %d;".printf(Account.columns, user.id));
        Gda.DataModelIter account_iter = account_data.create_iter();

        List<Account> list = new List<Account>();
        while ( account_iter.move_next() ) {
            list.append( new Account.from_iter(account_iter) );
        }

        return list;
    }

    public List<Transaction> get_transactions_for_account(Account account) {
        Gda.DataModel transaction_data = this.connection.execute_select_command("SELECT %s FROM transactions WHERE account_id = %d ORDER BY date DESC;".printf(Transaction.columns, account.id));
        Gda.DataModelIter transaction_iter = transaction_data.create_iter();

        List<Transaction> list = new List<Transaction>();
        while ( transaction_iter.move_next() ) {
            list.append( new Transaction.from_iter(transaction_iter) );
        }

        return list;
    }

    public List<Contact> get_all_contacts() throws Error {
        Gda.DataModel contacts_data = this.connection.execute_select_command(
            "SELECT DISTINCT other_name, other_iban, other_bic "
            +"FROM transactions "
            +"WHERE length(other_name)>0 AND length(other_iban)>0 AND length(other_bic)>0 "
            +"ORDER BY other_name;");
        Gda.DataModelIter contacts_iter = contacts_data.create_iter();

        List<Contact> list = new List<Contact>();
        while ( contacts_iter.move_next() ) {
            list.append( new Contact.from_iter(contacts_iter) );
        }

        return list;
    }

    public void insert_transaction(Transaction transaction) throws Error {
        // check if transaction is already present
        var builder = new Gda.SqlBuilder(Gda.SqlStatementType.SELECT);
        builder.select_add_target("transactions", null);
        transaction.set_select_fields(builder);
        builder.select_add_field("*", "transactions", null);
        var result = this.connection.statement_execute_select(builder.get_statement(), null);

        var iter = result.create_iter();

        if(!iter.move_next()) {
            // save transaction
            builder = new Gda.SqlBuilder(Gda.SqlStatementType.INSERT);
            builder.set_table("transactions");
            transaction.set_fields(builder);
            this.connection.statement_execute_non_select(builder.get_statement(), null, null);
        }
    }

    public void save_user(User user) throws Error {
        var b = new Gda.SqlBuilder(Gda.SqlStatementType.UPDATE);
        b.set_table("users");
        user.set_fields( b );
        var where = b.add_cond( Gda.SqlOperatorType.EQ,
                                b.add_field_id("id", "users"),
                                b.add_expr_value( null, user.id ),
                                0);
        b.set_where( where );

        this.connection.statement_execute_non_select(b.get_statement(), null, null);
    }

    public void save_account(Account account) throws Error {
        var b = new Gda.SqlBuilder(Gda.SqlStatementType.UPDATE);
        b.set_table("accounts");
        account.set_fields( b );
        var where = b.add_cond( Gda.SqlOperatorType.EQ,
                                b.add_field_id("id", "accounts"),
                                b.add_expr_value( null, account.id ),
                                0);
        b.set_where( where );

        this.connection.statement_execute_non_select(b.get_statement(), null, null);
    }

    public void create_tables() throws Error {
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS version (version);");
        this.connection.execute_non_select_command("INSERT OR IGNORE INTO version (version) VALUES (1);");
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id, customer_id, bank_code, bank_name, bic, country, token_type, host, port, hbci_version, sec_mech);");
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id, account_type, owner_name, account_number, bank_code, bic, iban, balance, currency);");
        this.connection.execute_non_select_command("CREATE TABLE IF NOT EXISTS transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, account_id, transaction_type, date, valuta_date, amount, currency, reference, other_name, other_iban, other_bic);");
        //this.connection.execute_non_select_command("INSERT OR IGNORE INTO users (id, user_id, customer_id, bank_code, bank_name, country, token_type, server_url, hbci_version, http_version_major, http_version_minor) VALUES(1, 'xxx', 'xxx', 'xxx', 'xxx', 'de', 'pintan', 'xxx', 300, 1, 1);");
        //this.connection.execute_non_select_command("INSERT OR IGNORE INTO accounts (id, user_id, account_type, owner_name, account_number, bank_code, balance, currency) VALUES (1, 1, 'bank', 'xxx', 'xxx', 'xxx', '1000,00', 'EUR');");
    }

}
