namespace Kiol.Zip.Compression
{
    public class DeflaterPending : PendingBuffer
    {
        public DeflaterPending() : base(0x10000) { }
    }
}

