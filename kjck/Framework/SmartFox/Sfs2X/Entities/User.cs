namespace Sfs2X.Entities
{
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Managers;
    using Sfs2X.Entities.Variables;
    using System;
    using System.Collections.Generic;

    public interface User
    {
        bool ContainsVariable(string name);
        int GetPlayerId(Room room);
        UserVariable GetVariable(string varName);
        List<UserVariable> GetVariables();
        bool IsAdmin();
        bool IsGuest();
        bool IsJoinedInRoom(Room room);
        bool IsModerator();
        bool IsPlayerInRoom(Room room);
        bool IsSpectatorInRoom(Room room);
        bool IsStandardUser();
        void RemovePlayerId(Room room);
        void SetPlayerId(int id, Room room);
        void SetVariable(UserVariable userVariable);
        void SetVariables(ICollection<UserVariable> userVaribles);

        Vec3D AOIEntryPoint { get; set; }

        int Id { get; }

        bool IsItMe { get; }

        bool IsPlayer { get; }

        bool IsSpectator { get; }

        string Name { get; }

        int PlayerId { get; }

        int PrivilegeId { get; set; }

        Dictionary<string, object> Properties { get; set; }

        IUserManager UserManager { get; set; }
    }
}

