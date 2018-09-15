namespace Sfs2X.Entities.Data
{
    using System;

    public class SFSDataWrapper
    {
        private object data;
        private int type;

        public SFSDataWrapper(SFSDataType tp, object data)
        {
            this.type = (int) tp;
            this.data = data;
        }

        public SFSDataWrapper(int type, object data)
        {
            this.type = type;
            this.data = data;
        }

        public object Data
        {
            get
            {
                return this.data;
            }
        }

        public int Type
        {
            get
            {
                return this.type;
            }
        }
    }
}

