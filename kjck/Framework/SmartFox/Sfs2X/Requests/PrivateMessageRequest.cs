namespace Sfs2X.Requests
{
    using Sfs2X.Entities.Data;
    using System;

    public class PrivateMessageRequest : GenericMessageRequest
    {
        public PrivateMessageRequest(string message, int recipientId) : this(message, recipientId, null)
        {
        }

        public PrivateMessageRequest(string message, int recipientId, ISFSObject parameters)
        {
            base.type = 1;
            base.message = message;
            base.recipient = recipientId;
            base.parameters = parameters;
        }
    }
}

