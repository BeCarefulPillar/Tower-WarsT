namespace Kiol.Zip.Compression
{
    using System;

    public class PendingBuffer
    {
        private int mBitCount;
        private uint mBits;
        private byte[] mBuffer;
        private int mEnd;
        private int mStart;

        public PendingBuffer() : this(4096) { }

        public PendingBuffer(int bufferSize)
        {
            mBuffer = new byte[bufferSize];
        }

        public void AlignToByte()
        {
            if (mBitCount > 0)
            {
                mBuffer[mEnd++] = (byte)mBits;
                if (mBitCount > 8)
                {
                    mBuffer[mEnd++] = (byte)(mBits >> 8);
                }
            }
            mBits = 0;
            mBitCount = 0;
        }

        public int Flush(byte[] output, int offset, int length)
        {
            if (mBitCount >= 8)
            {
                mBuffer[mEnd++] = (byte)mBits;
                mBits = mBits >> 8;
                mBitCount -= 8;
            }
            if (length > (mEnd - mStart))
            {
                length = mEnd - mStart;
                Array.Copy(mBuffer, mStart, output, offset, length);
                mStart = 0;
                mEnd = 0;
                return length;
            }
            Array.Copy(mBuffer, mStart, output, offset, length);
            mStart += length;
            return length;
        }

        public void Reset()
        {
            mStart = mEnd = mBitCount = 0;
        }

        public byte[] ToByteArray()
        {
            byte[] destinationArray = new byte[mEnd - mStart];
            Array.Copy(mBuffer, mStart, destinationArray, 0, destinationArray.Length);
            mStart = 0;
            mEnd = 0;
            return destinationArray;
        }

        public void WriteBits(int b, int count)
        {
            mBits |= (uint)(b << mBitCount);
            mBitCount += count;
            if (mBitCount >= 0x10)
            {
                mBuffer[mEnd++] = (byte)mBits;
                mBuffer[mEnd++] = (byte)(mBits >> 8);
                mBits = mBits >> 0x10;
                mBitCount -= 0x10;
            }
        }

        public void WriteBlock(byte[] block, int offset, int length)
        {
            Array.Copy(block, offset, mBuffer, mEnd, length);
            mEnd += length;
        }

        public void WriteByte(int value)
        {
            mBuffer[mEnd++] = (byte)value;
        }

        public void WriteInt(int value)
        {
            mBuffer[mEnd++] = (byte)value;
            mBuffer[mEnd++] = (byte)(value >> 8);
            mBuffer[mEnd++] = (byte)(value >> 0x10);
            mBuffer[mEnd++] = (byte)(value >> 0x18);
        }

        public void WriteShort(int value)
        {
            mBuffer[mEnd++] = (byte)value;
            mBuffer[mEnd++] = (byte)(value >> 8);
        }

        public void WriteShortMSB(int s)
        {
            mBuffer[mEnd++] = (byte)(s >> 8);
            mBuffer[mEnd++] = (byte)s;
        }

        public int BitCount { get { return mBitCount; } }

        public bool IsFlushed { get { return mEnd == 0; } }
    }
}
