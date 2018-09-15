namespace Sfs2X.Bitswarm
{
    using Sfs2X;
    using Sfs2X.Exceptions;
    using Sfs2X.Logging;
    using System;

    public abstract class BaseController : IController
    {
        protected BitSwarmClient bitSwarm;
        protected int id = -1;
        protected Logger log;
        protected SmartFox sfs;

        public BaseController(BitSwarmClient bitSwarm)
        {
            this.bitSwarm = bitSwarm;
            if (bitSwarm != null)
            {
                this.log = bitSwarm.Log;
                this.sfs = bitSwarm.Sfs;
            }
        }

        public abstract void HandleMessage(IMessage message);

        public int Id
        {
            get
            {
                return this.id;
            }
            set
            {
                if (this.id != -1)
                {
                    throw new SFSError("Controller ID is already set: " + this.id + ". Can't be changed at runtime!");
                }
                this.id = value;
            }
        }
    }
}

