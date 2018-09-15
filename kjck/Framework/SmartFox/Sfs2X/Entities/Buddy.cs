namespace Sfs2X.Entities
{
    using Sfs2X.Entities.Variables;
    using System;
    using System.Collections.Generic;

    public interface Buddy
    {
        void ClearVolatileVariables();
        bool ContainsVariable(string varName);
        List<BuddyVariable> GetOfflineVariables();
        List<BuddyVariable> GetOnlineVariables();
        BuddyVariable GetVariable(string varName);
        void RemoveVariable(string varName);
        void SetVariable(BuddyVariable bVar);
        void SetVariables(ICollection<BuddyVariable> variables);

        int Id { get; set; }

        bool IsBlocked { get; set; }

        bool IsOnline { get; }

        bool IsTemp { get; }

        string Name { get; }

        string NickName { get; }

        string State { get; }

        List<BuddyVariable> Variables { get; }
    }
}

