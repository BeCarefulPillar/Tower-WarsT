namespace Sfs2X.Entities
{
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Managers;
    using Sfs2X.Entities.Variables;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections;
    using System.Collections.Generic;

    public class SFSRoom : Room
    {
        protected string groupId;
        protected int id;
        protected bool isGame;
        protected bool isHidden;
        protected bool isJoined;
        protected bool isManaged;
        protected bool isPasswordProtected;
        protected int maxSpectators;
        protected int maxUsers;
        protected string name;
        protected Hashtable properties;
        protected IRoomManager roomManager;
        protected int specCount;
        protected int userCount;
        protected IUserManager userManager;
        protected Dictionary<string, RoomVariable> variables;

        public SFSRoom(int id, string name)
        {
            this.Init(id, name, "default");
        }

        public SFSRoom(int id, string name, string groupId)
        {
            this.Init(id, name, groupId);
        }

        public void AddUser(User user)
        {
            this.userManager.AddUser(user);
        }

        public bool ContainsUser(User user)
        {
            return this.userManager.ContainsUser(user);
        }

        public bool ContainsVariable(string name)
        {
            return this.variables.ContainsKey(name);
        }

        public static Room FromSFSArray(ISFSArray sfsa)
        {
            bool flag = sfsa.Size() == 14;
            Room room = null;
            if (flag)
            {
                room = new MMORoom(sfsa.GetInt(0), sfsa.GetUtfString(1), sfsa.GetUtfString(2));
            }
            else
            {
                room = new SFSRoom(sfsa.GetInt(0), sfsa.GetUtfString(1), sfsa.GetUtfString(2));
            }
            room.IsGame = sfsa.GetBool(3);
            room.IsHidden = sfsa.GetBool(4);
            room.IsPasswordProtected = sfsa.GetBool(5);
            room.UserCount = sfsa.GetShort(6);
            room.MaxUsers = sfsa.GetShort(7);
            ISFSArray sFSArray = sfsa.GetSFSArray(8);
            if (sFSArray.Size() > 0)
            {
                List<RoomVariable> roomVariables = new List<RoomVariable>();
                for (int i = 0; i < sFSArray.Size(); i++)
                {
                    roomVariables.Add(SFSRoomVariable.FromSFSArray(sFSArray.GetSFSArray(i)));
                }
                room.SetVariables(roomVariables);
            }
            if (room.IsGame)
            {
                room.SpectatorCount = sfsa.GetShort(9);
                room.MaxSpectators = sfsa.GetShort(10);
            }
            if (flag)
            {
                MMORoom room2 = room as MMORoom;
                room2.DefaultAOI = Vec3D.fromArray(sfsa.GetElementAt(11));
                if (!sfsa.IsNull(13))
                {
                    room2.LowerMapLimit = Vec3D.fromArray(sfsa.GetElementAt(12));
                    room2.HigherMapLimit = Vec3D.fromArray(sfsa.GetElementAt(13));
                }
            }
            return room;
        }

        public User GetUserById(int id)
        {
            return this.userManager.GetUserById(id);
        }

        public User GetUserByName(string name)
        {
            return this.userManager.GetUserByName(name);
        }

        public RoomVariable GetVariable(string name)
        {
            if (!this.variables.ContainsKey(name))
            {
                return null;
            }
            return this.variables[name];
        }

        public List<RoomVariable> GetVariables()
        {
            return new List<RoomVariable>(this.variables.Values);
        }

        private void Init(int id, string name, string groupId)
        {
            this.id = id;
            this.name = name;
            this.groupId = groupId;
            this.isJoined = this.isGame = this.isHidden = false;
            this.isManaged = true;
            this.userCount = this.specCount = 0;
            this.variables = new Dictionary<string, RoomVariable>();
            this.properties = new Hashtable();
            this.userManager = new SFSUserManager(this);
        }

        public void Merge(Room anotherRoom)
        {
            this.variables.Clear();
            foreach (RoomVariable variable in anotherRoom.GetVariables())
            {
                this.variables[variable.Name] = variable;
            }
            this.userManager.ClearAll();
            foreach (User user in anotherRoom.UserList)
            {
                this.userManager.AddUser(user);
            }
        }

        public void RemoveUser(User user)
        {
            this.userManager.RemoveUser(user);
        }

        private void RemoveUserVariable(string varName)
        {
            this.variables.Remove(varName);
        }

        public void SetVariable(RoomVariable roomVariable)
        {
            if (roomVariable.IsNull())
            {
                this.variables.Remove(roomVariable.Name);
            }
            else
            {
                this.variables[roomVariable.Name] = roomVariable;
            }
        }

        public void SetVariables(ICollection<RoomVariable> roomVariables)
        {
            foreach (RoomVariable variable in roomVariables)
            {
                this.SetVariable(variable);
            }
        }

        public override string ToString()
        {
            return string.Concat(new object[] { "[Room: ", this.name, ", Id: ", this.id, ", GroupId: ", this.groupId, "]" });
        }

        public int Capacity
        {
            get
            {
                return (this.maxUsers + this.maxSpectators);
            }
        }

        public string GroupId
        {
            get
            {
                return this.groupId;
            }
        }

        public int Id
        {
            get
            {
                return this.id;
            }
        }

        public bool IsGame
        {
            get
            {
                return this.isGame;
            }
            set
            {
                this.isGame = value;
            }
        }

        public bool IsHidden
        {
            get
            {
                return this.isHidden;
            }
            set
            {
                this.isHidden = value;
            }
        }

        public bool IsJoined
        {
            get
            {
                return this.isJoined;
            }
            set
            {
                this.isJoined = value;
            }
        }

        public bool IsManaged
        {
            get
            {
                return this.isManaged;
            }
            set
            {
                this.isManaged = value;
            }
        }

        public bool IsPasswordProtected
        {
            get
            {
                return this.isPasswordProtected;
            }
            set
            {
                this.isPasswordProtected = value;
            }
        }

        public int MaxSpectators
        {
            get
            {
                return this.maxSpectators;
            }
            set
            {
                this.maxSpectators = value;
            }
        }

        public int MaxUsers
        {
            get
            {
                return this.maxUsers;
            }
            set
            {
                this.maxUsers = value;
            }
        }

        public string Name
        {
            get
            {
                return this.name;
            }
            set
            {
                this.name = value;
            }
        }

        public List<User> PlayerList
        {
            get
            {
                List<User> list = new List<User>();
                foreach (User user in this.userManager.GetUserList())
                {
                    if (user.IsPlayerInRoom(this))
                    {
                        list.Add(user);
                    }
                }
                return list;
            }
        }

        public Hashtable Properties
        {
            get
            {
                return this.properties;
            }
            set
            {
                this.properties = value;
            }
        }

        public IRoomManager RoomManager
        {
            get
            {
                return this.roomManager;
            }
            set
            {
                if (this.roomManager != null)
                {
                    throw new SFSError("Room manager already assigned. Room: " + this);
                }
                this.roomManager = value;
            }
        }

        public int SpectatorCount
        {
            get
            {
                if (!this.isGame)
                {
                    return 0;
                }
                if (this.isJoined)
                {
                    return this.SpectatorList.Count;
                }
                return this.specCount;
            }
            set
            {
                this.specCount = value;
            }
        }

        public List<User> SpectatorList
        {
            get
            {
                List<User> list = new List<User>();
                foreach (User user in this.userManager.GetUserList())
                {
                    if (user.IsSpectatorInRoom(this))
                    {
                        list.Add(user);
                    }
                }
                return list;
            }
        }

        public int UserCount
        {
            get
            {
                if (!this.isJoined)
                {
                    return this.userCount;
                }
                if (this.isGame)
                {
                    return this.PlayerList.Count;
                }
                return this.userManager.UserCount;
            }
            set
            {
                this.userCount = value;
            }
        }

        public List<User> UserList
        {
            get
            {
                return this.userManager.GetUserList();
            }
        }
    }
}

