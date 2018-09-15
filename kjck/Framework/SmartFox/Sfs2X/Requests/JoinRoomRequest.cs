namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Exceptions;
    using System;

    public class JoinRoomRequest : BaseRequest
    {
        private bool asSpectator;
        private int id;
        public static readonly string KEY_AS_SPECTATOR = "sp";
        public static readonly string KEY_PASS = "p";
        public static readonly string KEY_ROOM = "r";
        public static readonly string KEY_ROOM_ID = "i";
        public static readonly string KEY_ROOM_NAME = "n";
        public static readonly string KEY_ROOM_TO_LEAVE = "rl";
        public static readonly string KEY_USER_LIST = "ul";
        private string name;
        private string pass;
        private int? roomIdToLeave;

        public JoinRoomRequest(object id) : base(RequestType.JoinRoom)
        {
            this.id = -1;
            this.Init(id, null, null, false);
        }

        public JoinRoomRequest(object id, string pass) : base(RequestType.JoinRoom)
        {
            this.id = -1;
            this.Init(id, pass, null, false);
        }

        public JoinRoomRequest(object id, string pass, int? roomIdToLeave) : base(RequestType.JoinRoom)
        {
            this.id = -1;
            this.Init(id, pass, roomIdToLeave, false);
        }

        public JoinRoomRequest(object id, string pass, int? roomIdToLeave, bool asSpectator) : base(RequestType.JoinRoom)
        {
            this.id = -1;
            this.Init(id, pass, roomIdToLeave, asSpectator);
        }

        public override void Execute(SmartFox sfs)
        {
            if (this.id > -1)
            {
                base.sfso.PutInt(KEY_ROOM_ID, this.id);
            }
            else if (this.name != null)
            {
                base.sfso.PutUtfString(KEY_ROOM_NAME, this.name);
            }
            if (this.pass != null)
            {
                base.sfso.PutUtfString(KEY_PASS, this.pass);
            }
            if (this.roomIdToLeave.HasValue)
            {
                base.sfso.PutInt(KEY_ROOM_TO_LEAVE, this.roomIdToLeave.Value);
            }
            if (this.asSpectator)
            {
                base.sfso.PutBool(KEY_AS_SPECTATOR, this.asSpectator);
            }
        }

        private void Init(object id, string pass, int? roomIdToLeave, bool asSpectator)
        {
            if (id is string)
            {
                this.name = id as string;
            }
            else if (id is int)
            {
                this.id = (int) id;
            }
            else if (id is Room)
            {
                this.id = (id as Room).Id;
            }
            this.pass = pass;
            this.roomIdToLeave = roomIdToLeave;
            this.asSpectator = asSpectator;
        }

        public override void Validate(SmartFox sfs)
        {
            if ((this.id < 0) && (this.name == null))
            {
                throw new SFSValidationError("JoinRoomRequest Error", new string[] { "Missing Room id or name, you should provide at least one" });
            }
        }
    }
}

