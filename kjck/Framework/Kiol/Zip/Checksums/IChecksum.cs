﻿namespace Kiol.Zip.Checksums
{
    public interface IChecksum
    {
        void Reset();
        void Update(int value);
        void Update(byte[] buffer);
        void Update(byte[] buffer, int offset, int count);
        long Value { get; }
    }
}
