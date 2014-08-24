[CCode (cheader_filename = "gwenhywfar4/gwenhywfar/gwenhywfar.h,gwenhywfar4/gwenhywfar/url.h")]

namespace Gwenhywfar {

    [CCode (cname = "GWEN_GUI", ref_function = "GWEN_Gui_Attach", unref_function = "GWEN_Gui_free")]
    [Compact]
    public class Gui {

        [CCode (cname = "GWEN_Gui_CGui_new")]
        public static Gui new_cgui ();

        [CCode (cname = "int", cprefix = "GWEN_GUI_FLAGS_", has_type_id = false)]
        [Flags]
        public enum GuiFlags {
            NONINTERACTIVE,
            ACCEPTVALIDCERTS,
            REJECTINVALIDCERTS,
            PERMPASSWORDS,
            DIALOGSUPPORTED
        }

        [CCode (cname = "GWEN_GUI_PASSWORD_STATUS", cprefix = "GWEN_Gui_PasswordStatus_", has_type_id = false)]
        public enum PasswordStatus {
            Bad,
            Unkown,
            Ok,
            Used,
            Unused,
            Remove
        }

        [CCode (cname = "GWEN_GUI_GETPASSWORD_FN", has_target = false, has_type_id = false)]
        public delegate int GetPasswordFn (Gui gui, int flags, string token, string title, string text, string buffer, int min_len, int max_len, int32 guiid);

        [CCode (cname = "GWEN_GUI_SETPASSWORDSTATUS_FN", has_target = false, has_type_id = false)]
        public delegate int SetPasswordStatusFn (Gui gui, string token, string pin, PasswordStatus status, int32 guiid);

        [CCode (cname = "GWEN_GUI_CHECKCERT_FN", has_target = false, has_type_id = false)]
        public delegate int CheckCertFn (Gui gui, SSLCertDescription cert, SyncIO sio, int32 guiid);

        [CCode (cname = "GWEN_GUI_PROGRESS_LOG_FN", has_target = false, has_type_id = false)]
        public delegate int ProgressLogFn (Gui gui, int id, LoggerLevel level, string text);

        [CCode (cname = "GWEN_GUI_PROGRESS_START_FN", has_target = false, has_type_id = false)]
        public delegate int ProgressStartFn (Gui gui, int progressFlags, string title, string text, uint64 total, uint32 guiid);

        [CCode (cname = "GWEN_GUI_PROGRESS_ADVANCE_FN", has_target = false, has_type_id = false)]
        public delegate int ProgressAdvanceFn (Gui gui, uint32 id, uint64 progress);

        [CCode (cname = "GWEN_GUI_PROGRESS_SETTOTAL_FN", has_target = false, has_type_id = false)]
        public delegate int ProgressSetTotalFn (Gui gui, uint32 id, uint64 total);

        [CCode (cname = "GWEN_GUI_WAITFORSOCKETS_FN", has_target = false, has_type_id = false)]
        public delegate int WaitForSocketsFn (Gui gui, SocketList readSockets, SocketList writeSockets, int msecs, uint32 guiid);

        [CCode (cname = "GWEN_Gui_SetGui")]
        public static void setGui (Gui gui);

        [CCode (cname = "GWEN_Gui_GetFlags")]
        public GuiFlags get_flags ();

        [CCode (cname = "GWEN_Gui_AddFlags")]
        public void add_flags (GuiFlags flags);

        [CCode (cname = "GWEN_Gui_SetGetPasswordFn")]
        public GetPasswordFn set_get_password_function (GetPasswordFn func);

        [CCode (cname = "GWEN_Gui_SetSetPasswordStatusFn")]
        public SetPasswordStatusFn set_set_password_status_function (SetPasswordStatusFn func);

        [CCode (cname = "GWEN_Gui_SetCheckCertFn")]
        public CheckCertFn set_check_cert_function (CheckCertFn func);

        [CCode (cname = "GWEN_Gui_SetProgressLogFn")]
        public ProgressLogFn set_progress_log_function (ProgressLogFn func);

        [CCode (cname = "GWEN_Gui_SetProgressStartFn")]
        public ProgressStartFn set_progress_start_function (ProgressStartFn func);

        [CCode (cname = "GWEN_Gui_SetProgressAdvanceFn")]
        public ProgressAdvanceFn set_progress_advance_function (ProgressAdvanceFn func);

        [CCode (cname = "GWEN_Gui_SetProgressSetTotalFn")]
        public ProgressSetTotalFn set_progress_set_total_function (ProgressSetTotalFn func);

        [CCode (cname = "GWEN_Gui_SetWaitForSocketsFn")]
        public WaitForSocketsFn set_wait_for_sockets_function (WaitForSocketsFn func);
    }

    [CCode (cname = "GWEN_SSLCERTDESCR", free_function = "GWEN_SslCertDescr_free")]
    [Compact]
    public class SSLCertDescription {

        [CCode (cname = "GWEN_SslCertDescr_dup")]
        public SSLCertDescription dup ();
    }

    [CCode (cname = "GWEN_SYNCIO", free_function = "GWEN_SyncIo_free")]
    [Compact]
    public class SyncIO {

    }

    [CCode (cname = "GWEN_STRINGLISTENTRY", free_function = "GWEN_StringListEntry_free")]
    [Compact]
    public class StringListEntry {

        [CCode (cname = "GWEN_StringListEntry_new")]
        public StringListEntry ( string s, int take);

        public string data {
            [CCode (cname = "GWEN_StringListEntry_Data")] get;
            [CCode (cname = "GWEN_StringListEntry_SetData")] set;
        }

        [CCode (cname = "GWEN_StringListEntry_Next ")]
        public unowned StringListEntry next ();

    }

    [CCode (cname = "GWEN_STRINGLIST", free_function = "GWEN_StringList_free")]
    [Compact]
    public class StringList {

        [CCode (cname = "GWEN_StringList_new")]
        public StringList ();

        [CCode (cname = "GWEN_StringList_dup")]
        public StringList dup ();

        [CCode (cname = "GWEN_StringList_FirstString")]
        public unowned string first_string ();

        [CCode (cname = "GWEN_StringList_StringAt")]
        public unowned string string_at (int idx);

        [CCode (cname = "GWEN_StringList_FirstEntry")]
        public unowned StringListEntry first_entry ();

        //[CCode (cname = "GWEN_StringList_ForEach")]
        //public unowned void for_each (func, user_data);
    }

    [CCode (cname = "GWEN_URL", ref_function="GWEN_Url_Attach", unref_function = "GWEN_Url_free")]
    [Compact]
    public class Url {

        [CCode (cname = "GWEN_Url_new")]
        public Url ();

        [CCode (cname = "GWEN_Url_dup")]
        public Url dup ();

        public string path {
            [CCode (cname = "GWEN_Url_GetPath")] get;
            [CCode (cname = "GWEN_Url_SetPath")] set;
        }

        public string protocol {
            [CCode (cname = "GWEN_Url_GetProtocol")] get;
            [CCode (cname = "GWEN_Url_SetProtocol")] set;
        }

        public string server {
            [CCode (cname = "GWEN_Url_GetServer")] get;
            [CCode (cname = "GWEN_Url_SetServer")] set;
        }
    }

    [CCode (cname = "GWEN_Url_fromString")]
    public Url url_from_string(string url);


    [CCode (cname = "GWEN_LOGGER_LEVEL", cprefix = "GWEN_LoggerLevel_", has_type_id = false)]
    public enum LoggerLevel {
        Emergency,
        Alert,
        Critical,
        Error,
        Warning,
        Notice,
        Info,
        Debug,
        Verbous,
        Unknown
    }

    [CCode (cname = "GWEN_Logger_SetLevel")]
    public void Logger_set_level (string logDomain, LoggerLevel level);

    [CCode (cname = "GWEN_Init")]
    public int init ();

    [CCode (cname = "GWEN_Fini")]
    public int finish ();

    [CCode (cname = "GWEN_PathManager_GetPaths")]
    public unowned StringList getpaths (string dest_lib, string name);

    [CCode (cname = "GWEN_TIME", free_function = "GWEN_Time_free ")]
    [Compact]
    public class Time {

        [CCode (cname = "GWEN_Time_new")]
        public Time (int year, int month, int day, int hour, int min, int sec, int inUtc);

        [CCode (cname = "GWEN_Time_dup")]
        public Time dup ();

        [CCode (cname = "GWEN_Time_Seconds")]
        public uint32 seconds ();

        [CCode (cname = "GWEN_Time_SubSeconds")]
        public int subseconds ();

        [CCode (cname = "GWEN_Time_toTime_t")]
        public time_t to_time_t ();

    }

    [CCode (cname = "GWEN_SOCKET_LIST2", free_function = "GWEN_Socket_List2_free")]
    [Compact]
    public class SocketList {

        [CCode (cname = "GWEN_Socket_List2_dup")]
        public StringList dup ();

        [CCode (cname = "GWEN_StringList_FirstString")]
        public unowned string first_string ();

        [CCode (cname = "GWEN_StringList_StringAt")]
        public unowned string string_at (int idx);

        [CCode (cname = "GWEN_StringList_FirstEntry")]
        public unowned StringListEntry first_entry ();

        //[CCode (cname = "GWEN_StringList_ForEach")]
        //public unowned void for_each (func, user_data);
    }
}
