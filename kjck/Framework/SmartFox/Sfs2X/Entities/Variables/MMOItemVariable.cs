namespace Sfs2X.Entities.Variables
{
    using Sfs2X.Entities.Data;
    using System;

    public class MMOItemVariable : SFSUserVariable, IMMOItemVariable, UserVariable
    {
        public MMOItemVariable(string name, object val) : base(name, val, -1)
        {
        }

        public MMOItemVariable(string name, object val, int type) : base(name, val, type)
        {
        }

        public new static IMMOItemVariable FromSFSArray(ISFSArray sfsa)
        {
            return new MMOItemVariable(sfsa.GetUtfString(0), sfsa.GetElementAt(2), sfsa.GetByte(1));
        }
    }
}

