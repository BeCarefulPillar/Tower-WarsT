namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class ExtensionRequest : BaseRequest
    {
        private string extCmd;
        public static readonly string KEY_CMD = "c";
        public static readonly string KEY_PARAMS = "p";
        public static readonly string KEY_ROOM = "r";
        private ISFSObject parameters;
        private Room room;
        private bool useUDP;

        public ExtensionRequest(string extCmd, ISFSObject parameters) : base(RequestType.CallExtension)
        {
            this.Init(extCmd, parameters, null, false);
        }

        public ExtensionRequest(string extCmd, ISFSObject parameters, Room room) : base(RequestType.CallExtension)
        {
            this.Init(extCmd, parameters, room, false);
        }

        public ExtensionRequest(string extCmd, ISFSObject parameters, Room room, bool useUDP) : base(RequestType.CallExtension)
        {
            this.Init(extCmd, parameters, room, useUDP);
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutUtfString(KEY_CMD, this.extCmd);
            base.sfso.PutInt(KEY_ROOM, (this.room == null) ? -1 : this.room.Id);
            base.sfso.PutSFSObject(KEY_PARAMS, this.parameters);
        }

        private void Init(string extCmd, ISFSObject parameters, Room room, bool useUDP)
        {
            base.targetController = 1;
            this.extCmd = extCmd;
            this.parameters = parameters ?? new SFSObject();
            this.room = room;
            this.useUDP = useUDP;
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if ((this.extCmd == null) || (this.extCmd.Length == 0))
            {
                errors.Add("Missing extension command");
            }
            if (this.parameters == null)
            {
                errors.Add("Missing extension parameters");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("ExtensionCall request error", errors);
            }
        }

        public bool UseUDP
        {
            get
            {
                return this.useUDP;
            }
        }
    }
}

