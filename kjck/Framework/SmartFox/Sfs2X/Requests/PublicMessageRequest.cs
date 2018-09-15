namespace Sfs2X.Requests
{
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using System;

    public class PublicMessageRequest : GenericMessageRequest
    {
        public PublicMessageRequest(string message) : this(message, null, null)
        {
        }

        public PublicMessageRequest(string message, ISFSObject parameters) : this(message, parameters, null)
        {
        }

        public PublicMessageRequest(string message, ISFSObject parameters, Room targetRoom)
        {
            base.type = 0;
            base.message = message;
            base.room = targetRoom;
            base.parameters = parameters;
        }
    }
}

