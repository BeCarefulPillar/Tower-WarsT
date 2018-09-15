namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Variables;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class SetRoomVariablesRequest : BaseRequest
    {
        public static readonly string KEY_VAR_LIST = "vl";
        public static readonly string KEY_VAR_ROOM = "r";
        private Room room;
        private ICollection<RoomVariable> roomVariables;

        public SetRoomVariablesRequest(ICollection<RoomVariable> roomVariables) : base(RequestType.SetRoomVariables)
        {
            this.Init(roomVariables, null);
        }

        public SetRoomVariablesRequest(ICollection<RoomVariable> roomVariables, Room room) : base(RequestType.SetRoomVariables)
        {
            this.Init(roomVariables, room);
        }

        public override void Execute(SmartFox sfs)
        {
            ISFSArray val = SFSArray.NewInstance();
            foreach (RoomVariable variable in this.roomVariables)
            {
                val.AddSFSArray(variable.ToSFSArray());
            }
            if (this.room == null)
            {
                this.room = sfs.LastJoinedRoom;
            }
            base.sfso.PutSFSArray(KEY_VAR_LIST, val);
            base.sfso.PutInt(KEY_VAR_ROOM, this.room.Id);
        }

        private void Init(ICollection<RoomVariable> roomVariables, Room room)
        {
            this.roomVariables = roomVariables;
            this.room = room;
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (this.room != null)
            {
                if (!this.room.ContainsUser(sfs.MySelf))
                {
                    errors.Add("You are not joined in the target room");
                }
            }
            else if (sfs.LastJoinedRoom == null)
            {
                errors.Add("You are not joined in any rooms");
            }
            if ((this.roomVariables == null) || (this.roomVariables.Count == 0))
            {
                errors.Add("No variables were specified");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("SetRoomVariables request error", errors);
            }
        }
    }
}

