using UnityEngine;
using System;
using System.Text;
using System.Collections.Generic;
using System.Diagnostics;

namespace Logger {

public class Log {
    //public static StringBuilder sync = new StringBuilder(10240);
    public enum Level {
        DEBUG,
        INFO,
        WARN,
        ERROR,
    }

    public static Level filterLevel = Level.INFO;
    public static Queue<string> historyMessages = new Queue<string>();
    public static int maxHistoryMessages = 100;

    [Conditional("JDEBUG")]
    public static void Debug(string msg, params System.Object[] args) {
        Output(Level.DEBUG, msg, args);
    }

    [Conditional("JDEBUG")]
    public static void Info(string msg, params System.Object[] args) {
        Output(Level.INFO, msg, args);
    }

    [Conditional("JDEBUG")]
    public static void Warn(string msg, params System.Object[] args) {
        Output(Level.WARN, msg, args);
    }

    [Conditional("JDEBUG")]
    public static void Error(string msg, params System.Object[] args) {
        Output(Level.ERROR, msg, args);
    }

    [Conditional("JDEBUG")]
    public static void Binary(byte[] buf, int offset, int size) {
        var sb = new StringBuilder();
        sb.Append("[");
        for(int i = 0; i < size; i++) {
            sb.Append(buf[i+offset]);
            sb.Append(",");
        }
        sb.Append("]");
        Info(sb.ToString());
    }

    [Conditional("JDEBUG")]
    public static void Assert(bool condition, string assertString, bool pauseOnFail = false) {
        if (!condition) {
            Error("Assert Failed! {0}", assertString);
#if UNITY_EDITOR
            if (pauseOnFail) {
                UnityEngine.Debug.Break();
            }
#endif
        }
    }

    [Conditional("JDEBUG")]
    private static void Output(Level level, string msg, params System.Object[] args) {
        if(level < filterLevel) return;
        if(args != null && args.Length > 0) {
            msg = string.Format(msg, args);
        }
        msg = string.Format("[{0}]{1}", Prefix(), msg);
        if(historyMessages.Count >= maxHistoryMessages) {
            historyMessages.Dequeue();
        }
        historyMessages.Enqueue(msg);
        switch(level) {
        case Level.INFO:
            UnityEngine.Debug.Log(msg);
            break;
        case Level.WARN:
            UnityEngine.Debug.LogWarning(msg);
            break;
        case Level.ERROR:
            UnityEngine.Debug.LogError(msg);
            break;
        }
    }
		
	private static string Prefix() {
        var now = DateTime.Now;
#if LOG_CODELINE
		var sf = new StackFrame(2, true);
		string filename = sf.GetFileName();
		filename = filename.Substring(filename.LastIndexOf('/') + 1);
		filename = filename.Substring(0, filename.Length - 3);
		return string.Format("{0}(Class:{1} Line:{2})", now.ToString("yyyy-MM-dd HH:mm:ss"), filename, sf.GetFileLineNumber());
#else
		return now.ToString("yyyy-MM-dd HH:mm:ss") + "." + now.Millisecond;
#endif	
	}
}
} // namespace Joywinds