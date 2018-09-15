namespace Sfs2X.Entities.Managers
{
    using Sfs2X;
    using Sfs2X.Entities;
    using System;
    using System.Collections.Generic;

    public class SFSGlobalUserManager : SFSUserManager, IUserManager
    {
        private Dictionary<User, int> roomRefCount;

        public SFSGlobalUserManager(Room room) : base(room)
        {
            this.roomRefCount = new Dictionary<User, int>();
        }

        public SFSGlobalUserManager(SmartFox sfs) : base(sfs)
        {
            this.roomRefCount = new Dictionary<User, int>();
        }

        public override void AddUser(User user)
        {
            if (!this.roomRefCount.ContainsKey(user))
            {
                base.AddUser(user);
                this.roomRefCount[user] = 1;
            }
            else
            {
                this.roomRefCount[user]++;
                //Dictionary<User, int> dictionary;
                //User user2;
                //(dictionary = this.roomRefCount)[user2 = user] = dictionary[user2] + 1;
            }
        }

        public override void RemoveUser(User user)
        {
            this.RemoveUserReference(user, false);
        }

        public void RemoveUserReference(User user, bool disconnected)
        {
            if (this.roomRefCount.ContainsKey(user))
            {
                if (this.roomRefCount[user] < 1)
                {
                    base.LogWarn("GlobalUserManager RefCount is already at zero. User: " + user);
                }
                else
                {
                    //Dictionary<User, int> dictionary;
                    //User user2;
                    //(dictionary = this.roomRefCount)[user2 = user] = dictionary[user2] - 1;
                    this.roomRefCount[user]--;
                    if ((this.roomRefCount[user] == 0) || disconnected)
                    {
                        base.RemoveUser(user);
                        this.roomRefCount.Remove(user);
                    }
                }
            }
            else
            {
                base.LogWarn("Can't remove User from GlobalUserManager. RefCount missing. User: " + user);
            }
        }
    }
}

