#define USE_XML_LINQ
using System;
using System.Collections;
using System.Collections.Generic;
#if USE_XML_LINQ
using Kiol.IO;
using System.Xml.Linq;
#else
using System.Xml;
#endif
using Kiol.Util;

namespace Kiol.Xml
{
    public class XmlDocument
    {
        /// <summary>
        /// 从文件完整路径创建XML文档
        /// </summary>
        /// <param name="filename">xml文件完整路径</param>
        public static XmlDocument CreatFromFile(string filename)
        {
#if USE_XML_LINQ
            if (File.Exists(filename))
            {
                System.IO.StreamReader sr = null;
                try
                {
                    sr = new System.IO.StreamReader(new FileStream(filename, FileMode.Open, FileAccess.Read).Stream, System.Text.Encoding.UTF8);
                    XDocument doc = XDocument.Load(sr);
                    XmlDocument kdoc = new XmlDocument();
                    kdoc.doc = doc;
                    return kdoc;
                }
                catch (Exception e)
                {
                    if (!(e is System.IO.FileNotFoundException))
                    {
                        KLogger.LogWarning("Creat Xml From File [" + filename + "] Error:\n" + e);
                    }
                }
                finally
                {
                    if (sr != null)
                    {
                        sr.Dispose();
#if !NETFX_CORE
                        sr.Close();
#endif
                    }
                }
            }
            return null;
#else
            if (string.IsNullOrEmpty(filename)) return null;

            try
            {

                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.Load(filename);
                XmlDocument kdoc = new XmlDocument();
                kdoc.doc = doc;
                return kdoc;

            }
            catch (Exception e)
            {
                if (!(e is System.IO.FileNotFoundException))
                {
                    Debug.LogWarning("Creat Xml From File [" + filename + "] Error:\n" + e);
                }    
                return null;
            }
#endif
        }
        /// <summary>
        /// 解析XML文本创建XML文档
        /// </summary>
        /// <param name="xml">xml文本</param>
        public static XmlDocument Creat(string xml)
        {
            if (string.IsNullOrEmpty(xml)) return null;
            
            try
            {
#if USE_XML_LINQ
                XDocument doc = XDocument.Parse(xml);
#else
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.LoadXml(xml);
#endif
                XmlDocument kdoc = new XmlDocument();
                kdoc.doc = doc;
                return kdoc;
            }
            catch (Exception e)
            {
                KLogger.LogWarning("Creat Xml From String Error:" + e);
                return null;
            }
        }

#if USE_XML_LINQ
        private XDocument doc;
        private XmlNode firstChild;
#else
        private System.Xml.XmlDocument doc;
        private XmlNode firstChild;
#endif
        /// <summary>
        /// 从完整XML文件路径加载
        /// </summary>
        /// <param name="filename">xml文件路径</param>
        public void Load(string filename)
        {
#if USE_XML_LINQ
            System.IO.StreamReader sr = null;
            try
            {
                sr = new System.IO.StreamReader(new FileStream(filename, FileMode.Open, FileAccess.Read).Stream, System.Text.Encoding.UTF8);
                doc = XDocument.Load(sr);
            }
            catch (System.IO.FileNotFoundException)
            {
                KLogger.LogWarning("Load Xml [" + filename + "] Not Found");
            }
            catch (Exception e)
            {
                KLogger.LogWarning("Load Xml [" + filename + "] Error:\n" + e);
            }
            finally
            {
                if (sr != null)
                {
                    sr.Dispose();
#if !NETFX_CORE
                    sr.Close();
#endif
                }
            }
#else
            if (doc == null) doc = new System.Xml.XmlDocument();
            doc.Load(filename);
#endif
            firstChild = null;
        }
        /// <summary>
        /// 从xml文本加载
        /// </summary>
        /// <param name="xml">xml文本</param>
        public void LoadXml(string xml)
        {
#if USE_XML_LINQ
            doc = XDocument.Parse(xml);
#else
            if (doc == null) doc = new System.Xml.XmlDocument();
            doc.LoadXml(xml);
#endif

            firstChild = null;
        }
        /// <summary>
        /// 获取所有指定名称的子节点
        /// </summary>
        /// <param name="tag">节点名称</param>
        public XmlNodeList GetNodesByTagName(string tag)
        {
#if USE_XML_LINQ
            return new XmlNodeList(doc.Root.Elements(tag));
#else
            return new XmlNodeList(doc != null ? doc.GetElementsByTagName(tag) : null);
#endif
        }
        /// <summary>
        /// 保存XML文档到指定路径
        /// </summary>
        /// <param name="filename">文件完成路径</param>
        public void Save(string filename)
        {
            if (doc != null)
            {
#if USE_XML_LINQ
                System.IO.StreamWriter sw = null;
                try
                {
                    sw = new System.IO.StreamWriter(new FileStream(filename, FileMode.OpenOrCreate, FileAccess.ReadWrite).Stream, System.Text.Encoding.UTF8);
                    doc.Save(sw);
                }
                catch(Exception e)
                {
                    KLogger.LogWarning("Save Xml error:" + e);
                    File.Delete(filename);
                }
                finally
                {
                    if (sw != null)
                    {
                        sw.Dispose();
#if !NETFX_CORE
                        sw.Close();
#endif
                    }
                }
#else
                doc.Save(filename);
#endif
            }
        }
        /// <summary>
        /// 文档的根节点
        /// </summary>
        public XmlNode FirstChild
        {
            get
            {
                if (firstChild == null && doc != null)
                {
#if USE_XML_LINQ
                    firstChild = new XmlNode(doc.Root);
#else
                    System.Xml.XmlNodeList childs = doc.ChildNodes;
                    for (int i = 0; i < childs.Count; i++)
                    {
                        if (childs[i].NodeType != XmlNodeType.XmlDeclaration)
                        {
                            firstChild = new XmlNode(childs[i]);
                            break;
                        }
                    }
#endif
                }
                return firstChild;
            }
        }

        public override string ToString()
        {
            return doc != null ? doc.ToString() : null;
        }
    }
}
