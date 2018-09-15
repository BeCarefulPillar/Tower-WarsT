namespace Sfs2X.Entities
{
    using Sfs2X.Entities.Managers;
    using Sfs2X.Entities.Variables;
    using System;
    using System.Collections;
    using System.Collections.Generic;

    public interface Room
    {
        void AddUser(User user);
        bool ContainsUser(User user);
        bool ContainsVariable(string name);
        User GetUserById(int id);
        User GetUserByName(string name);
        RoomVariable GetVariable(string name);
        List<RoomVariable> GetVariables();
        void Merge(Room anotherRoom);
        void RemoveUser(User user);
        void SetVariable(RoomVariable roomVariable);
        void SetVariables(ICollection<RoomVariable> roomVariables);

        int Capacity { get; }

        string GroupId { get; }

        int Id { get; }

        bool IsGame { get; set; }

        bool IsHidden { get; set; }

        bool IsJoined { get; set; }

        bool IsManaged { get; set; }

        bool IsPasswordProtected { get; set; }

        int MaxSpectators { get; set; }

        int MaxUsers { get; set; }

        string Name { get; set; }

        List<User> PlayerList { get; }

        Hashtable Properties { get; set; }

        IRoomManager RoomManager { get; set; }

        int SpectatorCount { get; set; }

        List<User> SpectatorList { get; }

        int UserCount { get; set; }

        List<User> UserList { get; }
    }
}

