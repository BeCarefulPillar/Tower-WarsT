namespace Sfs2X.Logging
{
    using Sfs2X;
    using Sfs2X.Core;
    using System;
    using System.Collections;

    public class Logger
    {
        private bool enableConsoleTrace = true;
        private bool enableEventDispatching = true;
        private Sfs2X.Logging.LogLevel loggingLevel;
        private SmartFox smartFox;

        public Logger(SmartFox smartFox)
        {
            this.smartFox = smartFox;
            this.loggingLevel = Sfs2X.Logging.LogLevel.INFO;
        }

        public void AddEventListener(Sfs2X.Logging.LogLevel level, EventListenerDelegate listener)
        {
            if (this.smartFox != null)
            {
                this.smartFox.AddEventListener(LoggerEvent.LogEventType(level), listener);
            }
        }

        public void Debug(params string[] messages)
        {
            this.Log(Sfs2X.Logging.LogLevel.DEBUG, string.Join(" ", messages));
        }

        public void Error(params string[] messages)
        {
            this.Log(Sfs2X.Logging.LogLevel.ERROR, string.Join(" ", messages));
        }

        public void Info(params string[] messages)
        {
            this.Log(Sfs2X.Logging.LogLevel.INFO, string.Join(" ", messages));
        }

        private void Log(Sfs2X.Logging.LogLevel level, string message)
        {
            if (level >= this.loggingLevel)
            {
                if (this.enableConsoleTrace)
                {
                    Console.WriteLine(string.Concat(new object[] { "[SFS - ", level, "] ", message }));
                }
                if (this.enableEventDispatching && (this.smartFox != null))
                {
                    Hashtable parameters = new Hashtable();
                    parameters.Add("message", message);
                    LoggerEvent evt = new LoggerEvent(level, parameters);
                    this.smartFox.DispatchEvent(evt);
                }
            }
        }

        public void RemoveEventListener(Sfs2X.Logging.LogLevel logLevel, EventListenerDelegate listener)
        {
            if (this.smartFox != null)
            {
                this.smartFox.RemoveEventListener(LoggerEvent.LogEventType(logLevel), listener);
            }
        }

        public void Warn(params string[] messages)
        {
            this.Log(Sfs2X.Logging.LogLevel.WARN, string.Join(" ", messages));
        }

        public bool EnableConsoleTrace
        {
            get
            {
                return this.enableConsoleTrace;
            }
            set
            {
                this.enableConsoleTrace = value;
            }
        }

        public bool EnableEventDispatching
        {
            get
            {
                return this.enableEventDispatching;
            }
            set
            {
                this.enableEventDispatching = value;
            }
        }

        public Sfs2X.Logging.LogLevel LoggingLevel
        {
            get
            {
                return this.loggingLevel;
            }
            set
            {
                this.loggingLevel = value;
            }
        }
    }
}

