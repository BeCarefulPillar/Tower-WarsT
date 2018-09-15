namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class GenericMessageRequest : BaseRequest
    {
        public static readonly string KEY_MESSAGE = "m";
        public static readonly string KEY_MESSAGE_TYPE = "t";
        public static readonly string KEY_RECIPIENT = "rc";
        public static readonly string KEY_RECIPIENT_MODE = "rm";
        public static readonly string KEY_ROOM_ID = "r";
        public static readonly string KEY_SENDER_DATA = "sd";
        public static readonly string KEY_USER_ID = "u";
        public static readonly string KEY_XTRA_PARAMS = "p";
        protected string message;
        protected ISFSObject parameters;
        protected object recipient;
        protected Room room;
        protected int sendMode;
        protected int type;
        protected User user;

        public GenericMessageRequest() : base(RequestType.GenericMessage)
        {
            this.type = -1;
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutByte(KEY_MESSAGE_TYPE, Convert.ToByte(this.type));
            switch (this.type)
            {
                case 0:
                    this.ExecutePublicMessage(sfs);
                    return;

                case 1:
                    this.ExecutePrivateMessage(sfs);
                    return;

                case 4:
                    this.ExecuteObjectMessage(sfs);
                    return;

                case 5:
                    this.ExecuteBuddyMessage(sfs);
                    return;
            }
            this.ExecuteSuperUserMessage(sfs);
        }

        private void ExecuteBuddyMessage(SmartFox sfs)
        {
            base.sfso.PutInt(KEY_RECIPIENT, (int) this.recipient);
            base.sfso.PutUtfString(KEY_MESSAGE, this.message);
            if (this.parameters != null)
            {
                base.sfso.PutSFSObject(KEY_XTRA_PARAMS, this.parameters);
            }
        }

        private void ExecuteObjectMessage(SmartFox sfs)
        {
            if (this.room == null)
            {
                this.room = sfs.LastJoinedRoom;
            }
            List<int> list = new List<int>();
            ICollection<User> recipient = this.recipient as ICollection<User>;
            if (recipient != null)
            {
                if (recipient.Count > this.room.Capacity)
                {
                    throw new ArgumentException("The number of recipients is bigger than the target Room capacity: " + recipient.Count);
                }
                foreach (User user in recipient)
                {
                    if (!list.Contains(user.Id))
                    {
                        list.Add(user.Id);
                    }
                }
            }
            base.sfso.PutInt(KEY_ROOM_ID, this.room.Id);
            base.sfso.PutSFSObject(KEY_XTRA_PARAMS, this.parameters);
            if (list.Count > 0)
            {
                base.sfso.PutIntArray(KEY_RECIPIENT, list.ToArray());
            }
        }

        private void ExecutePrivateMessage(SmartFox sfs)
        {
            base.sfso.PutInt(KEY_RECIPIENT, (int) this.recipient);
            base.sfso.PutUtfString(KEY_MESSAGE, this.message);
            if (this.parameters != null)
            {
                base.sfso.PutSFSObject(KEY_XTRA_PARAMS, this.parameters);
            }
        }

        private void ExecutePublicMessage(SmartFox sfs)
        {
            if (this.room == null)
            {
                this.room = sfs.LastJoinedRoom;
            }
            if (this.room == null)
            {
                throw new SFSError("User should be joined in a room in order to send a public message");
            }
            base.sfso.PutInt(KEY_ROOM_ID, this.room.Id);
            base.sfso.PutInt(KEY_USER_ID, sfs.MySelf.Id);
            base.sfso.PutUtfString(KEY_MESSAGE, this.message);
            if (this.parameters != null)
            {
                base.sfso.PutSFSObject(KEY_XTRA_PARAMS, this.parameters);
            }
        }

        private void ExecuteSuperUserMessage(SmartFox sfs)
        {
            base.sfso.PutUtfString(KEY_MESSAGE, this.message);
            if (this.parameters != null)
            {
                base.sfso.PutSFSObject(KEY_XTRA_PARAMS, this.parameters);
            }
            base.sfso.PutInt(KEY_RECIPIENT_MODE, this.sendMode);
            switch (this.sendMode)
            {
                case 0:
                    base.sfso.PutInt(KEY_RECIPIENT, ((User) this.recipient).Id);
                    break;

                case 1:
                    base.sfso.PutInt(KEY_RECIPIENT, ((Room) this.recipient).Id);
                    break;

                case 2:
                    base.sfso.PutUtfString(KEY_RECIPIENT, (string) this.recipient);
                    break;
            }
        }

        public override void Validate(SmartFox sfs)
        {
            if (this.type < 0)
            {
                throw new SFSValidationError("PublicMessage request error", new string[] { "Unsupported message type: " + this.type });
            }
            List<string> errors = new List<string>();
            switch (this.type)
            {
                case 0:
                    this.ValidatePublicMessage(sfs, errors);
                    break;

                case 1:
                    this.ValidatePrivateMessage(sfs, errors);
                    break;

                case 4:
                    this.ValidateObjectMessage(sfs, errors);
                    break;

                case 5:
                    this.ValidateBuddyMessage(sfs, errors);
                    break;

                default:
                    this.ValidateSuperUserMessage(sfs, errors);
                    break;
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("Request error - ", errors);
            }
        }

        private void ValidateBuddyMessage(SmartFox sfs, List<string> errors)
        {
            if (!sfs.BuddyManager.Inited)
            {
                errors.Add("BuddyList is not inited. Please send an InitBuddyRequest first.");
            }
            if (!sfs.BuddyManager.MyOnlineState)
            {
                errors.Add("Can't send messages while off-line");
            }
            if ((this.message == null) || (this.message.Length == 0))
            {
                errors.Add("Buddy message is empty!");
            }
            int recipient = (int) this.recipient;
            if (recipient < 0)
            {
                errors.Add("Recipient is not online or not in your buddy list");
            }
        }

        private void ValidateObjectMessage(SmartFox sfs, List<string> errors)
        {
            if (this.parameters == null)
            {
                errors.Add("Object message is null!");
            }
        }

        private void ValidatePrivateMessage(SmartFox sfs, List<string> errors)
        {
            if ((this.message == null) || (this.message.Length == 0))
            {
                errors.Add("Private message is empty!");
            }
            if (((int) this.recipient) < 0)
            {
                errors.Add("Invalid recipient id: " + this.recipient);
            }
        }

        private void ValidatePublicMessage(SmartFox sfs, List<string> errors)
        {
            if ((this.message == null) || (this.message.Length == 0))
            {
                errors.Add("Public message is empty!");
            }
            if (!((this.room == null) || sfs.JoinedRooms.Contains(this.room)))
            {
                errors.Add("You are not joined in the target Room: " + this.room);
            }
        }

        private void ValidateSuperUserMessage(SmartFox sfs, List<string> errors)
        {
            if ((this.message == null) || (this.message.Length == 0))
            {
                errors.Add("Moderator message is empty!");
            }
            switch (this.sendMode)
            {
                case 0:
                    if (!(this.recipient is User))
                    {
                        errors.Add("TO_USER expects a User object as recipient");
                    }
                    break;

                case 1:
                    if (!(this.recipient is Room))
                    {
                        errors.Add("TO_ROOM expects a Room object as recipient");
                    }
                    break;

                case 2:
                    if (!(this.recipient is string))
                    {
                        errors.Add("TO_GROUP expects a String object (the groupId) as recipient");
                    }
                    break;
            }
        }
    }
}

