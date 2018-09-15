namespace Sfs2X.Requests.Buddylist
{
    using Sfs2X;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class RemoveBuddyRequest : BaseRequest
    {
        public static readonly string KEY_BUDDY_NAME = "bn";
        private string name;

        public RemoveBuddyRequest(string buddyName) : base(RequestType.RemoveBuddy)
        {
            this.name = buddyName;
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutUtfString(KEY_BUDDY_NAME, this.name);
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (!sfs.BuddyManager.Inited)
            {
                errors.Add("BuddyList is not inited. Please send an InitBuddyRequest first.");
            }
            if (!sfs.BuddyManager.MyOnlineState)
            {
                errors.Add("Can't remove buddy while off-line");
            }
            if (!sfs.BuddyManager.ContainsBuddy(this.name))
            {
                errors.Add("Can't remove buddy, it's not in your list: " + this.name);
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("BuddyList request error", errors);
            }
        }
    }
}

