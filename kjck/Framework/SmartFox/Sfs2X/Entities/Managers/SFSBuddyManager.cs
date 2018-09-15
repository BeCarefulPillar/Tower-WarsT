namespace Sfs2X.Entities.Managers
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Entities.Variables;
    using System;
    using System.Collections.Generic;

    public class SFSBuddyManager : IBuddyManager
    {
        protected Dictionary<string, Buddy> buddiesByName = new Dictionary<string, Buddy>();
        private List<string> buddyStates;
        protected bool inited = false;
        protected bool myOnlineState;
        protected Dictionary<string, BuddyVariable> myVariables = new Dictionary<string, BuddyVariable>();

        public SFSBuddyManager(SmartFox sfs)
        {
        }

        public void AddBuddy(Buddy buddy)
        {
            this.buddiesByName.Add(buddy.Name, buddy);
        }

        public void ClearAll()
        {
            this.buddiesByName.Clear();
        }

        public bool ContainsBuddy(string name)
        {
            return this.buddiesByName.ContainsKey(name);
        }

        public Buddy GetBuddyById(int id)
        {
            if (id > -1)
            {
                foreach (Buddy buddy in this.buddiesByName.Values)
                {
                    if (buddy.Id == id)
                    {
                        return buddy;
                    }
                }
            }
            return null;
        }

        public Buddy GetBuddyByName(string name)
        {
            if (this.buddiesByName.ContainsKey(name))
            {
                return this.buddiesByName[name];
            }
            return null;
        }

        public Buddy GetBuddyByNickName(string nickName)
        {
            foreach (Buddy buddy in this.buddiesByName.Values)
            {
                if (buddy.NickName == nickName)
                {
                    return buddy;
                }
            }
            return null;
        }

        public BuddyVariable GetMyVariable(string varName)
        {
            if (this.myVariables.ContainsKey(varName))
            {
                return this.myVariables[varName];
            }
            return null;
        }

        public Buddy RemoveBuddyById(int id)
        {
            Buddy buddyById = this.GetBuddyById(id);
            if (buddyById != null)
            {
                this.buddiesByName.Remove(buddyById.Name);
            }
            return buddyById;
        }

        public Buddy RemoveBuddyByName(string name)
        {
            Buddy buddyByName = this.GetBuddyByName(name);
            if (buddyByName != null)
            {
                this.buddiesByName.Remove(name);
            }
            return buddyByName;
        }

        public void SetMyVariable(BuddyVariable bVar)
        {
            this.myVariables[bVar.Name] = bVar;
        }

        public List<Buddy> BuddyList
        {
            get
            {
                return new List<Buddy>(this.buddiesByName.Values);
            }
        }

        public List<string> BuddyStates
        {
            get
            {
                return this.buddyStates;
            }
            set
            {
                this.buddyStates = value;
            }
        }

        public bool Inited
        {
            get
            {
                return this.inited;
            }
            set
            {
                this.inited = value;
            }
        }

        public string MyNickName
        {
            get
            {
                BuddyVariable myVariable = this.GetMyVariable(ReservedBuddyVariables.BV_NICKNAME);
                return ((myVariable != null) ? myVariable.GetStringValue() : null);
            }
            set
            {
                this.SetMyVariable(new SFSBuddyVariable(ReservedBuddyVariables.BV_NICKNAME, value));
            }
        }

        public bool MyOnlineState
        {
            get
            {
                if (!this.inited)
                {
                    return false;
                }
                bool boolValue = true;
                BuddyVariable myVariable = this.GetMyVariable(ReservedBuddyVariables.BV_ONLINE);
                if (myVariable != null)
                {
                    boolValue = myVariable.GetBoolValue();
                }
                return boolValue;
            }
            set
            {
                this.SetMyVariable(new SFSBuddyVariable(ReservedBuddyVariables.BV_ONLINE, value));
            }
        }

        public string MyState
        {
            get
            {
                BuddyVariable myVariable = this.GetMyVariable(ReservedBuddyVariables.BV_STATE);
                return ((myVariable != null) ? myVariable.GetStringValue() : null);
            }
            set
            {
                this.SetMyVariable(new SFSBuddyVariable(ReservedBuddyVariables.BV_STATE, value));
            }
        }

        public List<BuddyVariable> MyVariables
        {
            get
            {
                return new List<BuddyVariable>(this.myVariables.Values);
            }
            set
            {
                foreach (BuddyVariable variable in value)
                {
                    this.SetMyVariable(variable);
                }
            }
        }

        public List<Buddy> OfflineBuddies
        {
            get
            {
                List<Buddy> list = new List<Buddy>();
                foreach (Buddy buddy in this.buddiesByName.Values)
                {
                    if (!buddy.IsOnline)
                    {
                        list.Add(buddy);
                    }
                }
                return list;
            }
        }

        public List<Buddy> OnlineBuddies
        {
            get
            {
                List<Buddy> list = new List<Buddy>();
                foreach (Buddy buddy in this.buddiesByName.Values)
                {
                    if (buddy.IsOnline)
                    {
                        list.Add(buddy);
                    }
                }
                return list;
            }
        }
    }
}

