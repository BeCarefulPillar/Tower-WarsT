namespace Sfs2X.Requests.Buddylist
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class AddBuddyRequest : BaseRequest
    {
        public static readonly string KEY_BUDDY_NAME = "bn";
        private string name;

        public AddBuddyRequest(string buddyName) : base(RequestType.AddBuddy)
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
            if ((this.name == null) || (this.name.Length < 1))
            {
                errors.Add("Invalid buddy name: " + this.name);
            }
            if (!sfs.BuddyManager.MyOnlineState)
            {
                errors.Add("Can't add buddy while off-line");
            }
            Buddy buddyByName = sfs.BuddyManager.GetBuddyByName(this.name);
            if (!((buddyByName == null) || buddyByName.IsTemp))
            {
                errors.Add("Can't add buddy, it is already in your list: " + this.name);
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("BuddyList request error", errors);
            }
        }
    }
}

