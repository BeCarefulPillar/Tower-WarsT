namespace Sfs2X.Entities.Managers
{
    using Sfs2X;
    using Sfs2X.Entities;
    using System;
    using System.Collections.Generic;

    public class SFSRoomManager : IRoomManager
    {
        private List<string> groups;
        private string ownerZone;
        private Dictionary<int, Room> roomsById;
        private Dictionary<string, Room> roomsByName;
        protected SmartFox smartFox;

        public SFSRoomManager(SmartFox sfs)
        {
            this.smartFox = sfs;
            this.groups = new List<string>();
            this.roomsById = new Dictionary<int, Room>();
            this.roomsByName = new Dictionary<string, Room>();
        }

        public void AddGroup(string groupId)
        {
            this.groups.Add(groupId);
        }

        public void AddRoom(Room room)
        {
            this.AddRoom(room, true);
        }

        public void AddRoom(Room room, bool addGroupIfMissing)
        {
            this.roomsById[room.Id] = room;
            this.roomsByName[room.Name] = room;
            if (addGroupIfMissing)
            {
                if (!this.ContainsGroup(room.GroupId))
                {
                    this.AddGroup(room.GroupId);
                }
            }
            else
            {
                room.IsManaged = false;
            }
        }

        public void ChangeRoomCapacity(Room room, int maxUsers, int maxSpect)
        {
            room.MaxUsers = maxUsers;
            room.MaxSpectators = maxSpect;
        }

        public void ChangeRoomName(Room room, string newName)
        {
            string name = room.Name;
            room.Name = newName;
            this.roomsByName[newName] = room;
            this.roomsByName.Remove(name);
        }

        public void ChangeRoomPasswordState(Room room, bool isPassProtected)
        {
            room.IsPasswordProtected = isPassProtected;
        }

        public bool ContainsGroup(string groupId)
        {
            return this.groups.Contains(groupId);
        }

        public bool ContainsRoom(object idOrName)
        {
            if (idOrName is int)
            {
                return this.roomsById.ContainsKey((int) idOrName);
            }
            return this.roomsByName.ContainsKey((string) idOrName);
        }

        public bool ContainsRoomInGroup(object idOrName, string groupId)
        {
            List<Room> roomListFromGroup = this.GetRoomListFromGroup(groupId);
            bool flag = idOrName is int;
            foreach (Room room in roomListFromGroup)
            {
                if (flag)
                {
                    if (room.Id == ((int) idOrName))
                    {
                        return true;
                    }
                }
                else if (room.Name == ((string) idOrName))
                {
                    return true;
                }
            }
            return false;
        }

        public List<Room> GetJoinedRooms()
        {
            List<Room> list = new List<Room>();
            foreach (Room room in this.roomsById.Values)
            {
                if (room.IsJoined)
                {
                    list.Add(room);
                }
            }
            return list;
        }

        public Room GetRoomById(int id)
        {
            if (!this.roomsById.ContainsKey(id))
            {
                return null;
            }
            return this.roomsById[id];
        }

        public Room GetRoomByName(string name)
        {
            if (!this.roomsByName.ContainsKey(name))
            {
                return null;
            }
            return this.roomsByName[name];
        }

        public int GetRoomCount()
        {
            return this.roomsById.Count;
        }

        public List<string> GetRoomGroups()
        {
            return this.groups;
        }

        public List<Room> GetRoomList()
        {
            return new List<Room>(this.roomsById.Values);
        }

        public List<Room> GetRoomListFromGroup(string groupId)
        {
            List<Room> list = new List<Room>();
            foreach (Room room in this.roomsById.Values)
            {
                if (room.GroupId == groupId)
                {
                    list.Add(room);
                }
            }
            return list;
        }

        public List<Room> GetUserRooms(User user)
        {
            List<Room> list = new List<Room>();
            foreach (Room room in this.roomsById.Values)
            {
                if (room.ContainsUser(user))
                {
                    list.Add(room);
                }
            }
            return list;
        }

        public void RemoveGroup(string groupId)
        {
            this.groups.Remove(groupId);
            List<Room> roomListFromGroup = this.GetRoomListFromGroup(groupId);
            foreach (Room room in roomListFromGroup)
            {
                if (!room.IsJoined)
                {
                    this.RemoveRoom(room);
                }
                else
                {
                    room.IsManaged = false;
                }
            }
        }

        public void RemoveRoom(Room room)
        {
            this.RemoveRoom(room.Id, room.Name);
        }

        private void RemoveRoom(int id, string name)
        {
            this.roomsById.Remove(id);
            this.roomsByName.Remove(name);
        }

        public void RemoveRoomById(int id)
        {
            if (this.roomsById.ContainsKey(id))
            {
                Room room = this.roomsById[id];
                this.RemoveRoom(id, room.Name);
            }
        }

        public void RemoveRoomByName(string name)
        {
            if (this.roomsByName.ContainsKey(name))
            {
                Room room = this.roomsByName[name];
                this.RemoveRoom(room.Id, name);
            }
        }

        public void RemoveUser(User user)
        {
            foreach (Room room in this.roomsById.Values)
            {
                if (room.ContainsUser(user))
                {
                    room.RemoveUser(user);
                }
            }
        }

        public Room ReplaceRoom(Room room)
        {
            return this.ReplaceRoom(room, true);
        }

        public Room ReplaceRoom(Room room, bool addToGroupIfMissing)
        {
            Room roomById = this.GetRoomById(room.Id);
            if (roomById != null)
            {
                roomById.Merge(room);
                return roomById;
            }
            this.AddRoom(room, addToGroupIfMissing);
            return room;
        }

        public string OwnerZone
        {
            get
            {
                return this.ownerZone;
            }
            set
            {
                this.ownerZone = value;
            }
        }

        public SmartFox SmartFoxClient
        {
            get
            {
                return this.smartFox;
            }
        }
    }
}

