using System;

namespace Kiol.Util
{
    public static class KLogger
    {
        public static void Log(object message)
        {
#if JOY_TOOL
            System.Diagnostics.Debug.WriteLine(message);
#else
            UnityEngine.Debug.Log(message);
#endif
        }

        public static void LogWarning(object message)
        {
#if JOY_TOOL
            System.Diagnostics.Debug.WriteLine(message, "Warning");
#else
            UnityEngine.Debug.LogWarning(message);
#endif
        }

        public static void LogError(object message)
        {
#if JOY_TOOL
            System.Diagnostics.Debug.WriteLine(message, "Error");
#else
            UnityEngine.Debug.LogError(message);
#endif
        }

        public static void LogException(Exception exception)
        {
#if JOY_TOOL
            System.Diagnostics.Debug.WriteLine(exception, "Exception");
#else
            UnityEngine.Debug.LogException(exception);
#endif
        }
    }
}