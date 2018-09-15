namespace Sfs2X.Entities.Managers
{
    using Sfs2X;
    using Sfs2X.Entities;
    using System;
    using System.Collections.Generic;

    public interface IUserManager
    {
        void AddUser(User user);
        void ClearAll();
        bool ContainsUser(User user);
        bool ContainsUserId(int userId);
        bool ContainsUserName(string userName);
        User GetUserById(int userId);
        User GetUserByName(string userName);
        List<User> GetUserList();
        void RemoveUser(User user);
        void RemoveUserById(int id);

        SmartFox SmartFoxClient { get; }

        int UserCount { get; }
    }
}

