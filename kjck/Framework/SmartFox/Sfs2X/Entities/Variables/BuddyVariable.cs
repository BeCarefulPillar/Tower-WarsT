namespace Sfs2X.Entities.Variables
{
    using System;

    public interface BuddyVariable : UserVariable
    {
        bool IsOffline { get; }
    }
}

