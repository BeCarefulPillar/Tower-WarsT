namespace Sfs2X.Bitswarm
{
    using Sfs2X.Core;
    using Sfs2X.Util;
    using System;

    public class PendingPacket
    {
        private ByteArray buffer;
        private PacketHeader header;

        public PendingPacket(PacketHeader header)
        {
            this.header = header;
            this.buffer = new ByteArray();
            this.buffer.Compressed = header.Compressed;
        }

        public ByteArray Buffer
        {
            get
            {
                return this.buffer;
            }
            set
            {
                this.buffer = value;
            }
        }

        public PacketHeader Header
        {
            get
            {
                return this.header;
            }
        }
    }
}

