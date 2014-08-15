[CCode (cheader_filename = "aqbanking5/aqbanking/banking.h,aqbanking5/aqhbci/aqhbci.h,aqbanking5/aqhbci/user.h,aqbanking5/aqhbci/tanmethod.h")]

namespace AqBanking {

    [CCode (cname = "AH_PROVIDER_NAME")]
    public string AH_PROVIDER_NAME;

    [CCode (cname = "AB_ACCOUNT_LIST2", free_function = "AB_Account_List2_free")]
    [Compact]
    public class AccountList {

        [CCode (cname = "AB_Account_List2_First")]
        public AccountListIterator first();

    }

    [CCode (cname = "AB_ACCOUNT_LIST2_ITERATOR", free_function = "AB_Account_List2Iterator_free")]
    [Compact]
    public class AccountListIterator {

        [CCode (cname = "AB_Account_List2Iterator_Data")]
        public unowned Account? data();

        [CCode (cname = "AB_Account_List2Iterator_Next")]
        public unowned Account? next();

    }

    [CCode (cname = "AH_CRYPT_MODE", cprefix = "AH_CryptMode_", has_type_id = false)]
    public enum CryptMode {
        Unkonwn,
        None,
        Ddv,
        Pintan,
        Rdh
    }

    [CCode (cname = "AH_USER_STATUS", cprefix = "AH_UserStatus", has_type_id = false)]
    public enum UserStatus {
        New,
        Enabled,
        Pending,
        Disabled,
        Unknown
    }


/*    [CCode (cname = "AH_TAN_METHOD_LIST", free_function = "AH_TanMethod_List2_freeAll")]
    [Compact]
    public class JobList {

        [CCode (cname = "AB_Job_List2_new")]
        public JobList ();

        [CCode (cname = "AB_Job_List2_PushBack")]
        public void push_back (Job job);

        [CCode (cname = "AB_Job_List2_ClearAll")]
        public void clear_all ();
    }*/

    [CCode (cname = "AH_TAN_METHOD", free_function = "AH_TanMethod_free")]
    [Compact]
    public class TanMethod {

        public int function {
            [CCode (cname = "AH_TanMethod_GetFunction")] get;
            [CCode (cname = "AH_TanMethod_SetFunction")] set;
        }

        public string method_id {
            [CCode (cname = "AH_TanMethod_GetMethodId")] get;
            [CCode (cname = "AH_TanMethod_SetMethodId")] set;
        }

        public string method_name {
            [CCode (cname = "AH_TanMethod_GetMethodName")] get;
            [CCode (cname = "AH_TanMethod_SetMethodName")] set;
        }

        [CCode (cname = "AH_TanMethod_List_Next")]
        public TanMethod list_next ();
    }

    [CCode (cname = "AH_TAN_METHOD_LIST", free_function = "AH_TanMethod_List2_freeAll")]
    [Compact]
    public class TanMethodList {
        [CCode (cname = "AH_TanMethod_List_First")]
        public TanMethod first ();
    }

    [CCode (cname = "AB_USER", free_function = "AB_User_free")]
    [Compact]
    public class User {

        public bool modified {
            [CCode (cname = "AB_User_IsModified")] get;
            [CCode (cname = "AB_User_SetModified")] set;
        }

        public int unique_id {
            [CCode (cname = "AB_User_GetUniqueId")] get;
            [CCode (cname = "AB_User_SetUniqueId")] set;
        }

        public string backend_name {
            [CCode (cname = "AB_User_GetBackendName")] get;
            [CCode (cname = "AB_User_SetBackendName")] set;
        }

        public string username {
            [CCode (cname = "AB_User_GetUserName")] get;
            [CCode (cname = "AB_User_SetUserName")] set;
        }

        public string user_id {
            [CCode (cname = "AB_User_GetUserId")] get;
            [CCode (cname = "AB_User_SetUserId")] set;
        }

        public string customer_id {
            [CCode (cname = "AB_User_GetCustomerId")] get;
            [CCode (cname = "AB_User_SetCustomerId")] set;
        }

        public string country {
            [CCode (cname = "AB_User_GetCountry")] get;
            [CCode (cname = "AB_User_SetCountry")] set;
        }

        public string bank_code {
            [CCode (cname = "AB_User_GetBankCode")] get;
            [CCode (cname = "AB_User_SetBankCode")] set;
        }

        public int last_session_id {
            [CCode (cname = "AB_User_GetLastSessionId")] get;
            [CCode (cname = "AB_User_SetLastSessionId")] set;
        }

        public Banking banking {
            [CCode (cname = "AB_User_GetBanking")] get;
            [CCode (cname = "AB_User_SetBanking")] set;
        }

        /* aqhbci backend */

        public string token_type {
            [CCode (cname = "AH_User_GetTokenType")] get;
            [CCode (cname = "AH_User_SetTokenType")] set;
        }

        public string token_name {
            [CCode (cname = "AH_User_GetTokenName")] get;
            [CCode (cname = "AH_User_SetTokenName")] set;
        }

        public int32 token_context_id {
            [CCode (cname = "AH_User_GetTokenContextId")] get;
            [CCode (cname = "AH_User_SetTokenContextId")] set;
        }

        public int max_transfers_per_job {
            [CCode (cname = "AH_User_GetMaxTransfersPerJob")] get;
            [CCode (cname = "AH_User_SetMaxTransfersPerJob")] set;
        }

        public int max_debit_notes_per_job {
            [CCode (cname = "AH_User_GetMaxDebitNotesPerJob")] get;
            [CCode (cname = "AH_User_SetMaxDebitNotesPerJob")] set;
        }

        [CCode (cname = "AH_User_FindSepaDescriptor")]
        public string find_sepa_descriptor;

        public Gwenhywfar.Url server_url {
            [CCode (cname = "AH_User_GetServerUrl")] get;
            [CCode (cname = "AH_User_SetServerUrl")] set;
        }

        public int rdh_type {
            [CCode (cname = "AH_User_GetRdhType")] get;
            [CCode (cname = "AH_User_SetRdhType")] set;
        }

        public string peer_id {
            [CCode (cname = "AH_User_GetPeerId")] get;
            [CCode (cname = "AH_User_SetPeerId")] set;
        }

        public string system_id {
            [CCode (cname = "AH_User_GetSystemId")] get;
            [CCode (cname = "AH_User_SetSystemId")] set;
        }

        [CCode (cname = "AH_User_GetTanMethodList")]
        public int[] get_tan_method_list();

        [CCode (cname = "AH_User_GetTanMethodCount")]
        public int get_tan_method_count();

        [CCode (cname = "AH_User_HasTanMethod")]
        public bool has_tan_method();

        [CCode (cname = "AH_User_HasTanMethodOtherThan")]
        public bool has_tan_method_other_than();

        [CCode (cname = "AH_User_AddTanMethod")]
        public void add_tan_method(int method);

        [CCode (cname = "AH_User_ClearTanMethodList")]
        public void clear_tan_method_list();

        [CCode (cname = "AH_User_GetSelectedTanMethod")]
        public int get_selected_tan_method();

        [CCode (cname = "AH_User_SetSelectedTanMethod")]
        public void set_selected_tan_method(int tan_method);

        [CCode (cname = "AH_User_GetTanMethodDescriptions")]
        public unowned TanMethodList get_tan_method_descriptions();

        public CryptMode crypt_mode {
            [CCode (cname = "AH_User_GetCryptMode")] get;
            [CCode (cname = "AH_User_SetCryptMode")] set;
        }

        public int hbci_version {
            [CCode (cname = "AH_User_GetHbciVersion")] get;
            [CCode (cname = "AH_User_SetHbciVersion")] set;
        }

        public int http_version_major {
            [CCode (cname = "AH_User_GetHttpVMajor")] get;
            [CCode (cname = "AH_User_SetHttpVMajor")] set;
        }

        public int http_version_minor {
            [CCode (cname = "AH_User_GetHttpVMinor")] get;
            [CCode (cname = "AH_User_SetHttpVMinor")] set;
        }

        public string user_agent {
            [CCode (cname = "AH_User_GetHttpUserAgent")] get;
            [CCode (cname = "AH_User_SetHttpUserAgent")] set;
        }

        public string tan_medium_id {
            [CCode (cname = "AH_User_GetTanMediumId")] get;
            [CCode (cname = "AH_User_SetTanMediumId")] set;
        }

        public UserStatus status {
            [CCode (cname = "AH_User_GetStatus")] get;
            [CCode (cname = "AH_User_SetStatus")] set;
        }

    }

    [CCode (cname = "AB_BANKINFO_SERVICE", free_function = "AB_BankInfoService_free")]
    [Compact]
    public class BankInfoService {
        [CCode (cname = "AB_BankInfoService_new")]
        public BankInfoService ();

        [CCode (cname = "AB_BankInfoService_dup")]
        public BankInfoService dup ();

        [CCode (cname = "AB_BankInfoService_List_Next")]
        public BankInfoService next ();
 
        public string type {
            [CCode (cname = "AB_BankInfoService_GetType")] get;
            [CCode (cname = "AB_BankInfoService_SetType")] set;
        }
 
        public string address {
            [CCode (cname = "AB_BankInfoService_GetAddress")] get;
            [CCode (cname = "AB_BankInfoService_SetAddress")] set;
        }
 
        public string suffix {
            [CCode (cname = "AB_BankInfoService_GetSuffix")] get;
            [CCode (cname = "AB_BankInfoService_SetSuffix")] set;
        }
 
        public string p_version {
            [CCode (cname = "AB_BankInfoService_GetPversion")] get;
            [CCode (cname = "AB_BankInfoService_SetPversion")] set;
        }
 
        public string mode {
            [CCode (cname = "AB_BankInfoService_GetMode")] get;
            [CCode (cname = "AB_BankInfoService_SetMode")] set;
        }
 
        public uint32 user_flags {
            [CCode (cname = "AB_BankInfoService_GetUserFlags")] get;
            [CCode (cname = "AB_BankInfoService_SetUserFlags")] set;
        }
 
        public string h_version {
            [CCode (cname = "AB_BankInfoService_GetHversion")] get;
            [CCode (cname = "AB_BankInfoService_SetHversion")] set;
        }
 
        public string aux1 {
            [CCode (cname = "AB_BankInfoService_GetAux1")] get;
            [CCode (cname = "AB_BankInfoService_SetAux1")] set;
        }
 
        public string aux2 {
            [CCode (cname = "AB_BankInfoService_GetAux2")] get;
            [CCode (cname = "AB_BankInfoService_SetAux2")] set;
        }
 
        public string aux3 {
            [CCode (cname = "AB_BankInfoService_GetAux3")] get;
            [CCode (cname = "AB_BankInfoService_SetAux3")] set;
        }
 
        public string aux4 {
            [CCode (cname = "AB_BankInfoService_GetAux4")] get;
            [CCode (cname = "AB_BankInfoService_SetAux4")] set;
        }
   }

    [CCode (cname = "AB_BANKINFO_SERVICE_LIST", free_function = "AB_BankInfoService_List_free")]
    [Compact]
    public class BankInfoServiceList {
        [CCode (cname = "AB_BankInfoService_List_new")]
        public BankInfoServiceList ();

        [CCode (cname = "AB_BankInfoService_List_dup")]
        public BankInfoServiceList dup ();

        [CCode (cname = "AB_BankInfoService_List_First")]
        public BankInfoService first ();

        [CCode (cname = "AB_BankInfoService_List_Next")]
        public static BankInfoService next (BankInfoService bank_info_service);
    }

    [CCode (cname = "AB_BANKINFO_LIST2_ITERATOR", free_function = "AB_BankInfo_List2Iterator_free")]
    [Compact]
    public class BankInfoListIterator {
        [CCode (cname = "AB_BankInfo_List2Iterator_new")]
        public BankInfoListIterator ();

        [CCode (cname = "AB_BankInfo_List2Iterator_Next")]
        public unowned BankInfo next ();

        [CCode (cname = "AB_BankInfo_List2Iterator_Data")]
        public unowned BankInfo data ();
    }

    [CCode (cname = "AB_BANKINFO_LIST2", free_function = "AB_BankInfo_List2_free")]
    [Compact]
    public class BankInfoList {
        [CCode (cname = "AB_BankInfo_List2_new")]
        public BankInfoList ();

        [CCode (cname = "AB_BankInfo_List2_First")]
        public BankInfoListIterator first ();
    }

    [CCode (cname = "AB_BANKINFO", free_function = "AB_BankInfo_free")]
    [Compact]
    public class BankInfo {
        [CCode (cname = "AB_BankInfo_new")]
        public BankInfo ();

        [CCode (cname = "AB_BankInfo_dup")]
        public BankInfo dup ();

        [CCode (cname = "AB_BankInfo_GetServices")]
        public unowned BankInfoServiceList get_services ();
 
        public string bank_id {
            [CCode (cname = "AB_BankInfo_GetBankId")] get;
            [CCode (cname = "AB_BankInfo_SetBankId")] set;
        }
 
        public string bank_name {
            [CCode (cname = "AB_BankInfo_GetBankName")] get;
            [CCode (cname = "AB_BankInfo_SetBankName")] set;
        }
 
        public string bic {
            [CCode (cname = "AB_BankInfo_GetBic")] get;
            [CCode (cname = "AB_BankInfo_SetBic")] set;
        }
 
        public string branch_id {
            [CCode (cname = "AB_BankInfo_GetBranchId")] get;
            [CCode (cname = "AB_BankInfo_SetBranchId")] set;
        }
 
        public string city {
            [CCode (cname = "AB_BankInfo_GetCity")] get;
            [CCode (cname = "AB_BankInfo_SetCity")] set;
        }
 
        public string country {
            [CCode (cname = "AB_BankInfo_GetCountry")] get;
            [CCode (cname = "AB_BankInfo_SetCountry")] set;
        }
 
        public string email {
            [CCode (cname = "AB_BankInfo_GetEmail")] get;
            [CCode (cname = "AB_BankInfo_SetEmail")] set;
        }
 
        public string fax {
            [CCode (cname = "AB_BankInfo_GetFax")] get;
            [CCode (cname = "AB_BankInfo_SetFax")] set;
        }
 
        public string location {
            [CCode (cname = "AB_BankInfo_GetLocation")] get;
            [CCode (cname = "AB_BankInfo_SetLocation")] set;
        }
 
        public string phone {
            [CCode (cname = "AB_BankInfo_GetPhone")] get;
            [CCode (cname = "AB_BankInfo_SetPhone")] set;
        }
 
        public string region {
            [CCode (cname = "AB_BankInfo_GetRegion")] get;
            [CCode (cname = "AB_BankInfo_SetRegion")] set;
        }
 
        public string street {
            [CCode (cname = "AB_BankInfo_GetStreet")] get;
            [CCode (cname = "AB_BankInfo_SetStreet")] set;
        }
 
        public string website {
            [CCode (cname = "AB_BankInfo_GetWebsite")] get;
            [CCode (cname = "AB_BankInfo_SetWebsite")] set;
        }
 
        public string zipcode {
            [CCode (cname = "AB_BankInfo_GetZipcode")] get;
            [CCode (cname = "AB_BankInfo_SetZipcode")] set;
        }
    }

    [CCode (cname = "AB_BANKING", free_function = "AB_Banking_free")]
    [Compact]
    public class Banking {
        [CCode (cname = "AB_Banking_new")]
        public Banking (string application_name, string? directory_name, int extensions);

        [CCode (cname = "AB_Banking_Init")]
        public int init ();

        [CCode (cname = "AB_Banking_OnlineInit")]
        public int online_init ();

        [CCode (cname = "AB_Banking_OnlineFini")]
        public int online_finish ();

        [CCode (cname = "AB_Banking_Fini")]
        public int finish ();

        [CCode (cname = "AB_Banking_GetVersion")]
        public static int get_version (out int major, out int minor, out int patchlevel, out int build);

        [CCode (cname = "AB_Banking_GetAccounts")]
        public AccountList get_accounts ();

        [CCode (cname = "AB_Banking_CreateUser")]
        public unowned User create_user (string backend_name);

        [CCode (cname = "AB_Banking_CreateAccount")]
        public unowned Account create_account (string backend_name);

        [CCode (cname = "AB_Banking_AddUser")]
        public int add_user (User user);

        [CCode (cname = "AB_Banking_GetUser")]
        public unowned User get_user (int unique_id);

        [CCode (cname = "AB_Banking_FindUser")]
        public unowned User find_user ( string backendName, string country, string bankId, string userId, string stringcustomerId );

        [CCode (cname = "AB_Banking_DeleteUser")]
        public int delete_user (User user);

        [CCode (cname = "AB_Banking_AddAccount")]
        public int add_account (Account account);

        [CCode (cname = "AB_Banking_GetAccount")]
        public unowned Account get_account (int unique_id);

        [CCode (cname = "AB_Banking_DeleteAccount")]
        public int delete_account (Account account);

        [CCode (cname = "AH_Provider_new")]
        public unowned Provider get_provider (string name);

        [CCode (cname = "AB_Banking_ExecuteJobs")]
        public int execute_jobs (JobList joblist, ImExporterContext context);

        [CCode (cname = "AB_Banking_GetBankInfo")]
        public BankInfo get_bank_info (string country, string branch_id, string bank_id);

        [CCode (cname = "AB_Banking_GetBankInfoByTemplate")]
        public int get_bank_info_by_template (string country, BankInfo bank_info_template, BankInfoList list);
    }

    [CCode (cname = "AB_ACCOUNT_TYPE", cprefix = "AB_AccountType_", has_type_id = false)]
    public enum AccountType {
        Unkonwn,
        Bank,
        CreditCard,
        Checking,
        Savings,
        Investment,
        Cash,
        MoneyMarket
    }

    [CCode (cname = "AB_ACCOUNT", free_function = "AB_Account_free")]
    [Compact]
    public class Account {

        [CCode (cname = "AB_Account_GetBanking")]
        public Banking get_banking ();

        public AccountType account_type {
            [CCode (cname = "AB_Account_GetAccountType")] get;
            [CCode (cname = "AB_Account_SetAccountType")] set;
        }

        public int unique_id {
            [CCode (cname = "AB_Account_GetUniqueId")] get;
            [CCode (cname = "AB_Account_GetUniqueId")] set;
        }

        public string backend_name {
            [CCode (cname = "AB_Account_GetBackendName")] get;
        }

        public string account_number {
            [CCode (cname = "AB_Account_GetAccountNumber")] get;
            [CCode (cname = "AB_Account_SetAccountNumber")] set;
        }

        public string sub_account_id {
            [CCode (cname = "AB_Account_GetSubAccountId")] get;
            [CCode (cname = "AB_Account_SetSubAccountId")] set;
        }

        public string bank_code {
            [CCode (cname = "AB_Account_GetBankCode")] get;
            [CCode (cname = "AB_Account_SetBankCode")] set;
        }

        public string bank_name {
            [CCode (cname = "AB_Account_GetBankName")] get;
            [CCode (cname = "AB_Account_SetBankName")] set;
        }

        public string iban {
            [CCode (cname = "AB_Account_GetIBAN ")] get;
            [CCode (cname = "AB_Account_SetIBAN ")] set;
        }

        public string bic {
            [CCode (cname = "AB_Account_GetBIC")] get;
            [CCode (cname = "AB_Account_GetBIC")] set;
        }

        public string owner_name {
            [CCode (cname = "AB_Account_GetOwnerName")] get;
            [CCode (cname = "AB_Account_SetOwnerName")] set;
        }

        public string currency {
            [CCode (cname = "AB_Account_GetCurrency")] get;
            [CCode (cname = "AB_Account_SetCurrency")] set;
        }

        public string country {
            [CCode (cname = "AB_Account_GetCountry")] get;
            [CCode (cname = "AB_Account_SetCountry")] set;
        }

        [CCode (cname = "AB_Account_SetUser")]
        public void set_user (User user);

        [CCode (cname = "AB_Account_SetSelectedUser")]
        public void set_selected_user (User user);

        [CCode (cname = "AB_Account_GetFirstSelectedUser")]
        public User get_first_selected_user ();
    }


    [CCode (cname = "AB_JOB_LIST2", free_function = "AB_Job_List2_free")]
    [Compact]
    public class JobList {

        [CCode (cname = "AB_Job_List2_new")]
        public JobList ();

        [CCode (cname = "AB_Job_List2_PushBack")]
        public void push_back (Job job);

        [CCode (cname = "AB_Job_List2_ClearAll")]
        public void clear_all ();
    }


    [CCode (cname = "AB_JOB", free_function = "AB_Job_free")]
    [Compact]
    public class Job {

        [CCode (cname = "AB_Job_CheckAvailability")]
        public int check_availability ();

        /* JobGetTransactions */

        [CCode (cname = "AB_JobGetTransactions_new")]
        public static Job new_get_transactions (Account account);

        //public int from_time {
        //    [CCode (cname = "AB_JobGetTransactions_GetFromTime")] get;
        //    [CCode (cname = "AB_JobGetTransactions_SetFromTime")] set;
        //}

        //public int to_time {
        //    [CCode (cname = "AB_JobGetTransactions_GetToTime")] get;
        //    [CCode (cname = "AB_JobGetTransactions_SetToTime")] set;
        //}

        [CCode (cname = "AB_JobGetTransactions_GetMaxStoreDays")]
        public int get_max_store_days ();

        /* JobGetBalance */

        [CCode (cname = "AB_JobGetBalance_new")]
        public static Job new_get_balance ();

    }

    [CCode (cname = "AB_JOB", free_function = "AB_Value_free")]
    [Compact]
    public class Value {

        [CCode (cname = "AB_Value_new")]
        public Value ();

        [CCode (cname = "AB_Value_dup")]
        public Value dup ();

        [CCode (cname = "AB_Value_GetValueAsDouble")]
        public double get_value_as_double ();

        [CCode (cname = "AB_Value_GetCurrency")]
        public unowned string get_currency ();
    }


    [CCode (cname = "AB_TRANSACTION", ref_function = "AB_Transaction_Attach", unref_function = "AB_Transaction_free")]
    [Compact]
    public class Transaction {

        public Value value {
            [CCode (cname = "AB_Transaction_GetValue")] get;
            [CCode (cname = "AB_Transaction_SetValue")] set;
        }

        public Gwenhywfar.StringList purpose {
            [CCode (cname = "AB_Transaction_GetPurpose")] get;
            [CCode (cname = "AB_Transaction_SetPurpose")] set;
        }
        public Gwenhywfar.Time date {
            [CCode (cname = "AB_Transaction_GetDate")] get;
            [CCode (cname = "AB_Transaction_SetDate")] set;
        }

        public Gwenhywfar.Time valuta_date {
            [CCode (cname = "AB_Transaction_GetValutaDate")] get;
            [CCode (cname = "AB_Transaction_SetValutaDate ")] set;
        }

        public Value fees {
            [CCode (cname = "AB_Transaction_GetFees")] get;
            [CCode (cname = "AB_Transaction_SetFees")] set;
        }

        public string remote_country {
            [CCode (cname = "AB_Transaction_GetRemoteCountry")] get;
            [CCode (cname = "AB_Transaction_SetRemoteCountry")] set;
        }

        public string remote_bank_name {
            [CCode (cname = "AB_Transaction_GetRemoteBankName")] get;
            [CCode (cname = "AB_Transaction_SetRemoteBankName")] set;
        }

        public string remote_bank_location {
            [CCode (cname = "AB_Transaction_GetRemoteBankLocation")] get;
            [CCode (cname = "AB_Transaction_SetRemoteBankLocation")] set;
        }

        public string remote_bank_code {
            [CCode (cname = "AB_Transaction_GetRemoteBankCode")] get;
            [CCode (cname = "AB_Transaction_GetRemoteBankCode")] set;
        }

        public string remote_account_number {
            [CCode (cname = "AB_Transaction_GetRemoteAccountNumber")] get;
            [CCode (cname = "AB_Transaction_SetRemoteAccountNumber")] set;
        }

        public Gwenhywfar.StringList remote_name {
            [CCode (cname = "AB_Transaction_GetRemoteName")] get;
            [CCode (cname = "AB_Transaction_SetRemoteName")] set;
        }

        public string remote_bic {
            [CCode (cname = "AB_Transaction_GetRemoteBic")] get;
            [CCode (cname = "AB_Transaction_SetRemoteBic")] set;
        }

    }


    [CCode (cname = "AB_IMEXPORTER_ACCOUNTINFO", free_function = "AB_ImExporterAccountInfo_free")]
    [Compact]
    public class AccountInfo {

        [CCode (cname = "AB_ImExporterAccountInfo_new")]
        public AccountInfo ();

        [CCode (cname = "AB_ImExporterAccountInfo_dup")]
        public AccountInfo dup ();

        public string bank_code {
            [CCode (cname = "AB_ImExporterAccountInfo_getBankCode")] get;
            [CCode (cname = "AB_ImExporterAccountInfo_setBankCode")] set;
        }

        public string bank_name {
            [CCode (cname = "AB_ImExporterAccountInfo_getBankName")] get;
            [CCode (cname = "AB_ImExporterAccountInfo_setBankName")] set;
        }

        [CCode (cname = "AB_ImExporterAccountInfo_GetFirstTransaction")]
        public unowned Transaction? get_first_transaction ();

        [CCode (cname = "AB_ImExporterAccountInfo_GetNextTransaction")]
        public unowned Transaction? get_next_transaction ();
    }

    [CCode (cname = "AB_IMEXPORTER_CONTEXT", free_function = "AB_ImExporterContext_free")]
    [Compact]
    public class ImExporterContext {

        [CCode (cname = "AB_ImExporterContext_new ")]
        public ImExporterContext ();

        [CCode (cname = "AB_ImExporterContext_GetFirstAccountInfo")]
        public unowned AccountInfo? get_first_account_info ();

        [CCode (cname = "AB_ImExporterContext_GetNextAccountInfo")]
        public unowned AccountInfo? get_next_account_info ();

    }

    [CCode (cname = "AB_PROVIDER", free_function = "AH_Provider_free")]
    [Compact]
    public class Provider {

        [CCode (cname = "AH_Provider_CreateKeys")]
        public int create_keys (User user, bool no_unmount);


        [CCode (cname = "AH_Provider_GetAccounts")]
        public int get_accounts (User user, ImExporterContext context, bool withProgress, bool no_unmount, bool do_lock);

        [CCode (cname = "AH_Provider_GetSysId")]
        public int get_sys_id (User user, ImExporterContext context, bool withProgress, bool no_unmount, bool do_lock);

        [CCode (cname = "AH_Provider_GetServerKeys")]
        public int get_server_keys (User user, ImExporterContext context, bool withProgress, bool no_unmount, bool do_lock);

        [CCode (cname = "AH_Provider_GetCert")]
        public int get_cert (User user, ImExporterContext context, bool withProgress, bool no_unmount, bool do_lock);

        [CCode (cname = "AH_Provider_SendUserKeys")]
        public int send_user_keys (User user, ImExporterContext context, bool withProgress, bool no_unmount, bool do_lock);

        [CCode (cname = "AH_Provider_SendUserKeys2")]
        public int send_user_keys2 (User user, ImExporterContext context, bool withProgress, bool no_unmount, bool do_lock);
    }
    [CCode (cname = "AB_Gui_Extend")]
    public void gui_extend (Gwenhywfar.Gui gui, Banking banking);

}
