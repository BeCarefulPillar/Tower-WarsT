namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class KickUserRequest : BaseRequest
    {
        private int delay;
        public static readonly string KEY_DELAY = "d";
        public static readonly string KEY_MESSAGE = "m";
        public static readonly string KEY_USER_ID = "u";
        private string message;
        private int userId;

        public KickUserRequest(int userId) : base(RequestType.KickUser)
        {
            this.Init(userId, null, 5);
        }

        public KickUserRequest(int userId, string message) : base(RequestType.KickUser)
        {
            this.Init(userId, message, 5);
        }

        public KickUserRequest(int userId, string message, int delaySeconds) : base(RequestType.BanUser)
        {
            this.Init(userId, message, delaySeconds);
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutInt(KEY_USER_ID, this.userId);
            base.sfso.PutInt(KEY_DELAY, this.delay);
            if ((this.message != null) && (this.message.Length > 0))
            {
                base.sfso.PutUtfString(KEY_MESSAGE, this.message);
            }
        }

        private void Init(int userId, string message, int delaySeconds)
        {
            this.userId = userId;
            this.message = message;
            this.delay = delaySeconds;
            if (this.delay < 0)
            {
                this.delay = 0;
            }
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (!(sfs.MySelf.IsModerator() || sfs.MySelf.IsAdmin()))
            {
                errors.Add("You don't have enough permissions to execute this request.");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("KickUser request error", errors);
            }
        }
    }
}

