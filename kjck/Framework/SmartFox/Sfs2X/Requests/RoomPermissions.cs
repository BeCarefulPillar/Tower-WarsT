namespace Sfs2X.Requests
{
    using System;

    public class RoomPermissions
    {
        private bool allowNameChange;
        private bool allowPasswordStateChange;
        private bool allowPublicMessages;
        private bool allowResizing;

        public bool AllowNameChange
        {
            get
            {
                return this.allowNameChange;
            }
            set
            {
                this.allowNameChange = value;
            }
        }

        public bool AllowPasswordStateChange
        {
            get
            {
                return this.allowPasswordStateChange;
            }
            set
            {
                this.allowPasswordStateChange = value;
            }
        }

        public bool AllowPublicMessages
        {
            get
            {
                return this.allowPublicMessages;
            }
            set
            {
                this.allowPublicMessages = value;
            }
        }

        public bool AllowResizing
        {
            get
            {
                return this.allowResizing;
            }
            set
            {
                this.allowResizing = value;
            }
        }
    }
}

