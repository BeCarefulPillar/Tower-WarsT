namespace Sfs2X.Util
{
    using System;

    public static class ClientDisconnectionReason
    {
        public static readonly string BAN = "ban";
        public static readonly string IDLE = "idle";
        public static readonly string KICK = "kick";
        public static readonly string MANUAL = "manual";
        private static string[] reasons = new string[] { "idle", "kick", "ban" };
        public static readonly string UNKNOWN = "unknown";

        public static string GetReason(int reasonId)
        {
            return reasons[reasonId];
        }
    }
}

