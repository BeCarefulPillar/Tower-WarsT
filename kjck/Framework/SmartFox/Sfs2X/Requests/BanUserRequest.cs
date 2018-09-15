namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class BanUserRequest : BaseRequest
    {
        private BanMode banMode;
        private int delay;
        private int durationHours;
        public static readonly string KEY_BAN_DURATION_HOURS = "dh";
        public static readonly string KEY_BAN_MODE = "b";
        public static readonly string KEY_DELAY = "d";
        public static readonly string KEY_MESSAGE = "m";
        public static readonly string KEY_USER_ID = "u";
        private string message;
        private int userId;

        public BanUserRequest(int userId) : base(RequestType.BanUser)
        {
            this.Init(userId, null, BanMode.BY_NAME, 5, 0);
        }

        public BanUserRequest(int userId, string message) : base(RequestType.BanUser)
        {
            this.Init(userId, message, BanMode.BY_NAME, 5, 0);
        }

        public BanUserRequest(int userId, string message, BanMode banMode) : base(RequestType.BanUser)
        {
            this.Init(userId, message, banMode, 5, 0);
        }

        public BanUserRequest(int userId, string message, BanMode banMode, int delaySeconds) : base(RequestType.BanUser)
        {
            this.Init(userId, message, banMode, delaySeconds, 0);
        }

        public BanUserRequest(int userId, string message, BanMode banMode, int delaySeconds, int durationHours) : base(RequestType.BanUser)
        {
            this.Init(userId, message, banMode, delaySeconds, durationHours);
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutInt(KEY_USER_ID, this.userId);
            base.sfso.PutInt(KEY_DELAY, this.delay);
            base.sfso.PutInt(KEY_BAN_MODE, (int) this.banMode);
            base.sfso.PutInt(KEY_BAN_DURATION_HOURS, this.durationHours);
            if ((this.message != null) && (this.message.Length > 0))
            {
                base.sfso.PutUtfString(KEY_MESSAGE, this.message);
            }
        }

        private void Init(int userId, string message, BanMode banMode, int delaySeconds, int durationHours)
        {
            this.userId = userId;
            this.message = message;
            this.banMode = banMode;
            this.delay = delaySeconds;
            this.durationHours = durationHours;
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
                throw new SFSValidationError("BanUser request error", errors);
            }
        }
    }
}

