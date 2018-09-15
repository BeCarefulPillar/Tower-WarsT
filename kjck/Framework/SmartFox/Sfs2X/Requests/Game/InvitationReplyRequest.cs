namespace Sfs2X.Requests.Game
{
    using Sfs2X;
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Invitation;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class InvitationReplyRequest : BaseRequest
    {
        private Sfs2X.Entities.Invitation.Invitation invitation;
        public static readonly string KEY_INVITATION_ID = "i";
        public static readonly string KEY_INVITATION_PARAMS = "p";
        public static readonly string KEY_INVITATION_REPLY = "r";
        private ISFSObject parameters;
        private InvitationReply reply;

        public InvitationReplyRequest(Sfs2X.Entities.Invitation.Invitation invitation, InvitationReply reply) : base(RequestType.InvitationReply)
        {
            this.Init(invitation, reply, null);
        }

        public InvitationReplyRequest(Sfs2X.Entities.Invitation.Invitation invitation, InvitationReply reply, ISFSObject parameters) : base(RequestType.InvitationReply)
        {
            this.Init(invitation, reply, parameters);
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutInt(KEY_INVITATION_ID, this.invitation.Id);
            base.sfso.PutByte(KEY_INVITATION_REPLY, (byte) this.reply);
            if (this.parameters != null)
            {
                base.sfso.PutSFSObject(KEY_INVITATION_PARAMS, this.parameters);
            }
        }

        private void Init(Sfs2X.Entities.Invitation.Invitation invitation, InvitationReply reply, ISFSObject parameters)
        {
            this.invitation = invitation;
            this.reply = reply;
            this.parameters = parameters;
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (this.invitation == null)
            {
                errors.Add("Missing invitation object");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("InvitationReply request error", errors);
            }
        }
    }
}

