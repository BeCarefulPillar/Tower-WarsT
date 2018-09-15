namespace Sfs2X.Core
{
    using System;
    using System.Text;

    public class PacketHeader
    {
        private bool bigSized;
        private bool binary = true;
        private bool blueBoxed;
        private bool compressed;
        private bool encrypted;
        private int expectedLength = -1;

        public PacketHeader(bool encrypted, bool compressed, bool blueBoxed, bool bigSized)
        {
            this.compressed = compressed;
            this.encrypted = encrypted;
            this.blueBoxed = blueBoxed;
            this.bigSized = bigSized;
        }

        public byte Encode()
        {
            byte num = 0;
            if (this.binary)
            {
                num = (byte) (num | 0x80);
            }
            if (this.Encrypted)
            {
                num = (byte) (num | 0x40);
            }
            if (this.Compressed)
            {
                num = (byte) (num | 0x20);
            }
            if (this.blueBoxed)
            {
                num = (byte) (num | 0x10);
            }
            if (this.bigSized)
            {
                num = (byte) (num | 8);
            }
            return num;
        }

        public static PacketHeader FromBinary(int headerByte)
        {
            return new PacketHeader((headerByte & 0x40) > 0, (headerByte & 0x20) > 0, (headerByte & 0x10) > 0, (headerByte & 8) > 0);
        }

        public override string ToString()
        {
            StringBuilder builder = new StringBuilder();
            builder.Append("---------------------------------------------\n");
            builder.Append("Binary:  \t" + this.binary + "\n");
            builder.Append("Compressed:\t" + this.compressed + "\n");
            builder.Append("Encrypted:\t" + this.encrypted + "\n");
            builder.Append("BlueBoxed:\t" + this.blueBoxed + "\n");
            builder.Append("BigSized:\t" + this.bigSized + "\n");
            builder.Append("---------------------------------------------\n");
            return builder.ToString();
        }

        public bool BigSized
        {
            get
            {
                return this.bigSized;
            }
            set
            {
                this.bigSized = value;
            }
        }

        public bool Binary
        {
            get
            {
                return this.binary;
            }
            set
            {
                this.binary = value;
            }
        }

        public bool BlueBoxed
        {
            get
            {
                return this.blueBoxed;
            }
            set
            {
                this.blueBoxed = value;
            }
        }

        public bool Compressed
        {
            get
            {
                return this.compressed;
            }
            set
            {
                this.compressed = value;
            }
        }

        public bool Encrypted
        {
            get
            {
                return this.encrypted;
            }
            set
            {
                this.encrypted = value;
            }
        }

        public int ExpectedLength
        {
            get
            {
                return this.expectedLength;
            }
            set
            {
                this.expectedLength = value;
            }
        }
    }
}

