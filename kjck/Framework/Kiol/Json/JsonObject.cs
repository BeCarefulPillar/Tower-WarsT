using System.Text;
using System.Collections.Generic;

namespace Kiol.Json
{
    public class JsonObject
    {
        public enum Type : byte
        {
            UnKnown = 0,
            Value = 1,
            String = 2,
            Array = 3,
            Object = 4,
        }

        private const int MAX_DEPTH = 1000;
        private const int WHITE_SPACE = 32;

        private string mName;
        private string mValue;
        private Type mType = Type.UnKnown;
        private List<JsonObject> mList;

        public JsonObject Parse(string json)
        {
            if (string.IsNullOrEmpty(json)) return null;

            int len = json.Length;

            char c;
            int idx = 0;

            bool inStr = false;
            bool isStr = false;
            bool isVal = true;
            string nm = null;
            string val = null;

            JsonObject ret = new JsonObject(Type.Object, null, null);
            Stack<List<JsonObject>> stack = new Stack<List<JsonObject>>(8);
            List<JsonObject> cur = null;

            for (int i = 0; i < len; i++)
            {
                c = json[i];

                if (c <= WHITE_SPACE) continue;

                if (inStr)
                {
                    if (c == '\'' || c == '\"')
                    {
                        val = json.Substring(idx, i - idx);
                        idx = i + 1;
                        inStr = false;
                    }
                    continue;
                }

                switch (c)
                {
                    case ',':
                        if (isVal)
                        {
                            if (cur == null) cur = ret.mList;
                            cur.Add(new JsonObject(isStr ? Type.String : Type.Value, nm, val == null && idx < i ? json.Substring(idx, i - idx) : val));
                        }
                        idx = i + 1;
                        nm = val = null;
                        isStr = false;
                        isVal = true;
                        break;
                    case ':':
                        if (isVal && nm == null)
                        {
                            nm = val == null && idx < i ? json.Substring(idx, i - idx) : val;
                            idx = i + 1;
                            val = null;
                            isStr = false;
                        }
                        break;
                    case '\'':
                    case '\"':
                        idx = i + 1;
                        isStr = true;
                        break;
                    case '{':
                    case '[':
                        if (cur == null)
                        {
                            cur = ret.mList;
                        }
                        else
                        {
                            stack.Push(cur);
                            JsonObject jo = new JsonObject(c == '[' ? Type.Array : Type.Object, nm, null);
                            cur.Add(jo);
                            cur = jo.mList;
                        }
                        
                        idx = i + 1;
                        nm = val = null;
                        isStr = false;
                        break;
                    case '}':
                    case ']':
                        if (isVal && idx < i)
                        {
                            cur.Add(new JsonObject(isStr ? Type.String : Type.Value, nm, val == null && idx < i ? json.Substring(idx, i - idx) : val));
                        }
                        cur = stack.Pop();
                        idx = i + 1;
                        nm = val = null;
                        isVal = isStr = false;
                        break;
                }
            }

            return ret;
        }
        private JsonObject(Type type, string name, string value)
        {
            mType = type;
            mName = name;
            mValue = value;
            if (mType == Type.Array || mType == Type.Object) mList = new List<JsonObject>(4);
        }

        public JsonObject(string json) : this(json, true) { }
        private JsonObject() { }
        private JsonObject(string json, bool checkName)
        {
            if (string.IsNullOrEmpty(json))
            {
                mName = string.Empty;
                mValue = string.Empty;
                return;
            }

            //json = json.Trim().Replace("\\n", "\n").Replace("\\t", "\t").Replace("\\r", "\r");
            json = json.Trim();

            int len = json.Length;

            if (len > 0)
            {
                char c = json[0];

                if (checkName && (c == '\'' || c == '\"'))
                {
                    //尝试解析名称
                    int idx = json.IndexOf(c, 1);
                    if (idx > 0)
                    {
                        for (int i = idx + 1; i < len; i++)
                        {
                            if (char.IsWhiteSpace(json[i])) continue;
                            if (json[i] == ':')
                            {
                                mName = json.Substring(1, idx - 1);
                                for (int j = i + 1; j < len; j++)
                                {
                                    if (char.IsWhiteSpace(json[j])) continue;
                                    json = json.Substring(j);
                                    len = len - j;
                                    c = json[0];
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }

                if (c == '[' || c == '{')
                {
                    mType = c == '[' ? Type.Array : Type.Object;

                    mList = new List<JsonObject>(4);

                    int depth = 0;
                    int token_tmp = 0;
                    bool inStr = false;
                    bool isEmpty = true;

                    for (int i = 1; i < len; i++)
                    {
                        c = json[i];
                        if (c == '\\')
                        {
                            i++;
                            continue;
                        }

                        if (c == '[' || c == '{')
                        {
                            depth++;

                            if (depth > MAX_DEPTH)
                            {
                                throw new System.StackOverflowException("jsonobject just allow " + MAX_DEPTH + " depth!");
                            }
                        }

                        if (depth == 0)
                        {
                            if (c == ']' || c == '}')
                            {
                                if (!isEmpty)
                                {
                                    mList.Add(new JsonObject(json.Substring(token_tmp + 1, i - token_tmp - 1), mType != Type.Array));
                                }
                            }
                            else if (c == '\'' || c == '"')
                            {
                                isEmpty = false;
                                inStr = !inStr;
                            }
                            else if (c == ',')
                            {
                                isEmpty = false;
                                if (!inStr)
                                {
                                    mList.Add(new JsonObject(json.Substring(token_tmp + 1, i - token_tmp - 1), mType != Type.Array));
                                    token_tmp = i;
                                }
                            }
                            else if (isEmpty)
                            {
                                isEmpty = char.IsWhiteSpace(c);
                            }
                        }
                        else if (isEmpty)
                        {
                            isEmpty = false;
                        }

                        if (c == ']' || c == '}') depth--;
                    }
                }
                else if (c == '\'' || c == '"')
                {
                    mType = Type.String;
                    if (json.EndsWith("\'") || json.EndsWith("\""))
                    {
                        mValue = json.Substring(1, json.Length - 2);
                    }
                    else
                    {
                        mValue = json.Substring(1);
                    }
                    mValue.Replace("\\\"", "\"");
                }
                else
                {
                    mType = Type.Value;
                    mValue = json;
                }
            }
            else
            {
                mName = string.Empty;
                mValue = string.Empty;
            }
        }
        /// <summary>
        /// 名称
        /// </summary>
        public string name { get { return mName; } set { mName = value; } }
        /// <summary>
        /// 值
        /// </summary>
        public string value { get { return mValue; } set { if (!hasChild)mValue = value; } }
        /// <summary>
        /// 将value转换为指定类型返回
        /// </summary>
        public T ValueFor<T>() { return ConvertValueTo<T>(mValue); }
        /// <summary>
        /// 类型
        /// </summary>
        public Type type { get { return mType; } }
        public JsonObject this[int index] { get { return GetChild(index); } }
        public JsonObject this[string name] { get { return GetChild(name); } }
        /// <summary>
        /// 是否有子级
        /// </summary>
        public bool hasChild { get { return mList != null; } }
        /// <summary>
        /// 子级个数
        /// </summary>
        public int childCount { get { return hasChild ? mList.Count : 0; } }
        
        /// <summary>
        /// 根据索引获取子级
        /// </summary>
        public JsonObject GetChild(int index) { return (hasChild && index >= 0 && index < mList.Count) ? mList[index] : null; }
        /// <summary>
        /// 按索引顺序搜索第一个名称匹配的子级
        /// </summary>
        /// <param name="childName">要匹配的子级名称</param>
        public JsonObject GetChild(string childName)
        {
            if (childCount > 0) for (int i = 0; i < mList.Count; i++) if (mList[i].mName == childName) return mList[i]; return null;
        }
        /// <summary>
        /// 按索引顺序搜索第一个名称和值都匹配的子级
        /// </summary>
        /// <param name="childName">要匹配的子级名称</param>
        /// <param name="childValue">要匹配的子级值</param>
        public JsonObject GetChild(string childName, string childValue)
        {
            if (childCount > 0) for (int i = 0; i < mList.Count; i++) if (mList[i].mName == childName && mList[i].mValue == childValue) return mList[i]; return null;
        }
        /// <summary>
        /// 搜索所有名称匹配的子级
        /// </summary>
        /// <param name="childName">要匹配的子级名称</param>
        public List<JsonObject> GetChilds(string childName)
        {
            if (childCount > 0)
            {
                List<JsonObject> ret = new List<JsonObject>(2);
                for (int i = 0; i < mList.Count; i++) if (mList[i].mName == childName) ret.Add(mList[i]);
                return ret;
            }
            return null;
        }
        /// <summary>
        /// 搜索所有名称和值都匹配的子级
        /// </summary>
        /// <param name="childName">要匹配的子级名称</param>
        /// <param name="childValue">要匹配的子级值</param>
        public List<JsonObject> GetChilds(string childName, string childValue)
        {
            if (childCount > 0)
            {
                List<JsonObject> ret = new List<JsonObject>(2);
                for (int i = 0; i < mList.Count; i++) if (mList[i].mName == childName && mList[i].mValue == childValue) ret.Add(mList[i]);
            }
            return null;
        }
        /// <summary>
        /// 获取按索引顺序搜索第一个子级，该子级至少有一个子级能匹配给定的名称
        /// </summary>
        public JsonObject GetChildWith(string childName)
        {
            if (childCount > 0) for (int i = 0; i < mList.Count; i++) if (mList[i].HasChild(childName)) return mList[i];
            return null;
        }
        /// <summary>
        /// 获取按索引顺序搜索第一个子级，该子级至少有一个子级能同时匹配给定的名称和值
        /// </summary>
        public JsonObject GetChildWith(string childName, string childValue)
        {
            if (childCount > 0) for (int i = 0; i < mList.Count; i++) if (mList[i].HasChild(childName, childValue)) return mList[i];
            return null;
        }
        /// <summary>
        /// 获取按索引顺序搜索所有子级，子级至少有一个子级能匹配给定的名称
        /// </summary>
        public List<JsonObject> GetChildsWith(string childName)
        {
            if (childCount > 0)
            {
                List<JsonObject> ret = new List<JsonObject>(2);
                for (int i = 0; i < mList.Count; i++) if (mList[i].HasChild(childName)) ret.Add(mList[i]);
            }
            return null;
        }
        /// <summary>
        /// 获取按索引顺序搜索所有子级，子级至少有一个子级能同时匹配给定的名称和值
        /// </summary>
        public List<JsonObject> GetChildsWith(string childName, string childValue)
        {
            if (childCount > 0)
            {
                List<JsonObject> ret = new List<JsonObject>(2);
                for (int i = 0; i < mList.Count; i++) if (mList[i].HasChild(childName, childValue)) ret.Add(mList[i]);
            }
            return null;
        }

        /// <summary>
        /// 获取指定索引位置的子级的值，若未找到返回string.Empty
        /// </summary>
        /// <param name="index">子级索引</param>
        /// <returns></returns>
        public string GetChildValue(int index) { JsonObject jo = GetChild(index); return jo == null ? string.Empty : jo.value; }
        /// <summary>
        /// 获取按索引顺序搜索第一个名称匹配的子级的值，若未找到返回string.Empty
        /// </summary>
        /// <param name="childName">要匹配的子级名称</param>
        public string GetChildValue(string childName) { JsonObject jo = GetChild(childName); return jo == null ? string.Empty : jo.value; }
        /// <summary>
        /// 获取指定索引位置的子级的值，并转换其类型，若未找到或类型无法转换，返回default(T)
        /// </summary>
        /// <typeparam name="T">转换目标类型</typeparam>
        /// <param name="index">子级索引</param>
        public T GetChildValue<T>(int index) { return ConvertValueTo<T>(GetChildValue(index)); }
        /// <summary>
        /// 获取按索引顺序搜索第一个名称匹配的子级的值，若未找到或类型无法转换，返回default(T)
        /// </summary>
        /// <typeparam name="T">转换目标类型</typeparam>
        /// <param name="childName">要匹配的子级名称</param>
        public T GetChildValue<T>(string childName) { return ConvertValueTo<T>(GetChildValue(childName)); }

        /// <summary>
        /// 添加一个子级(仅当当前JsonObject有子级时可加入)
        /// </summary>
        /// <param name="name">子级名称</param>
        /// <param name="value">子级的值</param>
        /// <param name="type">子级的类型</param>
        /// <returns>新加入的子级</returns>
        public JsonObject AddChild(string name, string value, Type type)
        {
            if (hasChild)
            {
                JsonObject jo = null;
                if (type == Type.Array)
                {
                    if (string.IsNullOrEmpty(value))
                    {
                        jo = new JsonObject();
                        jo.mValue = string.Empty;
                        jo.mType = type;
                        jo.mList = new List<JsonObject>();
                    }
                    else
                    {
                        if (value[0] != '[')
                        {
                            value = "[" + value;
                            if (value[value.Length - 1] != ']')
                            {
                                value = value + "]";
                            }
                        }
                        else if (value[value.Length - 1] != ']')
                        {
                            value = value + "]";
                        }
                        jo = new JsonObject(value);
                    }
                }
                else if (type == Type.Object)
                {
                    if (string.IsNullOrEmpty(value))
                    {
                        jo = new JsonObject();
                        jo.mValue = string.Empty;
                        jo.mType = type;
                        jo.mList = new List<JsonObject>();
                    }
                    else
                    {
                        if (value[0] != '{')
                        {
                            value = "{" + value;
                            if (value[value.Length - 1] != '}')
                            {
                                value = value + "}";
                            }
                        }
                        else if (value[value.Length - 1] != '}')
                        {
                            value = value + "}";
                        }
                        jo = new JsonObject(value);
                    }
                }
                else
                {
                    jo = new JsonObject();
                    jo.mValue = value;
                    jo.mType = type;
                }
                jo.mName = name;
                mList.Add(jo);
                return jo;
            }
            return null;
        }
        /// <summary>
        /// 移除指定索引的子级
        /// </summary>
        /// <param name="index">索引位置</param>
        /// <returns>是否移除</returns>
        public bool RemoveChild(int index)
        {
            if (childCount > 0 && index < mList.Count)
            {
                mList.RemoveAt(index);
                return true;
            }
            return false;
        }
        /// <summary>
        /// 移除指定名称的所有子级
        /// </summary>
        /// <param name="name">子级名称</param>
        /// <returns>本次操作移除子级的个数</returns>
        public int RemoveChild(string name)
        {
            int ret = 0;
            if (childCount > 0)
            {
                for (int i = mList.Count - 1; i >= 0; i--)
                {
                    if (mList[i].mName == name)
                    {
                        mList.RemoveAt(i);
                        ret++;
                    }
                }
            }
            return ret;
        }
        /// <summary>
        /// 移除指定的子级
        /// </summary>
        /// <param name="jo">子级对象</param>
        /// <returns>是否移除</returns>
        public bool RemoveChild(JsonObject jo)
        {
            if (childCount > 0)
            {
                for (int i = mList.Count - 1; i >= 0; i--)
                {
                    if (mList[i] == jo)
                    {
                        mList.RemoveAt(i);
                        return true;
                    }
                }
            }
            return false;
        }

        public JsonObject GetChildByPath(string childName1, string childName2)
        {
            JsonObject jo = GetChild(childName1);
            if (jo != null) jo = jo.GetChild(childName2);
            return jo;
        }
        public JsonObject GetChildByPath(string childName1, string childName2, string childName3)
        {
            JsonObject jo = GetChild(childName1);
            if (jo != null) jo = jo.GetChild(childName2);
            if (jo != null) jo = jo.GetChild(childName3);
            return jo;
        }
        public JsonObject GetChildByPath(params string[] childPath)
        {
            if (childPath != null && childPath.Length > 0)
            {
                JsonObject jo = this;
                for (int i = 0; i < childPath.Length; i++)
                {
                    jo = jo.GetChild(childPath[i]);
                    if (jo == null) break;
                }
                return jo;
            }
            return null;
        }
        public string GetValueByPath(string childName1, string childName2)
        {
            JsonObject jo = GetChildByPath(childName1, childName2);
            return jo == null ? string.Empty : jo.value;
        }
        public string GetValueByPath(string childName1, string childName2, string childName3)
        {
            JsonObject jo = GetChildByPath(childName1, childName2, childName3);
            return jo == null ? string.Empty : jo.value;
        }
        public string GetValueByPath(params string[] childPath) { JsonObject jo = GetChildByPath(childPath); return jo == null ? string.Empty : jo.value; }
        public T GetValueByPath<T>(string childName1, string childName2) { return ConvertValueTo<T>(GetValueByPath(childName1, childName2)); }
        public T GetValueByPath<T>(string childName1, string childName2, string childName3) { return ConvertValueTo<T>(GetValueByPath(childName1, childName2, childName3)); }
        public T GetValueByPath<T>(params string[] childPath) { return ConvertValueTo<T>(GetValueByPath(childPath)); }

        /// <summary>
        /// 递归搜索所有子级，找出第一个匹配指定名称的
        /// </summary>
        /// <param name="childName">匹配的子级名称</param>
        public JsonObject FindChildRecursive(string childName)
        {
            if (childCount > 0)
            {
                for (int i = 0; i < mList.Count; i++)
                {
                    if (mList[i].mName == name)
                    {
                        return mList[i];
                    }
                    JsonObject jo = mList[i].FindChildRecursive(childName);
                    if (jo != null) return jo;
                }
            }
            return null;
        }
        /// <summary>
        /// 递归搜索所有子级，找出第一个同时匹配指定名称和值的
        /// </summary>
        /// <param name="childName">匹配的子级名称</param>
        /// <param name="childValue">匹配的子级值</param>
        public JsonObject FindChildRecursive(string childName, string childValue)
        {
            if (childCount > 0)
            {
                for (int i = 0; i < mList.Count; i++)
                {
                    if (mList[i].mName == name)
                    {
                        return mList[i];
                    }
                    JsonObject jo = mList[i].FindChildRecursive(childName,childValue);
                    if (jo != null) return jo;
                }
            }
            return null;
        }
        /// <summary>
        /// 递归搜索所有子级，找出所有匹配指定名称的
        /// </summary>
        /// <param name="childName">匹配的子级名称</param>
        public List<JsonObject> FindChildsRecursive(string childName)
        {
            if (childCount > 0)
            {
                List<JsonObject> ret = new List<JsonObject>(4);
                FindChildsRecursive(ret, childName);
            }
            return null;
        }
        /// <summary>
        /// 递归搜索所有子级，找出第所有同时匹配指定名称和值的
        /// </summary>
        /// <param name="childName">匹配的子级名称</param>
        /// <param name="childValue">匹配的子级值</param>
        public List<JsonObject> FindChildsRecursive(string childName, string childValue)
        {
            if (childCount > 0)
            {
                List<JsonObject> ret = new List<JsonObject>(4);
                FindChildsRecursive(ret, childName, childValue);
            }
            return null;
        }
        protected void FindChildsRecursive(List<JsonObject> lst, string childName)
        {
            if (childCount > 0)
            {
                for (int i = 0; i < mList.Count; i++)
                {
                    if (mList[i].mName == childName) lst.Add(mList[i]);
                    mList[i].FindChildsRecursive(lst, childName);
                }
            }
        }
        protected void FindChildsRecursive(List<JsonObject> lst, string childName, string childValue)
        {
            if (childCount > 0)
            {
                for (int i = 0; i < mList.Count; i++)
                {
                    if (mList[i].mName == childName && mList[i].mValue == childValue) lst.Add(mList[i]);
                    mList[i].FindChildsRecursive(lst, childName, value);
                }
            }
        }

        /// <summary>
        /// 是否存在指定名称的子级
        /// </summary>
        public bool HasChild(string childName)
        {
            if (mList == null) return false;
            for (int i = 0; i < mList.Count; i++)
            {
                if (mList[i].mName == childName)
                {
                    return true;
                }
            }
            return false;
        }
        /// <summary>
        /// 是否存在指定名称和值的子级
        /// </summary>
        public bool HasChild(string childName, string childValue)
        {
            if (mList == null) return false;
            for (int i = 0; i < mList.Count; i++)
            {
                if (mList[i].mName == childName && mList[i].value == childValue)
                {
                    return true;
                }
            }
            return false;
        }

        public void ToString(StringBuilder sb, bool name = true)
        {
            if (name && !string.IsNullOrEmpty(mName))
            {
                sb.Append('"');
                sb.Append(mName);
                sb.Append('"');
                sb.Append(':');
            }
            if (hasChild)
            {
                sb.Append(mType == Type.Array ? '[' : '{');
                if (mList.Count > 0)
                {
                    foreach (JsonObject jo in mList)
                    {
                        jo.ToString(sb);
                        sb.Append(',');
                    }
                    sb.Remove(sb.Length - 1, 1);
                }
                sb.Append(mType == Type.Array ? ']' : '}');
            }
            else if (mType == Type.String)
            {
                sb.Append('"');
                sb.Append(mValue.Replace("\"", "\\\""));
                sb.Append('"');
            }
            else
            {
                sb.Append(mValue);
            }
        }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder(64);
            ToString(sb);
            return sb.ToString();
        }

        public string ToJson()
        {
            StringBuilder sb = new StringBuilder(64);
            ToString(sb, false);
            return sb.ToString();
        }

        private static T ConvertValueTo<T>(string val)
        {
            try
            {
                return (T)System.Convert.ChangeType(val, typeof(T));
            }
            catch
            {
                return default(T);
            }
        }
    }
}