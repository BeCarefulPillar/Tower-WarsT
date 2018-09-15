namespace Sfs2X.Requests.Buddylist
{
    using Sfs2X;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class GoOnlineRequest : BaseRequest
    {
        public static readonly string KEY_BUDDY_ID = "bi";
        public static readonly string KEY_BUDDY_NAME = "bn";
        public static readonly string KEY_ONLINE = "o";
        private bool online;

        public GoOnlineRequest(bool online) : base(RequestType.GoOnline)
        {
            this.online = online;
        }

        public override void Execute(SmartFox sfs)
        {
            sfs.BuddyManager.MyOnlineState = this.online;
            base.sfso.PutBool(KEY_ONLINE, this.online);
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (!sfs.BuddyManager.Inited)
            {
                errors.Add("BuddyList is not inited. Please send an InitBuddyRequest first.");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("GoOnline request error", errors);
            }
        }
    }
}

