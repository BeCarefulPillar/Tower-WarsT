namespace Sfs2X.Requests
{
    using System;

    public class MessageRecipientMode
    {
        private int mode;
        private object target;

        public MessageRecipientMode(int mode, object target)
        {
            if ((mode < 0) || (mode > 3))
            {
                throw new ArgumentException("Illegal recipient mode: " + mode);
            }
            this.mode = mode;
            this.target = target;
        }

        public int Mode
        {
            get
            {
                return this.mode;
            }
        }

        public object Target
        {
            get
            {
                return this.target;
            }
        }
    }
}

