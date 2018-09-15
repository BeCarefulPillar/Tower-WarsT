#define USE_XML_LINQ
using System.Collections;
using System.Collections.Generic;
#if USE_XML_LINQ
using System.Xml.Linq;
#endif

namespace Kiol.Xml
{
    public class XmlNodeList : IEnumerable
    {
        private List<XmlNode> list;

#if USE_XML_LINQ
        public XmlNodeList(IEnumerable<XElement> elements)
        {
            if (elements == null)
            {
                list = new List<XmlNode>(0);
            }
            else
            {
                list = new List<XmlNode>(8);
                foreach (XElement item in elements)
                {
                    if (item == null) continue;
                    list.Add(new XmlNode(item));
                }
            }
        }
#else
        public XmlNodeList(System.Xml.XmlNodeList nodeList)
        {
            if (nodeList != null)
            {
                list = new List<XmlNode>(nodeList.Count);
                for (int i = 0; i < nodeList.Count; i++)
                {
                    list.Add(new XmlNode(nodeList[i]));
                }
            }
            else
            {
                list = new List<XmlNode>(0);
            }
        }
#endif
        /// <summary>
        /// 节点数量
        /// </summary>
        public int Count { get { return list.Count; } }

        public XmlNode this[int i] { get { return list[i]; } }

        public List<XmlNode> Find(System.Predicate<XmlNode> match) { return list.FindAll(match); }

        public IEnumerator GetEnumerator() { return list.GetEnumerator(); }
    }
}
