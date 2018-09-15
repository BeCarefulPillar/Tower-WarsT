namespace Sfs2X.Util
{
    using ComponentAce.Compression.Libs.zlib;
    using Sfs2X.Entities.Data;
    using System;
    using System.IO;
    using System.Text;

    public class ByteArray
    {
        private byte[] buffer;
        private bool compressed;
        private int position;

        public ByteArray()
        {
            this.position = 0;
            this.compressed = false;
            this.buffer = new byte[0];
        }

        public ByteArray(byte[] buf)
        {
            this.position = 0;
            this.compressed = false;
            this.buffer = buf;
        }

        private void CheckCompressedRead()
        {
            if (this.compressed)
            {
                throw new Exception("Only raw bytes can be read from a compressed array.");
            }
        }

        private void CheckCompressedWrite()
        {
            if (this.compressed)
            {
                throw new Exception("Only raw bytes can be written a compressed array. Call Uncompress first.");
            }
        }

        public void Compress()
        {
            if (this.compressed)
            {
                throw new Exception("Buffer is already compressed");
            }
            MemoryStream stream = new MemoryStream();
            using (ZOutputStream stream2 = new ZOutputStream(stream, 9))
            {
                stream2.Write(this.buffer, 0, this.buffer.Length);
                stream2.Flush();
            }
            this.buffer = stream.ToArray();
            this.position = 0;
            this.compressed = true;
        }

        public bool ReadBool()
        {
            this.CheckCompressedRead();
            return (this.buffer[this.position++] == 1);
        }

        public byte ReadByte()
        {
            this.CheckCompressedRead();
            return this.buffer[this.position++];
        }

        public byte[] ReadBytes(int count)
        {
            byte[] dst = new byte[count];
            Buffer.BlockCopy(this.buffer, this.position, dst, 0, count);
            this.position += count;
            return dst;
        }

        public double ReadDouble()
        {
            this.CheckCompressedRead();
            return BitConverter.ToDouble(this.ReverseOrder(this.ReadBytes(8)), 0);
        }

        public float ReadFloat()
        {
            this.CheckCompressedRead();
            return BitConverter.ToSingle(this.ReverseOrder(this.ReadBytes(4)), 0);
        }

        public int ReadInt()
        {
            this.CheckCompressedRead();
            return BitConverter.ToInt32(this.ReverseOrder(this.ReadBytes(4)), 0);
        }

        public long ReadLong()
        {
            this.CheckCompressedRead();
            return BitConverter.ToInt64(this.ReverseOrder(this.ReadBytes(8)), 0);
        }

        public short ReadShort()
        {
            this.CheckCompressedRead();
            return BitConverter.ToInt16(this.ReverseOrder(this.ReadBytes(2)), 0);
        }

        public ushort ReadUShort()
        {
            this.CheckCompressedRead();
            return BitConverter.ToUInt16(this.ReverseOrder(this.ReadBytes(2)), 0);
        }

        public string ReadUTF()
        {
            this.CheckCompressedRead();
            ushort count = this.ReadUShort();
            string str = Encoding.UTF8.GetString(this.buffer, this.position, count);
            this.position += count;
            return str;
        }

        public byte[] ReverseOrder(byte[] dt)
        {
            if (!BitConverter.IsLittleEndian)
            {
                return dt;
            }
            byte[] buffer = new byte[dt.Length];
            int num = 0;
            for (int i = dt.Length - 1; i >= 0; i--)
            {
                buffer[num++] = dt[i];
            }
            return buffer;
        }

        public void Uncompress()
        {
            MemoryStream stream = new MemoryStream();
            using (ZOutputStream stream2 = new ZOutputStream(stream))
            {
                stream2.Write(this.buffer, 0, this.buffer.Length);
                stream2.Flush();
            }
            this.buffer = stream.ToArray();
            this.position = 0;
            this.compressed = false;
        }

        public void WriteBool(bool b)
        {
            this.CheckCompressedWrite();
            byte[] data = new byte[] { b ? ((byte) 1) : ((byte) 0) };
            this.WriteBytes(data);
        }

        public void WriteByte(SFSDataType tp)
        {
            this.WriteByte(Convert.ToByte((int) tp));
        }

        public void WriteByte(byte b)
        {
            byte[] data = new byte[] { b };
            this.WriteBytes(data);
        }

        public void WriteBytes(byte[] data)
        {
            this.WriteBytes(data, 0, data.Length);
        }

        public void WriteBytes(byte[] data, int ofs, int count)
        {
            byte[] dst = new byte[count + this.buffer.Length];
            Buffer.BlockCopy(this.buffer, 0, dst, 0, this.buffer.Length);
            Buffer.BlockCopy(data, ofs, dst, this.buffer.Length, count);
            this.buffer = dst;
        }

        public void WriteDouble(double d)
        {
            this.CheckCompressedWrite();
            byte[] bytes = BitConverter.GetBytes(d);
            this.WriteBytes(this.ReverseOrder(bytes));
        }

        public void WriteFloat(float f)
        {
            this.CheckCompressedWrite();
            byte[] bytes = BitConverter.GetBytes(f);
            this.WriteBytes(this.ReverseOrder(bytes));
        }

        public void WriteInt(int i)
        {
            this.CheckCompressedWrite();
            byte[] bytes = BitConverter.GetBytes(i);
            this.WriteBytes(this.ReverseOrder(bytes));
        }

        public void WriteLong(long l)
        {
            this.CheckCompressedWrite();
            byte[] bytes = BitConverter.GetBytes(l);
            this.WriteBytes(this.ReverseOrder(bytes));
        }

        public void WriteShort(short s)
        {
            this.CheckCompressedWrite();
            byte[] bytes = BitConverter.GetBytes(s);
            this.WriteBytes(this.ReverseOrder(bytes));
        }

        public void WriteUShort(ushort us)
        {
            this.CheckCompressedWrite();
            byte[] bytes = BitConverter.GetBytes(us);
            this.WriteBytes(this.ReverseOrder(bytes));
        }

        public void WriteUTF(string str)
        {
            this.CheckCompressedWrite();
            int num = 0;
            for (int i = 0; i < str.Length; i++)
            {
                int num3 = str[i];
                if ((num3 >= 1) && (num3 <= 0x7f))
                {
                    num++;
                }
                else if (num3 > 0x7ff)
                {
                    num += 3;
                }
                else
                {
                    num += 2;
                }
            }
            if (num > 0x8000)
            {
                throw new FormatException("String length cannot be greater then 32768 !");
            }
            this.WriteUShort(Convert.ToUInt16(num));
            this.WriteBytes(Encoding.UTF8.GetBytes(str));
        }

        public byte[] Bytes
        {
            get
            {
                return this.buffer;
            }
            set
            {
                this.buffer = value;
                this.compressed = false;
            }
        }

        public int BytesAvailable
        {
            get
            {
                int num = this.buffer.Length - this.position;
                if ((num > this.buffer.Length) || (num < 0))
                {
                    num = 0;
                }
                return num;
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

        public int Length
        {
            get
            {
                return this.buffer.Length;
            }
        }

        public int Position
        {
            get
            {
                return this.position;
            }
            set
            {
                this.position = value;
            }
        }
    }
}

