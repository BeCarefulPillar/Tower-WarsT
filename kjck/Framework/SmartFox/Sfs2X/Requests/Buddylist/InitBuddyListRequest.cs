namespace Sfs2X.Requests.Buddylist
{
    using Sfs2X;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class InitBuddyListRequest : BaseRequest
    {
        public static readonly string KEY_BLIST = "bl";
        public static readonly string KEY_BUDDY_STATES = "bs";
        public static readonly string KEY_MY_VARS = "mv";

        public InitBuddyListRequest() : base(RequestType.InitBuddyList)
        {
        }

        public override void Execute(SmartFox sfs)
        {
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (sfs.BuddyManager.Inited)
            {
                errors.Add("Buddy List is already initialized.");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("InitBuddyRequest error", errors);
            }
        }
    }
}

