namespace Sfs2X.Entities.Invitation
{
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using System;

    public interface Invitation
    {
        int Id { get; set; }

        User Invitee { get; }

        User Inviter { get; }

        ISFSObject Params { get; }

        int SecondsForAnswer { get; }
    }
}

