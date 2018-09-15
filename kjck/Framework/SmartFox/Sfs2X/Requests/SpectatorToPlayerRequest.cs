namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class SpectatorToPlayerRequest : BaseRequest
    {
        public static readonly string KEY_PLAYER_ID = "p";
        public static readonly string KEY_ROOM_ID = "r";
        public static readonly string KEY_USER_ID = "u";
        private Room room;

        public SpectatorToPlayerRequest() : base(RequestType.SpectatorToPlayer)
        {
            this.Init(null);
        }

        public SpectatorToPlayerRequest(Room targetRoom) : base(RequestType.SpectatorToPlayer)
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

