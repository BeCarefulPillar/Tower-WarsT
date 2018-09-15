namespace Sfs2X.Bitswarm
{
    using Sfs2X.Entities.Data;
    using System;

    public interface IMessage
    {
        ISFSObject Content { get; set; }

        int Id { get; set; }

        bool IsEncrypted { get; set; }

        bool IsUDP { get; set; }

        long PacketId { get; set; }

        int TargetController { get; set; }
    }
}

