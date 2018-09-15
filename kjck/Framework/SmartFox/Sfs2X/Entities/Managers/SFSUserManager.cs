namespace Sfs2X.Entities.Managers
{
    using Sfs2X;
    using Sfs2X.Entities;
    using System;
    using System.Collections.Generic;

    public class SFSUserManager : IUserManager
    {
        protected Room room;
        protected SmartFox sfs;
        private Dictionary<int, User> usersById;
        private Dictionary<string, User> usersByName;

        public SFSUserManager(Room room)
        {
            this.room = room;
            this.usersByName = new Dictionary<string, User>();
            this.usersById = new Dictionary<int, User>();
        }

        public SFSUserManager(SmartFox sfs)
        {
            this.sfs = sfs;
            this.usersByName = new Dictionary<string, User>();
            this.usersById = new Dictionary<int, User>();
        }

        public virtual void AddUser(User user)
        {
            if (this.usersById.ContainsKey(user.Id))
            {
                this.LogWarn("Unexpected: duplicate user in UserManager: " + user);
            }
            this.AddUserInternal(user);
        }

        protected void AddUserInternal(User user)
        {
            this.usersByName[user.Name] = user;
            this.usersById[user.Id] = user;
        }

        public void ClearAll()
        {
            this.usersByName = new Dictionary<string, User>();
            this.usersById = new Dictionary<int, User>();
        }

        public bool ContainsUser(User user)
        {
            return this.usersByName.ContainsValue(user);
        }

        public bool ContainsUserId(int userId)
        {
            return this.usersById.ContainsKey(userId);
        }

        public bool ContainsUserName(string userName)
        {
            return this.usersByName.ContainsKey(userName);
        }

        public User GetUserById(int userId)
        {
            if (!this.usersById.ContainsKey(userId))
            {
                return null;
            }
            return this.usersById[userId];
        }

        public User GetUserByName(string userName)
        {
            if (!this.usersByName.ContainsKey(userName))
            {
                return null;
            }
            return this.usersByName[userName];
        }

        public List<User> GetUserList()
        {
            return new List<User>(this.usersById.Values);
        }

        protected void LogWarn(string msg)
        {
            if (this.sfs != null)
            {
                this.sfs.Log.Warn(new string[] { msg });
            }
            else if ((this.room != null) && (this.room.RoomManager != null))
            {
                this.room.RoomManager.SmartFoxClient.Log.Warn(new string[] { msg });
            }
        }

        public virtual void RemoveUser(User user)
        {
            this.usersByName.Remove(user.Name);
            this.usersById.Remove(user.Id);
        }

        public void RemoveUserById(int id)
        {
            if (this.usersById.ContainsKey(id))
            {
                User user = this.usersById[id];
                this.RemoveUser(user);
            }
        }

        public SmartFox SmartFoxClient
        {
            get
            {
                return this.sfs;
            }
        }

        public int UserCount
        {
            get
            {
                return this.usersById.Count;
            }
        }
    }
}

