namespace Sfs2X.Core
{
    using Sfs2X.Util;
    using System;
    using System.Runtime.CompilerServices;

    public delegate void WriteBinaryDataDelegate(PacketHeader header, ByteArray binData, bool udp);
}

