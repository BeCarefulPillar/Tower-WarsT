namespace Kiol.Zip.GZip
{
    using Kiol.Zip.Checksums;
    using Kiol.Zip.Compression;
    using Kiol.Zip.Compression.Streams;
    using System;
    using System.IO;

    public class GZipOutputStream : DeflaterOutputStream
    {
        private enum OutputState
        {
            Header,
            Footer,
            Finished,
            Closed
        }

        protected Crc32 mCrc;
        private OutputState mState;

        public GZipOutputStream(Stream outputStream) : this(outputStream, 4096) { }

        public GZipOutputStream(Stream outputStream, int size) : base(outputStream, new Deflater(-1, true), size)
        {
            mCrc = new Crc32();
        }

        public override void Close()
        {
            try
            {
                Finish();
            }
            finally
            {
                if (mState != OutputState.Closed)
                {
                    mState = OutputState.Closed;
                    if (IsStreamOwner)
                    {
                        mOutputStream.Close();
                    }
                }
            }
        }

        public override void Finish()
        {
            if (mState == OutputState.Header)
            {
                WriteHeader();
            }
            if (mState == OutputState.Footer)
            {
                mState = OutputState.Finished;
                base.Finish();
                uint total = (uint)(((ulong)mDeflater.TotalIn) & 0xffffffffL);
                uint crc = (uint)(((ulong)mCrc.Value) & 0xffffffffL);
                byte[] buffer = new byte[] { (byte) crc, (byte) (crc >> 8), (byte) (crc >> 16), (byte) (crc >> 24), (byte) total, (byte) (total >> 8), (byte) (total >> 16), (byte) (total >> 24) };
                mOutputStream.Write(buffer, 0, buffer.Length);
            }
        }

        public int GetLevel()
        {
            return mDeflater.GetLevel();
        }

        public void SetLevel(int level)
        {
            if (level < 1)
            {
                throw new ArgumentOutOfRangeException("level");
            }
            mDeflater.SetLevel(level);
        }

        public override void Write(byte[] buffer, int offset, int count)
        {
            if (mState == OutputState.Header)
            {
                WriteHeader();
            }
            if (mState != OutputState.Footer)
            {
                throw new InvalidOperationException("Write not permitted in current state");
            }
            mCrc.Update(buffer, offset, count);
            base.Write(buffer, offset, count);
        }

        private void WriteHeader()
        {
            if (mState == OutputState.Header)
            {
                mState = OutputState.Footer;
                // 写入文件头及时间戳
                int ts = (int) ((DateTime.Now.Ticks - new DateTime(1970, 1, 1).Ticks) / 10000000L);
                byte[] buffer = new byte[] { 0x1F, 0x8B, 8, 0, (byte)ts, (byte)(ts >> 8), (byte)(ts >> 16), (byte)(ts >> 24), 0, 0xFF };
                mOutputStream.Write(buffer, 0, buffer.Length);
            }
        }
    }
}

