using UnityEngine;
using System;

public static class ArrayExtend
{
    /// <summary>
    /// 数组中每个元素遍历执行
    /// </summary>
    public static void ForEach<T>(this T[] array, Action<T> action) { if (array != null) for (int i = 0; i < array.Length; i++) action(array[i]); }
    /// <summary>
    /// 数组中是否存在给定元素
    /// </summary>
    public static bool Contains<T>(this T[] array, T element) { if (array != null) for (int i = 0; i < array.Length; i++) if (object.Equals(array[i], element)) return true; return false; }
    /// <summary>
    /// 数组中是否存在给定元素
    /// </summary>
    public static bool Contains(this Array array, object element) { if (array != null) for (int i = 0; i < array.Length; i++) if (object.Equals(array.GetValue(i), element)) return true; return false; }
    /// <summary>
    /// 给定索引是否在数组的索引范围内
    /// </summary>
    /// <param name="index">给定的索引</param>
    /// <returns>索引是否在范围内</returns>
    public static bool IndexAvailable(this Array array, int index) { return array != null && index >= 0 && index < array.Length; }
    /// <summary>
    /// 给定索引是否在数组指定维数索引范围内
    /// </summary>
    /// <param name="index">给定的索引</param>
    /// <param name="dimension">数组维数</param>
    /// <returns>索引是否在范围内</returns>
    public static bool IndexAvailable(this Array array, int index, int dimension) { return array != null && index >= 0 && index < array.GetLength(dimension); }
    /// <summary>
    /// 移除数组中从起始索引开始的指定数目元素，改变数组大小
    /// </summary>
    /// <typeparam name="T">数组泛型</typeparam>
    /// <param name="array">数组</param>
    /// <param name="index">删除的起始索引</param>
    /// <param name="count">删除数目</param>
    public static void RemoveAt<T>(ref T[] array, int index, int count = 1)
    {
        if (array != null && index >= 0 && count > 0)
        {
            int len = array.Length;
            if (index < len)
            {
                count = Math.Min(count, len - index);
                int newLen = len - count;
                for (int i = index; i < newLen; i++) array[i] = array[i + count];
                T[] destinationArray = new T[newLen];
                Array.Copy(array, destinationArray, newLen);
                array = destinationArray;
            }
        }
    }
    /// <summary>
    /// 类型转换
    /// </summary>
    public static T[] Cast<T>(this Array array)
    {
        if (array == null) return null;
        T[] ret = new T[array.Length];
        for (int i = 0; i < array.Length; i++) ret[i] = array.GetValue(i).Cast<T>();
        return ret;
    }
    /// <summary>
    /// 类型转换
    /// </summary>
    public static T[] Cast<T>(this Array array, T def)
    {
        if (array == null) return null;
        T[] ret = new T[array.Length];
        for (int i = 0; i < array.Length; i++) ret[i] = array.GetValue(i).Cast<T>(def);
        return ret;
    }
    /// <summary>
    /// 类型转换
    /// </summary>
    public static int[] CastToInt(this string[] array)
    {
        if (array == null) return null;
        int[] ret = new int[array.Length];
        for (int i = 0; i < array.Length; i++) ret[i] = array[i].ParseToInt();
        return ret;
    }
    /// <summary>
    /// 类型转换
    /// </summary>
    public static int[] CastToInt(this string[] array, int def)
    {
        if (array == null) return null;
        int[] ret = new int[array.Length];
        for (int i = 0; i < array.Length; i++) ret[i] = array[i].ParseToInt(def);
        return ret;
    }
    /// <summary>
    /// 数组的长度，若数组为NULL也为0
    /// </summary>
    public static int GetLength(this Array array) { return array != null ? array.Length : 0; }
    /// <summary>
    /// 取值,默认为0
    /// </summary>
    public static int GetValDef(this int[] array, int index) { return (array != null && index >= 0 && index < array.Length) ? array[index] : 0; }
    //public static int GetValDef(this int[] array, int index) { try { return array[index]; } catch { return 0; } }
    /// <summary>
    /// 取值,默认为def
    /// </summary>
    public static int GetValDef(this int[] array, int index, int def) { return (array != null && index >= 0 && index < array.Length) ? array[index] : def; }
    /// <summary>
    /// 将一维数组的索引进行偏移
    /// </summary>
    /// <param name="offset">偏移量 大于0右移 小于0左移</param>
    public static void OffsetIndex<T>(this T[] array, int offset)
    {
        if (array == null) return;
        int len = array.Length;
        offset %= len;

        //双数组复制法
        //if (offset != 0)
        //{
        //    if (offset < 0) offset += len;
        //    T[] temps = new T[len];
        //    Array.Copy(array, temps, 0);
        //    for (int i = 0; i < len; i++)
        //    {
        //        array[i] = temps[(i + offset) % len];
        //    }
        //}

        //单数组交替赋值法
        int totalCount = len - 1, idx = 0;
        while (offset != 0 && idx < totalCount)
        {
            T temp;
            if (offset > 0) offset -= len;//以向左移动为准
            int curCnt = len + offset;//该次需要替换的个数
            int idxLen = idx + curCnt;//原数组替换到的最大索引
            for (; idx < idxLen; idx++)
            {
                //值互换
                int iof = idx - offset;
                temp = array[idx];
                array[idx] = array[iof];
                array[iof] = temp;
            }
            len = -offset;//剩余的需要替换的个数
            offset = (offset + curCnt) % len;//剩余替换个数的偏移量
        }
    }
    /// <summary>
    /// 匹配2个数组的元素
    /// </summary>
    public static bool MatchElement<T>(this T[] arr, T[] to)
    {
        if (object.Equals(arr, to)) return true;
        if (arr == null || to == null || arr.Length != to.Length) return false;
        for (int i = 0; i < arr.Length; i++) if (!object.Equals(arr[i], to[i])) return false;
        return true;
    }
    /// <summary>
    /// 剔除列表中为NULL的对象和多个相同对象的多余项
    /// </summary>
    public static void TrimSame<T>(ref T[] arr)
    {
        if (arr == null) return;
        int len = arr.Length;
        int idx = 0;
        for (int i = 0; i < len; i++)
        {
            T v = arr[i];
            
            if (object.Equals(v, null)) continue;

            bool jump = false;
            for (int j = 0; j < i; j++)
            {
                if (v.Equals(arr[j]))
                {
                    jump = true;
                    break;
                }
            }
            if (jump) continue;

            arr[idx++] = v;
        }

        if (idx < len) Array.Resize(ref arr, idx);
    }
    /// <summary>
    /// 改变数组长度，为空则创建
    /// </summary>
    public static void ResizeEvenNull<T>(ref T[] arr , int newSize)
    {
        if (newSize < 0) arr = null;
        else if (arr == null) arr = new T[newSize];
        else if (arr.Length != newSize) Array.Resize(ref arr, newSize);
    }

    /// <summary>
    /// 获取进度操作集的总进度
    /// </summary>
    /// <param name="pros">进度操作集</param>
    /// <param name="percent">总进度</param>
    /// <returns>是否已全部完成或停止</returns>
    public static bool GetDoneAndProgress(this IProgress[] pros, out float percent)
    {
        bool ret = true;
        percent = 0f;
        if (pros.GetLength() > 0)
        {
            for (int i = 0; i < pros.Length; i++)
            {
                if (pros[i] != null)
                {
                    percent += pros[i].process;
                    if (ret && !pros[i].isDone && !pros[i].isTimeOut) ret = false;
                }
            }
            percent /= pros.Length;
        }
        return ret;
    }
    /// <summary>
    /// 获取进度操作集的总完成标志
    /// </summary>
    /// <param name="pros">进度操作集</param>
    public static bool GetIsDone(this IProgress[] pros)
    {
        if (pros.GetLength() > 0)
        {
            for (int i = 0; i < pros.Length; i++)
            {
                if (pros[i] == null || pros[i].isDone || pros[i].isTimeOut) continue;
                return false;
            }
        }
        else
        {
            return false;
        }
        return true;
    }
    /// <summary>
    /// 获取进度操作集的总进度
    /// </summary>
    /// <param name="pros">进度操作集</param>
    /// <returns>总进度</returns>
    public static float GetProgress(this IProgress[] pros)
    {
        float percent = 0f;
        if (pros.GetLength() > 0)
        {
            for (int i = 0; i < pros.Length; i++)
            {
                percent += pros[i] != null ? pros[i].process : 0f;
            }
            percent /= pros.Length;
        }
        return percent;
    }
}
