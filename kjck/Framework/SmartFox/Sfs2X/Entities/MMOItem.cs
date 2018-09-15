namespace Sfs2X.Entities
{
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Variables;
    using System;
    using System.Collections.Generic;

    public class MMOItem : IMMOItem
    {
        private Vec3D aoiEntryPoint;
        private int id;
        private Dictionary<string, IMMOItemVariable> variables = new Dictionary<string, IMMOItemVariable>();

        public MMOItem(int id)
        {
            this.id = id;
        }

        public bool ContainsVariable(string name)
        {
            return this.variables.ContainsKey(name);
        }

        public static IMMOItem FromSFSArray(ISFSArray encodedItem)
        {
            IMMOItem item = new MMOItem(encodedItem.GetInt(0));
            ISFSArray sFSArray = encodedItem.GetSFSArray(1);
            for (int i = 0; i < sFSArray.Size(); i++)
            {
                item.SetVariable(MMOItemVariable.FromSFSArray(sFSArray.GetSFSArray(i)));
            }
            return item;
        }

        public IMMOItemVariable GetVariable(string name)
        {
            return this.variables[name];
        }

        public List<IMMOItemVariable> GetVariables()
        {
            return new List<IMMOItemVariable>(this.variables.Values);
        }

        public void SetVariable(IMMOItemVariable variable)
        {
            if (variable.IsNull())
            {
                this.variables.Remove(variable.Name);
            }
            else
            {
                this.variables[variable.Name] = variable;
            }
        }

        public void SetVariables(List<IMMOItemVariable> variables)
        {
            foreach (IMMOItemVariable variable in variables)
            {
                this.SetVariable(variable);
            }
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
    }
}

