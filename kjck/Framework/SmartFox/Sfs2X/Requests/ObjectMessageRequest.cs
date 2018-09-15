namespace Sfs2X.Requests
{
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using System;
    using System.Collections.Generic;

    public class ObjectMessageRequest : GenericMessageRequest
    {
        public ObjectMessageRequest(ISFSObject obj) : this(obj, null, null)
        {
        }

        public ObjectMessageRequest(ISFSObject obj, Room targetRoom) : this(obj, targetRoom, null)
        {
        }

        public ObjectMessageRequest(ISFSObject obj, Room targetRoom, ICollection<User> recipients)
        {
            base.type = 4;
            base.parameters = obj;
            base.room = targetRoom;
            base.recipient = recipients;
        }
    }
}

