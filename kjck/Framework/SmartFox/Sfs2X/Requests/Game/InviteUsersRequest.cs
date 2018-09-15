namespace Sfs2X.Requests.Game
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class InviteUsersRequest : BaseRequest
    {
        private List<object> invitedUsers;
        public static readonly string KEY_INVITATION_ID = "ii";
        public static readonly string KEY_INVITED_USERS = "iu";
        public static readonly string KEY_INVITEE_ID = "ee";
        public static readonly string KEY_PARAMS = "p";
        public static readonly string KEY_REPLY_ID = "ri";
        public static readonly string KEY_TIME = "t";
        public static readonly string KEY_USER = "u";
        public static readonly string KEY_USER_ID = "ui";
        public static readonly int MAX_EXPIRY_TIME = 300;
        public static readonly int MAX_INVITATIONS_FROM_CLIENT_SIDE = 8;
        public static readonly int MIN_EXPIRY_TIME = 5;
        private ISFSObject parameters;
        private int secondsForAnswer;

        public InviteUsersRequest(List<object> invitedUsers, int secondsForReply, ISFSObject parameters) : base(RequestType.InviteUser)
        {
            this.invitedUsers = invitedUsers;
            this.secondsForAnswer = secondsForReply;
            this.parameters = parameters;
        }

        public override void Execute(SmartFox sfs)
        {
            List<int> list = new List<int>();
            foreach (object obj2 in this.invitedUsers)
            {
                if (obj2 is User)
                {
                    if ((obj2 as User) != sfs.MySelf)
                    {
                        list.Add((obj2 as User).Id);
                    }
                }
                else if (obj2 is Buddy)
                {
                    list.Add((obj2 as Buddy).Id);
                }
            }
            base.sfso.PutIntArray(KEY_INVITED_USERS, list.ToArray());
            base.sfso.PutShort(KEY_TIME, (short) this.secondsForAnswer);
            if (this.parameters != null)
            {
                base.sfso.PutSFSObject(KEY_PARAMS, this.parameters);
            }
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if ((this.invitedUsers == null) || (this.invitedUsers.Count < 1))
            {
                errors.Add("No invitation(s) to send");
            }
            if (this.invitedUsers.Count > MAX_INVITATIONS_FROM_CLIENT_SIDE)
            {
                errors.Add("Too many invitations. Max allowed from client side is: " + MAX_INVITATIONS_FROM_CLIENT_SIDE);
            }
            if ((this.secondsForAnswer < 5) || (this.secondsForAnswer > 300))
            {
                errors.Add(string.Concat(new object[] { "SecondsForAnswer value is out of range (", MIN_EXPIRY_TIME, "-", MAX_EXPIRY_TIME, ")" }));
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("InvitationReply request error", errors);
            }
        }
    }
}

