namespace Sfs2X.Core.Sockets
{
    using System;
    using System.Net;

    public interface ISocketLayer
    {
        //void Connect(IPAddress adr, int port);//ipv6
        void Connect(string adr, int port);//ipv6
        void Disconnect();
        void Disconnect(string reason);
        void Kill();
        void Write(byte[] data);

        bool IsConnected { get; }

        ConnectionDelegate OnConnect { get; set; }

        OnDataDelegate OnData { get; set; }

        ConnectionDelegate OnDisconnect { get; set; }

        OnErrorDelegate OnError { get; set; }

        bool RequiresConnection { get; }
    }
}

