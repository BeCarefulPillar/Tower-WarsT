namespace Sfs2X.Entities.Managers
{
    using Sfs2X.Entities;
    using Sfs2X.Entities.Variables;
    using System;
    using System.Collections.Generic;

    public interface IBuddyManager
    {
        void AddBuddy(Buddy buddy);
        void ClearAll();
        bool ContainsBuddy(string name);
        Buddy GetBuddyById(int id);
        Buddy GetBuddyByName(string name);
        Buddy GetBuddyByNickName(string nickName);
        BuddyVariable GetMyVariable(string varName);
        Buddy RemoveBuddyById(int id);
        Buddy RemoveBuddyByName(string name);
        void SetMyVariable(BuddyVariable bVar);

        List<Buddy> BuddyList { get; }

        List<string> BuddyStates { get; set; }

        bool Inited { get; set; }

        string MyNickName { get; set; }

        bool MyOnlineState { get; set; }

        string MyState { get; set; }

        List<BuddyVariable> MyVariables { get; set; }

        List<Buddy> OfflineBuddies { get; }

        List<Buddy> OnlineBuddies { get; }
    }
}

