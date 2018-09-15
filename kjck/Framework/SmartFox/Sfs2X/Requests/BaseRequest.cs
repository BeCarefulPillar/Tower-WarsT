namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Bitswarm;
    using Sfs2X.Entities.Data;
    using System;

    public class BaseRequest : IRequest
    {
        private int id;
        private bool isEncrypted;
        public static readonly string KEY_ERROR_CODE = "ec";
        public static readonly string KEY_ERROR_PARAMS = "ep";
        protected ISFSObject sfso;
        protected int targetController;

        public BaseRequest(RequestType tp)
        {
            this.sfso = SFSObject.NewInstance();
            this.targetController = 0;
            this.isEncrypted = false;
            this.id = (int) tp;
        }

        public BaseRequest(int id)
        {
            this.sfso = SFSObject.NewInstance();
            this.targetController = 0;
            this.isEncrypted = false;
            this.id = id;
        }

        public virtual void Execute(SmartFox sfs)
        {
        }

        public virtual void Validate(SmartFox sfs)
        {
        }

        public int Id
        {
            get
            {
                return this.id;
            }
            set
            {
                this.id = value;
            }
        }

        public bool IsEncrypted
        {
            get
            {
                return this.isEncrypted;
            }
            set
            {
                this.isEncrypted = value;
            }
        }

        public IMessage Message
        {
            get
            {
                IMessage message = new Sfs2X.Bitswarm.Message {
                    Id = this.id,
                    IsEncrypted = this.isEncrypted,
                    TargetController = this.targetController,
                    Content = this.sfso
                };
                if (this is ExtensionRequest)
                {
                    message.IsUDP = (this as ExtensionRequest).UseUDP;
                }
                return message;
            }
        }

        public int TargetController
        {
            get
            {
                return this.targetController;
            }
            set
            {
                this.targetController = value;
            }
        }

        public RequestType Type
        {
            get
            {
                return (RequestType) this.id;
            }
            set
            {
                this.id = (int) value;
            }
        }
    }
}

