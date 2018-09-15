namespace Sfs2X.Bitswarm
{
    using Sfs2X.Protocol;
    using Sfs2X.Util;
    using System;

    public interface IoHandler
    {
        void OnDataRead(ByteArray buffer);
        void OnDataWrite(IMessage message);

        IProtocolCodec Codec { get; }
    }
}

