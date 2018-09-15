namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class PlayerToSpectatorRequest : BaseRequest
    {
        public static readonly string KEY_ROOM_ID = "r";
        public static readonly string KEY_USER_ID = "u";
        private Room room;

        public PlayerToSpectatorRequest() : base(RequestType.PlayerToSpectator)
        {
            this.Init(null);
        }

        public PlayerToSpectatorRequest(Room targetRoom) : base(RequestType.PlayerToSpectator)
        {
            this.Init(targetRoom);
        }

        public override void Execute(SmartFox sfs)
        {
            if (this.room == null)
            {
                this.room = sfs.LastJoinedRoom;
            }
            base.sfso.PutInt(KEY_ROOM_ID, this.room.Id);
        }

        private void Init(Room targetRoom)
        {
            this.room = targetRoom;
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (sfs.JoinedRooms.Count < 1)
            {
                errors.Add("You are not joined in any rooms");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("LeaveRoom request error", errors);
            }
        }
    }
}

