namespace Sfs2X.Entities.Variables
{
    using Sfs2X.Entities.Data;
    using System;

    public class SFSRoomVariable : SFSUserVariable, RoomVariable, UserVariable
    {
        private bool isPersistent;
        private bool isPrivate;

        public SFSRoomVariable(string name, object val) : base(name, val, -1)
        {
        }

        public SFSRoomVariable(string name, object val, int type) : base(name, val, type)
        {
        }

        public new static RoomVariable FromSFSArray(ISFSArray sfsa)
        {
            return new SFSRoomVariable(sfsa.GetUtfString(0), sfsa.GetElementAt(2), sfsa.GetByte(1)) { IsPrivate = sfsa.GetBool(3), IsPersistent = sfsa.GetBool(4) };
        }

        public override ISFSArray ToSFSArray()
        {
            ISFSArray array = base.ToSFSArray();
            array.AddBool(this.isPrivate);
            array.AddBool(this.isPersistent);
            return array;
        }

        public override string ToString()
        {
            return string.Concat(new object[] { "[RVar: ", base.name, ", type: ", base.type, ", value: ", base.val, ", isPriv: ", this.isPrivate, "]" });
        }

        public bool IsPersistent
        {
            get
            {
                return this.isPersistent;
            }
            set
            {
                this.isPersistent = value;
            }
        }

        public bool IsPrivate
        {
            get
            {
                return this.isPrivate;
            }
            set
            {
                this.isPrivate = value;
            }
        }
    }
}

