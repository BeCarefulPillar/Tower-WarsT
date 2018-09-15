namespace Sfs2X.Entities.Data
{
    using System;
    using System.Collections;
    using System.Collections.Generic;

    public class SFSArrayEnumerator : IEnumerator
    {
        private int cursorIndex;
        private List<SFSDataWrapper> data;

        public SFSArrayEnumerator(List<SFSDataWrapper> data)
        {
            this.data = data;
            this.cursorIndex = -1;
        }

        bool IEnumerator.MoveNext()
        {
            if (this.cursorIndex < this.data.Count)
            {
                this.cursorIndex++;
            }
            return (this.cursorIndex != this.data.Count);
        }

        void IEnumerator.Reset()
        {
            this.cursorIndex = -1;
        }

        object IEnumerator.Current
        {
            get
            {
                if ((this.cursorIndex < 0) || (this.cursorIndex == this.data.Count))
                {
                    throw new InvalidOperationException();
                }
                return this.data[this.cursorIndex].Data;
            }
        }
    }
}

