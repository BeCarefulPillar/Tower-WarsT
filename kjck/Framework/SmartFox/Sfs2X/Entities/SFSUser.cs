namespace Sfs2X.Entities
{
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Managers;
    using Sfs2X.Entities.Variables;
    using Sfs2X.Exceptions;
    using System;
    using System.Collections.Generic;

    public class SFSUser : User
    {
        protected Vec3D aoiEntryPoint;
        protected int id;
        protected bool isItMe;
        protected bool isModerator;
        protected string name;
        protected Dictionary<int, int> playerIdByRoomId;
        protected int privilegeId;
        protected Dictionary<string, object> properties;
        protected IUserManager userManager;
        protected Dictionary<string, UserVariable> variables;

        public SFSUser(int id, string name)
        {
            this.id = -1;
            this.privilegeId = 0;
            this.Init(id, name, false);
        }

        public SFSUser(int id, string name, bool isItMe)
        {
            this.id = -1;
            this.privilegeId = 0;
            this.Init(id, name, isItMe);
        }

        public bool ContainsVariable(string name)
        {
            return this.variables.ContainsKey(name);
        }

        public static User FromSFSArray(ISFSArray sfsa)
        {
            return FromSFSArray(sfsa, null);
        }

        public static User FromSFSArray(ISFSArray sfsa, Room room)
        {
            User user = new SFSUser(sfsa.GetInt(0), sfsa.GetUtfString(1)) {
                PrivilegeId = sfsa.GetShort(2)
            };
            if (room != null)
            {
                user.SetPlayerId(sfsa.GetShort(3), room);
            }
            ISFSArray sFSArray = sfsa.GetSFSArray(4);
            for (int i = 0; i < sFSArray.Size(); i++)
            {
                user.SetVariable(SFSUserVariable.FromSFSArray(sFSArray.GetSFSArray(i)));
            }
            return user;
        }

        public int GetPlayerId(Room room)
        {
            int num = 0;
            if (this.playerIdByRoomId.ContainsKey(room.Id))
            {
                num = this.playerIdByRoomId[room.Id];
            }
            return num;
        }

        public UserVariable GetVariable(string name)
        {
            if (!this.variables.ContainsKey(name))
            {
                return null;
            }
            return this.variables[name];
        }

        public List<UserVariable> GetVariables()
        {
            return new List<UserVariable>(this.variables.Values);
        }

        private void Init(int id, string name, bool isItMe)
        {
            this.id = id;
            this.name = name;
            this.isItMe = isItMe;
            this.variables = new Dictionary<string, UserVariable>();
            this.properties = new Dictionary<string, object>();
            this.isModerator = false;
            this.playerIdByRoomId = new Dictionary<int, int>();
        }

        public bool IsAdmin()
        {
            return (this.privilegeId == 3);
        }

        public bool IsGuest()
        {
            return (this.privilegeId == 0);
        }

        public bool IsJoinedInRoom(Room room)
        {
            return room.ContainsUser(this);
        }

        public bool IsModerator()
        {
            return (this.privilegeId == 2);
        }

        public bool IsPlayerInRoom(Room room)
        {
            return (this.playerIdByRoomId[room.Id] > 0);
        }

        public bool IsSpectatorInRoom(Room room)
        {
            return (this.playerIdByRoomId[room.Id] < 0);
        }

        public bool IsStandardUser()
        {
            return (this.privilegeId == 1);
        }

        public void RemovePlayerId(Room room)
        {
            this.playerIdByRoomId.Remove(room.Id);
        }

        private void RemoveUserVariable(string varName)
        {
            this.variables.Remove(varName);
        }

        public void SetPlayerId(int id, Room room)
        {
            this.playerIdByRoomId[room.Id] = id;
        }

        public void SetVariable(UserVariable userVariable)
        {
            if (userVariable != null)
            {
                if (userVariable.IsNull())
                {
                    this.variables.Remove(userVariable.Name);
                }
                else
                {
                    this.variables[userVariable.Name] = userVariable;
                }
            }
        }

        public void SetVariables(ICollection<UserVariable> userVariables)
        {
            foreach (UserVariable variable in userVariables)
            {
                this.SetVariable(variable);
            }
        }

        public override string ToString()
        {
            return string.Concat(new object[] { "[User: ", this.name, ", Id: ", this.id, ", isMe: ", this.isItMe, "]" });
        }

        public Vec3D AOIEntryPoint
        {
            get
            {
                return this.aoiEntryPoint;
            }
            set
            {
                this.aoiEntryPoint = value;
            }
        }

        public int Id
        {
            get
            {
                return this.id;
            }
        }

        public bool IsItMe
        {
            get
            {
                return this.isItMe;
            }
        }

        public bool IsPlayer
        {
            get
            {
                return (this.PlayerId > 0);
            }
        }

        public bool IsSpectator
        {
            get
            {
                return !this.IsPlayer;
            }
        }

        public string Name
        {
            get
            {
                return this.name;
            }
        }

        public int PlayerId
        {
            get
            {
                return this.GetPlayerId(this.userManager.SmartFoxClient.LastJoinedRoom);
            }
        }

        public int PrivilegeId
        {
            get
            {
                return this.privilegeId;
            }
            set
            {
                this.privilegeId = value;
            }
        }

        public Dictionary<string, object> Properties
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

        public IUserManager UserManager
        {
            get
            {
                return this.userManager;
            }
            set
            {
                if (this.userManager != null)
                {
                    throw new SFSError("Cannot re-assign the User manager. Already set. User: " + this);
                }
                this.userManager = value;
            }
        }
    }
}

