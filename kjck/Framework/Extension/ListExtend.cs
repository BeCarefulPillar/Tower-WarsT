using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;

public static class ListExtend
{
    /// <summary>
    /// 剔除列表中为NULL的对象和多个相同对象的多余项
    /// </summary>
    public static void TrimSame<T>(this List<T> list)
    {
        int count = list != null ? list.Count : 0;
        for (int i = 0; i < count; i++)
        {
            T e = list[i];
            if (object.Equals(e, null))
            {
                list.RemoveAt(i--); count--;
            }
            else
            {
                for (int j = 0; j < i; j++)
                {
                    if (e.Equals(list[j]))
                    {
                        list.RemoveAt(i--); count--;
                        break;
                    }
                }
            }
        }
    }

    /// <summary>
    /// 添加唯一编号的对象
    /// </summary>
    public static void AddNo_<T>(this List<T> list, T[] arr) where T : No_
    {
        if (list != null && arr != null)
        {
            foreach (T n in arr)
            {
                bool flag = true;
                for (int i = 0; i < list.Count; i++)
                {
                    if (list[i].SN == n.SN)
                    {
                        flag = false;
                        list[i] = n;
                        break;
                    }
                }
                if (flag) list.Add(n);
            }
        }
    }

    /// <summary>
    /// 统计数目
    /// </summary>
    public static int Count<T>(this List<T> list, System.Predicate<T> match)
    {
        int cnt = 0;
        if (list != null) foreach (T item in list) if (match(item)) cnt++;
        return cnt;
    }

    /// <summary>
    /// 序列化保存list
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="list"></param>
    /// <param name="path"></param>
    public static void SerializeToFile<T>(this List<T> list, string path)
    {
        try
        {
            //序列化List
            FileStream fs = new FileStream(path, FileMode.Create);
            BinaryFormatter bf = new BinaryFormatter();
            bf.Serialize(fs, list);
            fs.Close();
        }
        catch (System.Exception e)
        {
            UnityEngine.Debug.Log(e.Message);
        }
    }

    /// <summary>
    /// 反序列化读取文件至list
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="path"></param>
    /// <returns></returns>
    public static List<T> DeSerializeToList<T>(string path)
    {
        try
        {
            FileStream fs = new FileStream(path, FileMode.Open);
            BinaryFormatter bf = new BinaryFormatter();
            List<T> list = bf.Deserialize(fs) as List<T>;
            fs.Close();
            return list;
        }
        catch (System.Exception e)
        {
            UnityEngine.Debug.Log(e.Message);
            return null;
        }
    }
}
