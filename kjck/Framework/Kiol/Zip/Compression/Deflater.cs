namespace Kiol.Zip.Compression
{
    using System;

    public class Deflater
    {
        /// <summary>
        /// 压缩级别-默认
        /// </summary>
        public const int DEFAULT_COMPRESSION = -1;
        /// <summary>
        /// 压缩级别-无
        /// </summary>
        public const int NO_COMPRESSION = 0;
        /// <summary>
        /// 压缩级别-最好
        /// </summary>
        public const int BEST_COMPRESSION = 9;
        /// <summary>
        /// 最快压缩速度
        /// </summary>
        public const int BEST_SPEED = 1;
        /// <summary>
        /// 最大压缩率
        /// </summary>
        public const int DEFLATED = 8;

        /// <summary>
        /// 正在写入
        /// </summary>
        private const int IS_FLUSHING = 4;
        /// <summary>
        /// 正在配置字典
        /// </summary>
        private const int IS_SETDICT = 1;
        /// <summary>
        /// 正在结束
        /// </summary>
        private const int IS_FINISHING = 8;
        /// <summary>
        /// 状态-初始
        /// </summary>
        private const int INIT_STATE = 0;
        /// <summary>
        /// 状态-正在配置字典
        /// </summary>
        private const int SETDICT_STATE = 1;
        /// <summary>
        /// 状态-繁忙
        /// </summary>
        private const int BUSY_STATE = 16;
        /// <summary>
        /// 状态-写入
        /// </summary>
        private const int FLUSHING_STATE = 20;
        /// <summary>
        /// 状态-正在结束
        /// </summary>
        private const int FINISHING_STATE = 28;
        /// <summary>
        /// 状态-已结束
        /// </summary>
        private const int FINISHED_STATE = 30;
        /// <summary>
        /// 状态-已关闭
        /// </summary>
        private const int CLOSED_STATE = 127;

        private DeflaterPending mPending;
        private DeflaterEngine mEngine;
        private int mLevel;
        private bool mNoZlibHeaderOrFooter;
        private int mState;
        private long mTotalOut;

        public Deflater() : this(DEFAULT_COMPRESSION, false) { }

        public Deflater(int level) : this(level, false) { }

        public Deflater(int level, bool noZlibHeaderOrFooter)
        {
            if (level == DEFAULT_COMPRESSION)
            {
                level = 6;
            }
            else if (level < NO_COMPRESSION || level > BEST_COMPRESSION)
            {
                throw new ArgumentOutOfRangeException("level");
            }
            mPending = new DeflaterPending();
            mEngine = new DeflaterEngine(mPending);
            mNoZlibHeaderOrFooter = noZlibHeaderOrFooter;
            SetStrategy(DeflateStrategy.Default);
            SetLevel(level);
            Reset();
        }

        public int Deflate(byte[] output) { return Deflate(output, 0, output.Length); }

        public int Deflate(byte[] output, int offset, int length)
        {
            int len = length;
            if (mState == CLOSED_STATE)
            {
                throw new InvalidOperationException("Deflater closed");
            }
            if (mState < BUSY_STATE)
            {
                int s = 0x7800;
                int lv = (mLevel - 1) >> 1;
                if (lv < 0 || lv > 3)
                {
                    lv = 3;
                }
                s |= lv << 6;
                if ((mState & IS_SETDICT) != 0)
                {
                    s |= 32;
                }
                s += 31 - (s % 31);
                mPending.WriteShortMSB(s);
                if ((mState & IS_SETDICT) != 0)
                {
                    int adler = mEngine.Adler;
                    mEngine.ResetAdler();
                    mPending.WriteShortMSB(adler >> 16);
                    mPending.WriteShortMSB(adler & 0xFFFF);
                }
                mState = BUSY_STATE | (mState & (IS_FLUSHING | IS_FINISHING));
            }
            while (true)
            {
                int count = mPending.Flush(output, offset, length);
                offset += count;
                mTotalOut += count;
                length -= count;
                if (length == 0 || mState == FINISHED_STATE)
                {
                    return (len - length);
                }
                if (!mEngine.Deflate((mState & IS_FLUSHING) != 0, (mState & IS_FINISHING) != 0))
                {
                    if (mState == BUSY_STATE)
                    {
                        return len - length;
                    }
                    if (mState == FLUSHING_STATE)
                    {
                        if (mLevel != 0)
                        {
                            for (int i = 8 + (-mPending.BitCount & 7); i > 0; i -= 10)
                            {
                                mPending.WriteBits(2, 10);
                            }
                        }
                        mState = BUSY_STATE;
                    }
                    else if (mState == FINISHING_STATE)
                    {
                        mPending.AlignToByte();
                        if (!mNoZlibHeaderOrFooter)
                        {
                            int adler = mEngine.Adler;
                            mPending.WriteShortMSB(adler >> 16);
                            mPending.WriteShortMSB(adler & 0xFFFF);
                        }
                        mState = FINISHED_STATE;
                    }
                }
            }
        }

        public void Finish()
        {
            mState |= IS_FLUSHING | IS_FINISHING;
        }

        public void Flush()
        {
            mState |= IS_FLUSHING;
        }

        public int GetLevel()
        {
            return mLevel;
        }

        public void Reset()
        {
            mState = mNoZlibHeaderOrFooter ? BUSY_STATE : INIT_STATE;
            mTotalOut = 0L;
            mPending.Reset();
            mEngine.Reset();
        }

        public void SetDictionary(byte[] dictionary)
        {
            SetDictionary(dictionary, 0, dictionary.Length);
        }

        public void SetDictionary(byte[] dictionary, int index, int count)
        {
            if (mState != INIT_STATE)
            {
                throw new InvalidOperationException();
            }
            mState = SETDICT_STATE;
            mEngine.SetDictionary(dictionary, index, count);
        }

        public void SetInput(byte[] input)
        {
            SetInput(input, 0, input.Length);
        }

        public void SetInput(byte[] input, int offset, int count)
        {
            if ((mState & IS_FINISHING) != 0)
            {
                throw new InvalidOperationException("Finish() already called");
            }
            mEngine.SetInput(input, offset, count);
        }

        public void SetLevel(int level)
        {
            if (level == DEFAULT_COMPRESSION)
            {
                level = 6;
            }
            else if (level < NO_COMPRESSION || level > BEST_COMPRESSION)
            {
                throw new ArgumentOutOfRangeException("level");
            }
            if (mLevel != level)
            {
                mLevel = level;
                mEngine.SetLevel(level);
            }
        }

        public void SetStrategy(DeflateStrategy strategy)
        {
            mEngine.Strategy = strategy;
        }

        public int Adler { get { return mEngine.Adler; } }

        public bool IsFinished { get { return mState == FINISHED_STATE && mPending.IsFlushed; } }

        public bool IsNeedingInput { get { return mEngine.NeedsInput(); } }

        public long TotalIn { get { return mEngine.TotalIn; } }

        public long TotalOut { get { return mTotalOut; } }
    }
}
