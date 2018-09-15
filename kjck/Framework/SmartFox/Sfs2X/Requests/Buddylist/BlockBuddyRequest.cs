namespace Sfs2X.Requests.Buddylist
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class BlockBuddyRequest : BaseRequest
    {
        private bool blocked;
        private string buddyName;
        public static readonly string KEY_BUDDY_BLOCK_STATE = "bs";
        public static readonly string KEY_BUDDY_NAME = "bn";

        public BlockBuddyRequest(string buddyName, bool blocked) : base(RequestType.BlockBuddy)
        {
            this.buddyName = buddyName;
            this.blocked = blocked;
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutUtfString(KEY_BUDDY_NAME, this.buddyName);
            base.sfso.PutBool(KEY_BUDDY_BLOCK_STATE, this.blocked);
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (!sfs.BuddyManager.Inited)
            {
                errors.Add("BuddyList is not inited. Please send an InitBuddyRequest first.");
            }
            if ((this.buddyName == null) || (this.buddyName.Length < 1))
            {
                errors.Add("Invalid buddy name: " + this.buddyName);
            }
            if (!sfs.BuddyManager.MyOnlineState)
            {
                errors.Add("Can't block buddy while off-line");
            }
            Buddy buddyByName = sfs.BuddyManager.GetBuddyByName(this.buddyName);
            if (buddyByName == null)
            {
                errors.Add("Can't block buddy, it's not in your list: " + this.buddyName);
            }
            else if (buddyByName.IsBlocked == this.blocked)
            {
                errors.Add(string.Concat(new object[] { "BuddyBlock flag is already in the requested state: ", this.blocked, ", for buddy: ", buddyByName }));
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("BuddyList request error", errors);
            }
        }
    }
}

