namespace Sfs2X.Requests
{
    using System;

    public class RoomEvents
    {
        private bool allowUserCountChange = false;
        private bool allowUserEnter = false;
        private bool allowUserExit = false;
        private bool allowUserVariablesUpdate = false;

        public bool AllowUserCountChange
        {
            get
            {
                return this.allowUserCountChange;
            }
            set
            {
                this.allowUserCountChange = value;
            }
        }

        public bool AllowUserEnter
        {
            get
            {
                return this.allowUserEnter;
            }
            set
            {
                this.allowUserEnter = value;
            }
        }

        public bool AllowUserExit
        {
            get
            {
                return this.allowUserExit;
            }
            set
            {
                this.allowUserExit = value;
            }
        }

        public bool AllowUserVariablesUpdate
        {
            get
            {
                return this.allowUserVariablesUpdate;
            }
            set
            {
                this.allowUserVariablesUpdate = value;
            }
        }
    }
}

