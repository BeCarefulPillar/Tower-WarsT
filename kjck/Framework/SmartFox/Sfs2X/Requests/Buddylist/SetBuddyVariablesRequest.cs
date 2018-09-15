namespace Sfs2X.Requests.Buddylist
{
    using Sfs2X;
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Variables;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class SetBuddyVariablesRequest : BaseRequest
    {
        private List<BuddyVariable> buddyVariables;
        public static readonly string KEY_BUDDY_NAME = "bn";
        public static readonly string KEY_BUDDY_VARS = "bv";

        public SetBuddyVariablesRequest(List<BuddyVariable> buddyVariables) : base(RequestType.SetBuddyVariables)
        {
            this.buddyVariables = buddyVariables;
        }

        public override void Execute(SmartFox sfs)
        {
            ISFSArray val = SFSArray.NewInstance();
            foreach (BuddyVariable variable in this.buddyVariables)
            {
                val.AddSFSArray(variable.ToSFSArray());
            }
            base.sfso.PutSFSArray(KEY_BUDDY_VARS, val);
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
                errors.Add("Can't set buddy variables while off-line");
            }
            if ((this.buddyVariables == null) || (this.buddyVariables.Count == 0))
            {
                errors.Add("No variables were specified");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("SetBuddyVariables request error", errors);
            }
        }
    }
}

