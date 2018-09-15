namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class ChangeRoomNameRequest : BaseRequest
    {
        public static readonly string KEY_NAME = "n";
        public static readonly string KEY_ROOM = "r";
        private string newName;
        private Room room;

        public ChangeRoomNameRequest(Room room, string newName) : base(RequestType.ChangeRoomName)
        {
            this.room = room;
            this.newName = newName;
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutInt(KEY_ROOM, this.room.Id);
            base.sfso.PutUtfString(KEY_NAME, this.newName);
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (this.room == null)
            {
                errors.Add("Provided room is null");
            }
            if ((this.newName == null) || (this.newName.Length == 0))
            {
                errors.Add("Invalid new room name. It must be a non-null and non-empty string.");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("ChangeRoomName request error", errors);
            }
        }
    }
}

