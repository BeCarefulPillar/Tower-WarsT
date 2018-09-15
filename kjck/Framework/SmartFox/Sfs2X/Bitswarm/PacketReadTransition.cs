namespace Sfs2X.Bitswarm
{
    using System;

    public enum PacketReadTransition
    {
        HeaderReceived,
        SizeReceived,
        IncompleteSize,
        WholeSizeReceived,
        PacketFinished,
        InvalidData,
        InvalidDataFinished
    }
}

