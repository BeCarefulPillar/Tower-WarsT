namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class SubscribeRoomGroupRequest : BaseRequest
    {
        private string groupId;
        public static readonly string KEY_GROUP_ID = "g";
        public static readonly string KEY_ROOM_LIST = "rl";

        public SubscribeRoomGroupRequest(string groupId) : base(RequestType.SubscribeRoomGroup)
        {
            this.groupId = groupId;
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutUtfString(KEY_GROUP_ID, this.groupId);
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if ((this.groupId == null) || (this.groupId.Length == 0))
            {
                errors.Add("Invalid groupId. Must be a string with at least 1 character.");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("SubscribeGroup request Error", errors);
            }
        }
    }
}

