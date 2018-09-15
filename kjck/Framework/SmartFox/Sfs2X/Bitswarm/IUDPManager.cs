namespace Sfs2X.Bitswarm
{
    using Sfs2X.Util;
    using System;

    public interface IUDPManager
    {
        void Disconnect();
        void Initialize(string udpAddr, int udpPort);
        bool isConnected();
        void Reset();
        void Send(ByteArray binaryData);

        bool Inited { get; }

        long NextUdpPacketId { get; }
    }
}

