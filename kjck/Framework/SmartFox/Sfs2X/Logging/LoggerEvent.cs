namespace Sfs2X.Logging
{
    using Sfs2X.Core;
    using System;
    using System.Collections;

    public class LoggerEvent : BaseEvent, ICloneable
    {
        private Sfs2X.Logging.LogLevel level;

        public LoggerEvent(Sfs2X.Logging.LogLevel level, Hashtable parameters) : base(LogEventType(level), parameters)
        {
            this.level = level;
        }

        public new object Clone()
        {
            return new LoggerEvent(this.level, base.arguments);
        }

        public static string LogEventType(Sfs2X.Logging.LogLevel level)
        {
            return ("LOG_" + level.ToString());
        }

        public override string ToString()
        {
            return string.Format("LoggerEvent " + base.type, new object[0]);
        }
    }
}

