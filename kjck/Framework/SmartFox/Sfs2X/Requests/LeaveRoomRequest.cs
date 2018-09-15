namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Exceptions;
    using System;

    public class LeaveRoomRequest : BaseRequest
    {
        public static readonly string KEY_ROOM_ID = "r";
        private Room room;

        public LeaveRoomRequest() : base(RequestType.LeaveRoom)
        {
            this.Init(null);
        }

        public LeaveRoomRequest(Room room) : base(RequestType.LeaveRoom)
        {
            this.Init(room);
        }

        public override void Execute(SmartFox sfs)
        {
            if (this.room != null)
            {
                base.sfso.PutInt(KEY_ROOM_ID, this.room.Id);
            }
        }

        private void Init(Room room)
        {
            this.room = room;
        }

        public override void Validate(SmartFox sfs)
        {
            if (sfs.JoinedRooms.Count < 1)
            {
                throw new SFSValidationError("LeaveRoom request error", new string[] { "You are not joined in any rooms" });
            }
        }
    }
}

