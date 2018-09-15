namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class ChangeRoomCapacityRequest : BaseRequest
    {
        public static readonly string KEY_ROOM = "r";
        public static readonly string KEY_SPEC_SIZE = "s";
        public static readonly string KEY_USER_SIZE = "u";
        private int newMaxSpect;
        private int newMaxUsers;
        private Room room;

        public ChangeRoomCapacityRequest(Room room, int newMaxUsers, int newMaxSpect) : base(RequestType.ChangeRoomCapacity)
        {
            this.room = room;
            this.newMaxUsers = newMaxUsers;
            this.newMaxSpect = newMaxSpect;
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutInt(KEY_ROOM, this.room.Id);
            base.sfso.PutInt(KEY_USER_SIZE, this.newMaxUsers);
            base.sfso.PutInt(KEY_SPEC_SIZE, this.newMaxSpect);
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (this.room == null)
            {
                errors.Add("Provided room is null");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("ChangeRoomCapacity request error", errors);
            }
        }
    }
}

