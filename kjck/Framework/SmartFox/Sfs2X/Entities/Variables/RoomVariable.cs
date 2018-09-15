namespace Sfs2X.Entities.Variables
{
    using System;

    public interface RoomVariable : UserVariable
    {
        bool IsPersistent { get; set; }

        bool IsPrivate { get; set; }
    }
}

