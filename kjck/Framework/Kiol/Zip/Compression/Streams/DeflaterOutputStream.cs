namespace Kiol.Zip.Compression.Streams
{
    using Kiol.Zip;
    using Kiol.Zip.Compression;
    using System;
    using System.IO;
    using System.Runtime.InteropServices;
    using System.Security.Cryptography;

    public class DeflaterOutputStream : Stream
    {
        private static RNGCryptoServiceProvider _aesRnd;
        protected byte[] mAESAuthCode;
        protected Stream mOutputStream;
        private byte[] mBuffer;
        protected Deflater mDeflater;
        private bool mIsClosed;
        private bool mIsStreamOwner;
        private string mPassword;

        public DeflaterOutputStream(Stream outputStream) : this(outputStream, new Deflater(), 512) { }

        public DeflaterOutputStream(Stream outputStream, Deflater deflater) : this(outputStream, deflater, 512) { }

        public DeflaterOutputStream(Stream outputStream, Deflater deflater, int bufferSize)
        {
            mIsStreamOwner = true;
            if (outputStream == null)
            {
                throw new ArgumentNullException("baseOutputStream");
            }
            if (!outputStream.CanWrite)
            {
                throw new ArgumentException("Must support writing", "baseOutputStream");
            }
            if (deflater == null)
            {
                throw new ArgumentNullException("deflater");
            }
            if (bufferSize < 512)
            {
                throw new ArgumentOutOfRangeException("bufferSize");
            }
            mOutputStream = outputStream;
            mBuffer = new byte[bufferSize];
            mDeflater = deflater;
        }

        public override IAsyncResult BeginRead(byte[] buffer, int offset, int count, AsyncCallback callback, object state)
        {
            throw new NotSupportedException("DeflaterOutputStream BeginRead not currently supported");
        }

        public override IAsyncResult BeginWrite(byte[] buffer, int offset, int count, AsyncCallback callback, object state)
        {
            throw new NotSupportedException("BeginWrite is not supported");
        }

        public override void Close()
        {
            if (mIsClosed) return;
            mIsClosed = true;
            try
            {
                Finish();
            }
            finally
            {
                if (mIsStreamOwner)
                {
                    mOutputStream.Close();
                }
            }
        }

        protected void Deflate()
        {
            while (!mDeflater.IsNeedingInput)
            {
                int deflateCount = mDeflater.Deflate(mBuffer, 0, mBuffer.Length);
                if (deflateCount <= 0)
                {
                    break;
                }
                mOutputStream.Write(mBuffer, 0, deflateCount);
            }
            if (!mDeflater.IsNeedingInput)
            {
                throw new SharpZipBaseException("DeflaterOutputStream can't deflate all input?");
            }
        }

        public virtual void Finish()
        {
            mDeflater.Finish();
            while (!mDeflater.IsFinished)
            {
                int deflateCount = mDeflater.Deflate(mBuffer, 0, mBuffer.Length);
                if (deflateCount <= 0)
                {
                    break;
                }
                mOutputStream.Write(mBuffer, 0, deflateCount);
            }
            if (!mDeflater.IsFinished)
            {
                throw new SharpZipBaseException("Can't deflate all input?");
            }
            mOutputStream.Flush();
        }

        public override void Flush()
        {
            mDeflater.Flush();
            Deflate();
            mOutputStream.Flush();
        }

        public override int Read(byte[] buffer, int offset, int count)
        {
            throw new NotSupportedException("DeflaterOutputStream Read not supported");
        }

        public override int ReadByte()
        {
            throw new NotSupportedException("DeflaterOutputStream ReadByte not supported");
        }

        public override long Seek(long offset, SeekOrigin origin)
        {
            throw new NotSupportedException("DeflaterOutputStream Seek not supported");
        }

        public override void SetLength(long value)
        {
            throw new NotSupportedException("DeflaterOutputStream SetLength not supported");
        }

        public override void Write(byte[] buffer, int offset, int count)
        {
            mDeflater.SetInput(buffer, offset, count);
            Deflate();
        }

        public override void WriteByte(byte value)
        {
            Write(new byte[] { value }, 0, 1);
        }

        public bool CanPatchEntries { get { return mOutputStream.CanSeek; } }

        public override bool CanRead { get { return false; } }

        public override bool CanSeek { get { return false; } }

        public override bool CanWrite { get { return mOutputStream.CanWrite; } }

        public bool IsStreamOwner { get { return mIsStreamOwner; } set { mIsStreamOwner = value; } }

        public override long Length { get { return mOutputStream.Length; } }

        public string Password { get { return mPassword; } set { mPassword = string.IsNullOrEmpty(value) ? null : value; } }

        public override long Position { get { return mOutputStream.Position; } set { throw new NotSupportedException("Position property not supported"); } }
    }
}

