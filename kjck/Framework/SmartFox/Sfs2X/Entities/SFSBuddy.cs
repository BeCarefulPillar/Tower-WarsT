namespace Sfs2X.Entities
{
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Variables;
    using System;
    using System.Collections.Generic;

    public class SFSBuddy : Buddy
    {
        protected int id;
        protected bool isBlocked;
        protected bool isTemp;
        protected string name;
        protected Dictionary<string, BuddyVariable> variables;

        public SFSBuddy(int id, string name) : this(id, name, false, false)
        {
        }

        public SFSBuddy(int id, string name, bool isBlocked) : this(id, name, isBlocked, false)
        {
        }

        public SFSBuddy(int id, string name, bool isBlocked, bool isTemp)
        {
            this.variables = new Dictionary<string, BuddyVariable>();
            this.id = id;
            this.name = name;
            this.isBlocked = isBlocked;
            this.variables = new Dictionary<string, BuddyVariable>();
            this.isTemp = isTemp;
        }

        public void ClearVolatileVariables()
        {
            List<string> list = new List<string>();
            foreach (BuddyVariable variable in this.variables.Values)
            {
                if (variable.Name[0] != Convert.ToChar(SFSBuddyVariable.OFFLINE_PREFIX))
                {
                    list.Add(variable.Name);
                }
            }
            foreach (string str in list)
            {
                this.RemoveVariable(str);
            }
        }

        public bool ContainsVariable(string varName)
        {
            return this.variables.ContainsKey(varName);
        }

        public static Buddy FromSFSArray(ISFSArray arr)
        {
            Buddy buddy = new SFSBuddy(arr.GetInt(0), arr.GetUtfString(1), arr.GetBool(2), (arr.Size() > 4) ? arr.GetBool(4) : false);
            ISFSArray sFSArray = arr.GetSFSArray(3);
            for (int i = 0; i < sFSArray.Size(); i++)
            {
                BuddyVariable bVar = SFSBuddyVariable.FromSFSArray(sFSArray.GetSFSArray(i));
                buddy.SetVariable(bVar);
            }
            return buddy;
        }

        public List<BuddyVariable> GetOfflineVariables()
        {
            List<BuddyVariable> list = new List<BuddyVariable>();
            foreach (BuddyVariable variable in this.variables.Values)
            {
                if (variable.Name[0] == Convert.ToChar(SFSBuddyVariable.OFFLINE_PREFIX))
                {
                    list.Add(variable);
                }
            }
            return list;
        }

        public List<BuddyVariable> GetOnlineVariables()
        {
            List<BuddyVariable> list = new List<BuddyVariable>();
            foreach (BuddyVariable variable in this.variables.Values)
            {
                if (variable.Name[0] != Convert.ToChar(SFSBuddyVariable.OFFLINE_PREFIX))
                {
                    list.Add(variable);
                }
            }
            return list;
        }

        public BuddyVariable GetVariable(string varName)
        {
            if (this.variables.ContainsKey(varName))
            {
                return this.variables[varName];
            }
            return null;
        }

        public void RemoveVariable(string varName)
        {
            this.variables.Remove(varName);
        }

        public void SetVariable(BuddyVariable bVar)
        {
            this.variables[bVar.Name] = bVar;
        }

        public void SetVariables(ICollection<BuddyVariable> variables)
        {
            foreach (BuddyVariable variable in variables)
            {
                this.SetVariable(variable);
            }
        }

        public override string ToString()
        {
            return string.Concat(new object[] { "[Buddy: ", this.name, ", id: ", this.id, "]" });
        }

        public int Id
        {
            get
            {
                return this.id;
            }
            set
            {
                this.id = value;
            }
        }

        public bool IsBlocked
        {
            get
            {
                return this.isBlocked;
            }
            set
            {
                this.isBlocked = value;
            }
        }

        public bool IsOnline
        {
            get
            {
                BuddyVariable variable = this.GetVariable(ReservedBuddyVariables.BV_ONLINE);
                return (((variable == null) || variable.GetBoolValue()) && (this.id > -1));
            }
        }

        public bool IsTemp
        {
            get
            {
                return this.isTemp;
            }
        }

        public string Name
        {
            get
            {
                return this.name;
            }
        }

        public string NickName
        {
            get
            {
                BuddyVariable variable = this.GetVariable(ReservedBuddyVariables.BV_NICKNAME);
                return ((variable == null) ? null : variable.GetStringValue());
            }
        }

        public string State
        {
            get
            {
                BuddyVariable variable = this.GetVariable(ReservedBuddyVariables.BV_STATE);
                return ((variable == null) ? null : variable.GetStringValue());
            }
        }

        public List<BuddyVariable> Variables
        {
            get
            {
                return new List<BuddyVariable>(this.variables.Values);
            }
        }
    }
}

