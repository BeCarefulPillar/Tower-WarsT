namespace Sfs2X.Requests
{
    using Sfs2X.Entities.Data;
    using System;

    public class AdminMessageRequest : GenericMessageRequest
    {
        public AdminMessageRequest(string message, MessageRecipientMode recipientMode) : this(message, recipientMode, null)
        {
        }

        public AdminMessageRequest(string message, MessageRecipientMode recipientMode, ISFSObject parameters)
        {
            if (recipientMode == null)
            {
                throw new ArgumentException("RecipientMode cannot be null!");
            }
            base.type = 3;
            base.message = message;
            base.parameters = parameters;
            base.recipient = recipientMode.Target;
            base.sendMode = recipientMode.Mode;
        }
    }
}

