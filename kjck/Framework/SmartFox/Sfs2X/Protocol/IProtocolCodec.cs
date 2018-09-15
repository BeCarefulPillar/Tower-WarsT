namespace Sfs2X.Protocol
{
    using Sfs2X.Bitswarm;
    using Sfs2X.Entities.Data;
    using Sfs2X.Util;
    using System;

    public interface IProtocolCodec
    {
        void OnPacketRead(ISFSObject packet);
        void OnPacketRead(ByteArray packet);
        void OnPacketWrite(IMessage message);

        IoHandler IOHandler { get; set; }
    }
}

