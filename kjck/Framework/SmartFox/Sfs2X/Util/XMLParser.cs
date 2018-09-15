namespace Sfs2X.Util
{
    using System;
    using System.Collections;

    public class XMLParser
    {
        private char DASH = '-';
        private char EQUALS = '=';
        private char EXCLAMATION = '!';
        private char GT = '>';
        private char LT = '<';
        private char QMARK = '?';
        private char QUOTE = '"';
        private char QUOTE2 = '\'';
        private char SLASH = '/';
        private char SPACE = ' ';
        private char SQR = ']';

        public XMLNode Parse(string content)
        {
            XMLNode node = new XMLNode();
            node["_text"] = "";
            bool flag = false;
            bool flag2 = false;
            bool flag3 = false;
            bool flag4 = false;
            bool flag5 = false;
            string str = "";
            string str2 = "";
            string str3 = "";
            string str4 = "";
            bool flag6 = false;
            bool flag7 = false;
            bool flag8 = false;
            XMLNodeList list = new XMLNodeList();
            XMLNode item = node;
            for (int i = 0; i < content.Length; i++)
            {
                char ch = content[i];
                char ch2 = '~';
                char ch3 = '~';
                char ch4 = '~';
                if ((i + 1) < content.Length)
                {
                    ch2 = content[i + 1];
                }
                if ((i + 2) < content.Length)
                {
                    ch3 = content[i + 2];
                }
                if (i > 0)
                {
                    ch4 = content[i - 1];
                }
                if (flag6)
                {
                    if ((ch == this.QMARK) && (ch2 == this.GT))
                    {
                        flag6 = false;
                        i++;
                    }
                }
                else if ((!flag5 && (ch == this.LT)) && (ch2 == this.QMARK))
                {
                    flag6 = true;
                }
                else if (flag7)
                {
                    if (((ch4 == this.DASH) && (ch == this.DASH)) && (ch2 == this.GT))
                    {
                        flag7 = false;
                        i++;
                    }
                }
                else if ((!flag5 && (ch == this.LT)) && (ch2 == this.EXCLAMATION))
                {
                    if ((content.Length > (i + 9)) && (content.Substring(i, 9) == "<![CDATA["))
                    {
                        flag8 = true;
                        i += 8;
                    }
                    else
                    {
                        flag7 = true;
                    }
                }
                else if (flag8)
                {
                    if (((ch == this.SQR) && (ch2 == this.SQR)) && (ch3 == this.GT))
                    {
                        flag8 = false;
                        i += 2;
                    }
                    else
                    {
                        str4 = str4 + ch;
                    }
                }
                else if (flag)
                {
                    if (flag2)
                    {
                        if (ch == this.SPACE)
                        {
                            flag2 = false;
                        }
                        else if (ch == this.GT)
                        {
                            flag2 = false;
                            flag = false;
                        }
                        if (!flag2 && (str3.Length > 0))
                        {
                            //Hashtable hashtable;
                            //object obj2;
                            if (str3[0] == this.SLASH)
                            {
                                if (str4.Length > 0)
                                {
                                    item["_text"] += str4;
                                    //(hashtable = item)[obj2 = "_text"] = hashtable[obj2] + str4;
                                }
                                str4 = "";
                                str3 = "";
                                item = list.Pop();
                            }
                            else
                            {
                                if (str4.Length > 0)
                                {
                                    item["_text"] += str4;
                                    //(hashtable = item)[obj2 = "_text"] = hashtable[obj2] + str4;
                                }
                                str4 = "";
                                XMLNode node3 = new XMLNode();
                                node3["_text"] = "";
                                node3["_name"] = str3;
                                if (item[str3] == null)
                                {
                                    item[str3] = new XMLNodeList();
                                }
                                ((XMLNodeList) item[str3]).Push(node3);
                                list.Push(item);
                                item = node3;
                                str3 = "";
                            }
                        }
                        else
                        {
                            str3 = str3 + ch;
                        }
                    }
                    else if ((!flag5 && (ch == this.SLASH)) && (ch2 == this.GT))
                    {
                        flag = false;
                        flag3 = false;
                        flag4 = false;
                        if (str.Length > 0)
                        {
                            if (str2.Length > 0)
                            {
                                item["@" + str] = str2;
                            }
                            else
                            {
                                item["@" + str] = true;
                            }
                        }
                        i++;
                        item = list.Pop();
                        str = "";
                        str2 = "";
                    }
                    else if (!flag5 && (ch == this.GT))
                    {
                        flag = false;
                        flag3 = false;
                        flag4 = false;
                        if (str.Length > 0)
                        {
                            item["@" + str] = str2;
                        }
                        str = "";
                        str2 = "";
                    }
                    else if (flag3)
                    {
                        if ((ch == this.SPACE) || (ch == this.EQUALS))
                        {
                            flag3 = false;
                            flag4 = true;
                        }
                        else
                        {
                            str = str + ch;
                        }
                    }
                    else if (flag4)
                    {
                        if ((ch == this.QUOTE) || (ch == this.QUOTE2))
                        {
                            if (flag5)
                            {
                                flag4 = false;
                                item["@" + str] = str2;
                                str2 = "";
                                str = "";
                                flag5 = false;
                            }
                            else
                            {
                                flag5 = true;
                            }
                        }
                        else if (flag5)
                        {
                            str2 = str2 + ch;
                        }
                        else if (ch == this.SPACE)
                        {
                            flag4 = false;
                            item["@" + str] = str2;
                            str2 = "";
                            str = "";
                        }
                    }
                    else if (ch != this.SPACE)
                    {
                        flag3 = true;
                        str = ch.ToString();
                        str2 = "";
                        flag5 = false;
                    }
                }
                else if (ch == this.LT)
                {
                    flag = true;
                    flag2 = true;
                }
                else
                {
                    str4 = str4 + ch;
                }
            }
            return node;
        }
    }
}

