namespace Sfs2X.Bitswarm
{
    using Sfs2X.Entities.Data;
    using System;
    using System.Text;

    public class Message : IMessage
    {
        private ISFSObject content;
        private int id;
        private bool isEncrypted = false;
        private bool isUDP;
        private long packetId;
        private int targetController;

        public override string ToString()
        {
            StringBuilder builder = new StringBuilder("{ Message id: " + this.id + " }\n");
            builder.Append("{ Dump: }\n");
            builder.Append(this.content.GetDump());
            return builder.ToString();
        }

        public ISFSObject Content
        {
            get
            {
                return this.content;
            }
            set
            {
                this.content = value;
            }
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

        public bool IsUDP
        {
            get
            {
                return this.isUDP;
            }
            set
            {
                this.isUDP = value;
            }
        }

        public long PacketId
        {
            get
            {
                return this.packetId;
            }
            set
            {
                this.packetId = value;
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
    }
}

