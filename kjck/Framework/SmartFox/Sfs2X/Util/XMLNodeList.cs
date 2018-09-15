namespace Sfs2X.Util
{
    using System;
    using System.Collections;

    public class XMLNodeList : ArrayList
    {
        public XMLNode Pop()
        {
            XMLNode node = null;
            node = (XMLNode) this[this.Count - 1];
            this.Remove(node);
            return node;
        }

        public int Push(XMLNode item)
        {
            this.Add(item);
            return this.Count;
        }
    }
}

