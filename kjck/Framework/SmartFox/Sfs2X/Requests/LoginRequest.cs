namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities.Data;
    using Sfs2X.Exceptions;
    using Sfs2X.Util;
    using System;

    public class LoginRequest : BaseRequest
    {
        public static readonly string KEY_ID = "id";
        public static readonly string KEY_PARAMS = "p";
        public static readonly string KEY_PASSWORD = "pw";
        public static readonly string KEY_PRIVILEGE_ID = "pi";
        public static readonly string KEY_RECONNECTION_SECONDS = "rs";
        public static readonly string KEY_ROOMLIST = "rl";
        public static readonly string KEY_USER_NAME = "un";
        public static readonly string KEY_ZONE_NAME = "zn";
        private ISFSObject parameters;
        private string password;
        private string userName;
        private string zoneName;

        public LoginRequest(string userName) : base(RequestType.Login)
        {
            this.Init(userName, null, null, null);
        }

        public LoginRequest(string userName, string password) : base(RequestType.Login)
        {
            this.Init(userName, password, null, null);
        }

        public LoginRequest(string userName, string password, string zoneName) : base(RequestType.Login)
        {
            this.Init(userName, password, zoneName, null);
        }

        public LoginRequest(string userName, string password, string zoneName, ISFSObject parameters) : base(RequestType.Login)
        {
            this.Init(userName, password, zoneName, parameters);
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutUtfString(KEY_ZONE_NAME, this.zoneName);
            base.sfso.PutUtfString(KEY_USER_NAME, this.userName);
            if (this.password.Length > 0)
            {
                this.password = PasswordUtil.MD5Password(sfs.SessionToken + this.password);
            }
            base.sfso.PutUtfString(KEY_PASSWORD, this.password);
            if (this.parameters != null)
            {
                base.sfso.PutSFSObject(KEY_PARAMS, this.parameters);
            }
        }

        private void Init(string userName, string password, string zoneName, ISFSObject parameters)
        {
            this.userName = userName;
            this.password = (password == null) ? "" : password;
            this.zoneName = zoneName;
            this.parameters = parameters;
        }

        public override void Validate(SmartFox sfs)
        {
            if (sfs.MySelf != null)
            {
                throw new SFSValidationError("LoginRequest Error", new string[] { "You are already logged in. Logout first" });
            }
            if (((this.zoneName == null) || (this.zoneName.Length == 0)) && (sfs.Config != null))
            {
                this.zoneName = sfs.Config.Zone;
            }
            if ((this.zoneName == null) || (this.zoneName.Length == 0))
            {
                throw new SFSValidationError("LoginRequest Error", new string[] { "Missing Zone name" });
            }
        }
    }
}

