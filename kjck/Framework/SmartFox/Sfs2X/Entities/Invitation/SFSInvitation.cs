namespace Sfs2X.Entities.Invitation
{
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using System;

    public class SFSInvitation : Sfs2X.Entities.Invitation.Invitation
    {
        protected int id;
        protected User invitee;
        protected User inviter;
        protected ISFSObject parameters;
        protected int secondsForAnswer;

        public SFSInvitation(User inviter, User invitee)
        {
            this.Init(inviter, invitee, 15, null);
        }

        public SFSInvitation(User inviter, User invitee, int secondsForAnswer)
        {
            this.Init(inviter, invitee, secondsForAnswer, null);
        }

        public SFSInvitation(User inviter, User invitee, int secondsForAnswer, ISFSObject parameters)
        {
            this.Init(inviter, invitee, secondsForAnswer, parameters);
        }

        private void Init(User inviter, User invitee, int secondsForAnswer, ISFSObject parameters)
        {
            this.inviter = inviter;
            this.invitee = invitee;
            this.secondsForAnswer = secondsForAnswer;
            this.parameters = parameters;
        }

        public int Id
        {
            get
            {
                return this.id;
            }
            set
            {
                this.id = value;
            }
        }

        public User Invitee
        {
            get
            {
                return this.invitee;
            }
        }

        public User Inviter
        {
            get
            {
                return this.inviter;
            }
        }

        public ISFSObject Params
        {
            get
            {
                return this.parameters;
            }
        }

        public int SecondsForAnswer
        {
            get
            {
                return this.secondsForAnswer;
            }
        }
    }
}

