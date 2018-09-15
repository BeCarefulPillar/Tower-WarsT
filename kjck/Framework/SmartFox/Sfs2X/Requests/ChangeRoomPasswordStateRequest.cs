namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class ChangeRoomPasswordStateRequest : BaseRequest
    {
        public static readonly string KEY_PASS = "p";
        public static readonly string KEY_ROOM = "r";
        private string newPass;
        private Room room;

        public ChangeRoomPasswordStateRequest(Room room, string newPass) : base(RequestType.ChangeRoomPassword)
        {
            this.room = room;
            this.newPass = newPass;
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutInt(KEY_ROOM, this.room.Id);
            base.sfso.PutUtfString(KEY_PASS, this.newPass);
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (this.room == null)
            {
                errors.Add("Provided room is null");
            }
            if (this.newPass == null)
            {
                errors.Add("Invalid new room password. It must be a non-null string.");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("ChangePassState request error", errors);
            }
        }
    }
}

