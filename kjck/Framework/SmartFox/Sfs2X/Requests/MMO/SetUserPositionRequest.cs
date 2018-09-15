namespace Sfs2X.Requests.MMO
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class SetUserPositionRequest : BaseRequest
    {
        public static readonly string KEY_MINUS_ITEM_LIST = "n";
        public static readonly string KEY_MINUS_USER_LIST = "m";
        public static readonly string KEY_PLUS_ITEM_LIST = "q";
        public static readonly string KEY_PLUS_USER_LIST = "p";
        public static readonly string KEY_ROOM = "r";
        public static readonly string KEY_VEC3D = "v";
        private Vec3D pos;
        private Room room;

        public SetUserPositionRequest(Vec3D position) : this(position, null)
        {
        }

        public SetUserPositionRequest(Vec3D position, Room room) : base(RequestType.SetUserPosition)
        {
            this.room = room;
            this.pos = position;
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutInt(KEY_ROOM, this.room.Id);
            if (this.pos.IsFloat())
            {
                base.sfso.PutFloatArray(KEY_VEC3D, this.pos.ToFloatArray());
            }
            else
            {
                base.sfso.PutIntArray(KEY_VEC3D, this.pos.ToIntArray());
            }
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (this.pos == null)
            {
                errors.Add("Position must be a valid Vec3D ");
            }
            if (this.room == null)
            {
                this.room = sfs.LastJoinedRoom;
            }
            if (this.room == null)
            {
                errors.Add("You are not joined in any room");
            }
            if (!(this.room is MMORoom))
            {
                errors.Add("Selected Room is not an MMORoom");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("SetUserVariables request error", errors);
            }
        }
    }
}

