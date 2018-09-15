namespace Sfs2X.Entities.Managers
{
    using Sfs2X;
    using Sfs2X.Entities;
    using System;
    using System.Collections.Generic;

    public interface IRoomManager
    {
        void AddGroup(string groupId);
        void AddRoom(Room room);
        void AddRoom(Room room, bool addGroupIfMissing);
        void ChangeRoomCapacity(Room room, int maxUsers, int maxSpect);
        void ChangeRoomName(Room room, string newName);
        void ChangeRoomPasswordState(Room room, bool isPassProtected);
        bool ContainsGroup(string groupId);
        bool ContainsRoom(object idOrName);
        bool ContainsRoomInGroup(object idOrName, string groupId);
        List<Room> GetJoinedRooms();
        Room GetRoomById(int id);
        Room GetRoomByName(string name);
        int GetRoomCount();
        List<string> GetRoomGroups();
        List<Room> GetRoomList();
        List<Room> GetRoomListFromGroup(string groupId);
        List<Room> GetUserRooms(User user);
        void RemoveGroup(string groupId);
        void RemoveRoom(Room room);
        void RemoveRoomById(int id);
        void RemoveRoomByName(string name);
        void RemoveUser(User user);
        Room ReplaceRoom(Room room);
        Room ReplaceRoom(Room room, bool addToGroupIfMissing);

        string OwnerZone { get; }

        SmartFox SmartFoxClient { get; }
    }
}

