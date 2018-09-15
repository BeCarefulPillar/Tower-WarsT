namespace Sfs2X.Bitswarm
{
    using System;

    public enum PacketReadState
    {
        WAIT_NEW_PACKET,
        WAIT_DATA_SIZE,
        WAIT_DATA_SIZE_FRAGMENT,
        WAIT_DATA,
        INVALID_DATA
    }
}

