namespace Sfs2X.Requests.Buddylist
{
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using Sfs2X.Requests;
    using System;

    public class BuddyMessageRequest : GenericMessageRequest
    {
        public BuddyMessageRequest(string message, Buddy targetBuddy) : this(message, targetBuddy, null)
        {
        }

        public BuddyMessageRequest(string message, Buddy targetBuddy, ISFSObject parameters)
        {
            base.type = 5;
            base.message = message;
            base.recipient = (targetBuddy != null) ? targetBuddy.Id : -1;
            base.parameters = parameters;
        }
    }
}

