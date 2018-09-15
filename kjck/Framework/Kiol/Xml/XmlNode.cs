#define USE_XML_LINQ
using System.Collections;
using System.Collections.Generic;
#if USE_XML_LINQ
using System.Xml.Linq;
#else
using System.Xml;
#endif

namespace Kiol.Xml
{
    public class XmlNode
    {
        private const string Wildcard = "*";
#if USE_XML_LINQ
        private XElement node;

        public XmlNode(XElement node)
        {
            this.node = node;
        }
#else
        private System.Xml.XmlNode node;

        public XmlNode(System.Xml.XmlNode node)
        {
            this.node = node;
        }
#endif

        /// <summary>
        /// 新建一个指定名称的节点到当前节点子级
        /// </summary>
        /// <param name="name">节点名称</param>
        public XmlNode AddChild(string name)
        {
#if USE_XML_LINQ
            XElement xe = new XElement(name);
            node.Add(xe);
            return new XmlNode(xe);
#else
            return new XmlNode(node.AppendChild(node.OwnerDocument.CreateNode(XmlNodeType.Element, name, "")));
#endif
        }
        /// <summary>
        /// 复制一个节点到当前节点子级
        /// </summary>
        /// <param name="n">节点源</param>
        public void AddChild(XmlNode n)
        {
            if (n != null)
            {
#if USE_XML_LINQ
                node.Add(new XElement(n.node));
#else
                node.AppendChild(node.OwnerDocument.ImportNode(n.node, true));
#endif
            }
        }
        /// <summary>
        /// 添加一条属性到当前节点
        /// </summary>
        /// <param name="name">属性名称</param>
        /// <param name="value">属性值</param>
        public void AddAttribute(string name, string value)
        {
#if USE_XML_LINQ
            node.SetAttributeValue(name, value);
#else
            node.Attributes.Append(node.OwnerDocument.CreateAttribute(name)).Value = value;
#endif
        }

        /// <summary>
        /// 当前节点是否有属性
        /// </summary>
        public bool HasAttributes
        {
            get
            {
#if USE_XML_LINQ
                return node.HasAttributes;
#else
                return node.Attributes.Count > 0;
#endif
            }
        }

        /// <summary>
        /// 获取当前节点的所有属性字典
        /// </summary>
        public Dictionary<string, string> GetAttributeDic()
        {
#if USE_XML_LINQ
            IEnumerable<XAttribute> xac = node.Attributes();
            Dictionary<string, string> dic = new Dictionary<string, string>(8);
            foreach (XAttribute item in xac)
            {
                if (dic.ContainsKey(item.Name.LocalName))
                {
                    dic[item.Name.LocalName] = item.Value;
                }
                else
                {
                    dic.Add(item.Name.LocalName, item.Value);
                }
            }
#else
            Dictionary<string, string> dic = new Dictionary<string, string>(node.Attributes.Count);
            foreach (XmlAttribute att in node.Attributes)
            {
                if(dic.ContainsKey(att.Name))
                {
                    dic[att.Name] = att.Value;
                }
                else
                {
                    dic.Add(att.Name, att.Value);
                }
            }
#endif
            return dic;
        }

        /// <summary>
        /// 获取当前节点的所有属性列表
        /// </summary>
        public List<KeyValuePair<string,string>> GetAttributeList()
        {
#if USE_XML_LINQ
            IEnumerable<XAttribute> xac = node.Attributes();
            List<KeyValuePair<string, string>> list = new List<KeyValuePair<string, string>>(8);
            foreach (XAttribute item in xac)
            {
                list.Add(new KeyValuePair<string, string>(item.Name.LocalName, item.Value));
            }
#else
            List<KeyValuePair<string, string>> list = new List<KeyValuePair<string, string>>(node.Attributes.Count);
            foreach (XmlAttribute att in node.Attributes)
            {
                list.Add(new KeyValuePair<string, string>(att.Name, att.Value));
            }
#endif
            return list;
        }

        /// <summary>
        /// 获取指定名称的属性，若没有则返回 string.Empty
        /// </summary>
        /// <param name="name">属性名称</param>
        public string GetAttribute(string name)
        {
#if USE_XML_LINQ
            XAttribute att = node.Attribute(name);
#else
            System.Xml.XmlAttribute att = node.Attributes[name];
#endif
            return att != null ? att.Value : string.Empty;
        }
        /// <summary>
        /// 设置指定名称的属性的值
        /// </summary>
        /// <param name="name">属性名称</param>
        /// <param name="value">属性值</param>
        public void SetAttribute(string name, string value)
        {
#if USE_XML_LINQ
            XAttribute att = node.Attribute(name);
#else
            System.Xml.XmlAttribute att = node.Attributes[name];
            
#endif
            if (att != null) att.Value = value;
        }
        /// <summary>
        /// 是否存在指定名称的属性
        /// </summary>
        /// <param name="name">属性名称</param>
        public bool ExitsAttribute(string name)
        {
#if USE_XML_LINQ
            return node.Attribute(name) != null;
#else
            return node.Attributes[name] != null;
#endif
        }
        /// <summary>
        /// 搜索指定名称的第一个子节点
        /// </summary>
        /// <param name="tag">节点名称</param>
        public XmlNode SearchSingleNode(string tag)
        {
#if USE_XML_LINQ
            XElement n = Wildcard.Equals(tag) ? node.FirstNode as XElement : node.Element(tag);
#else
            System.Xml.XmlNode n = node.SelectSingleNode(tag);
#endif
            return n != null ? new XmlNode(n) : null;
        }
        /// <summary>
        /// 搜索指定名称 属性名称 的第一个子节点
        /// </summary>
        /// <param name="tag">节点名称</param>
        /// <param name="attName">属性名称</param>
        public XmlNode SearchSingleNode(string tag, string attName)
        {
#if USE_XML_LINQ
            IEnumerable<XElement> xes = Wildcard.Equals(tag) ? node.Elements() : node.Elements(tag);
            if (Wildcard.Equals(attName))
            {
                foreach (XElement item in xes) return new XmlNode(item);
            }
            else
            {
                foreach (XElement item in xes) if (item.Attribute(attName) != null) return new XmlNode(item);
            }
            return null;
#else
            System.Xml.XmlNode snode = node.SelectSingleNode(string.Format("{0}[@{1}]", tag, attName));
            return snode != null ? new XmlNode(snode) : null;
#endif
        }
        /// <summary>
        /// 搜索指定名称 属性名称 属性值 的第一个子节点
        /// </summary>
        /// <param name="tag">节点名称</param>
        /// <param name="attName">属性名称</param>
        /// <param name="attValue">属性值</param>
        public XmlNode SearchSingleNode(string tag, string attName, string attValue)
        {
#if USE_XML_LINQ
            IEnumerable<XElement> xes = Wildcard.Equals(tag) ? node.Elements() : node.Elements(tag);
            if (Wildcard.Equals(attName))
            {
                foreach (XElement item in xes)
                {
                    IEnumerable<XAttribute> xatts = item.Attributes();
                    foreach (XAttribute xa in xatts) if (xa.Value == attValue) return new XmlNode(item);
                }
            }
            else
            {
                foreach (XElement item in xes)
                {
                    XAttribute xa = item.Attribute(attName);
                    if (xa != null && xa.Value == attValue)
                    {
                        return new XmlNode(item);
                    }
                }
            }
            return null;
#else
            System.Xml.XmlNode snode = node.SelectSingleNode(string.Format("{0}[@{1}='{2}']", tag, attName, attValue));
            return snode != null ? new XmlNode(snode) : null;
#endif
        }
        /// <summary>
        /// 搜索指定名称的所有子节点
        /// </summary>
        /// <param name="tag">节点名称</param>
        public XmlNodeList SearchNodes(string tag)
        {
#if USE_XML_LINQ
            return new XmlNodeList(Wildcard.Equals(tag) ? node.Elements() : node.Elements(tag));
#else
            return new XmlNodeList(node.SelectNodes(tag));
#endif
        }
        /// <summary>
        /// 搜索指定名称 属性名称 的所有子节点
        /// </summary>
        /// <param name="tag">节点名称</param>
        /// <param name="attName">属性名称</param>
        public XmlNodeList SearchNodes(string tag, string attName)
        {
#if USE_XML_LINQ
            IEnumerable<XElement> xes = Wildcard.Equals(tag) ? node.Elements() : node.Elements(tag);
            List<XElement> list = new List<XElement>(8);
            if (Wildcard.Equals(attName))
            {
                foreach (XElement item in xes) list.Add(item);
            }
            else
            {
                foreach (XElement item in xes) if (item.Attribute(attName) != null) list.Add(item);
            }
            return new XmlNodeList(list);
#else
            return new XmlNodeList(node.SelectNodes(string.Format("{0}[@{1}]", tag, attName)));
#endif
        }
        /// <summary>
        /// 搜索指定名称 属性名称 属性值 的所有子节点
        /// </summary>
        /// <param name="tag">节点名称</param>
        /// <param name="attName">属性名称</param>
        /// <param name="attValue">属性值</param>
        public XmlNodeList SearchNodes(string tag, string attName, string attValue)
        {
#if USE_XML_LINQ
            IEnumerable<XElement> xes = Wildcard.Equals(tag) ? node.Elements() : node.Elements(tag);
            List<XElement> list = new List<XElement>(8);
            if (Wildcard.Equals(attName))
            {
                foreach (XElement item in xes)
                {
                    IEnumerable<XAttribute> xatts = item.Attributes();
                    foreach (XAttribute xa in xatts)
                    {
                        if (xa.Value == attValue)
                        {
                            list.Add(item);
                            break;
                        }
                    }
                }
            }
            else
            {
                foreach (XElement item in xes)
                {
                    XAttribute xa = item.Attribute(attName);
                    if (xa != null && xa.Value == attValue)
                    {
                        list.Add(item);
                    }
                }
            }
            return new XmlNodeList(list);
#else
            return new XmlNodeList(node.SelectNodes(string.Format("{0}[@{1}='{2}']", tag, attName, attValue)));
#endif
        }
        /// <summary>
        /// 节点名称
        /// </summary>
        public string Name
        {
            get
            {
#if USE_XML_LINQ
                return node.Name.LocalName;
#else
                return node.Name;
#endif
            }
        }
        /// <summary>
        /// 节点内部文本
        /// </summary>
        public string InnerText
        {
            get
            {
#if USE_XML_LINQ
                return node.FirstNode != null ? node.FirstNode.ToString() : "";
#else
                return node.InnerText;
#endif

            }
        }
        /// <summary>
        /// 节点的所有子节点
        /// </summary>
        public XmlNodeList ChildNodes
        {
            get
            {
#if USE_XML_LINQ
                return new XmlNodeList(node.Elements());
#else
                return new XmlNodeList(node.ChildNodes);
#endif

            }
        }

        public override string ToString()
        {
            return node != null ? node.ToString() : null;
        }
    }
}
