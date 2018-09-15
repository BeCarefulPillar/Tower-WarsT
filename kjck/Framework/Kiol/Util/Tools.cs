using System;
//using UnityEngine;

namespace Kiol.Util
{
    public static class Tools
    {
        /// <summary>
        /// 检查版本号，是否需要更新
        /// </summary>
        /// <param name="targetVer">目标版本号</param>
        /// <param name="currentVer">当前版本号</param>
        /// <returns>是否需要更新</returns>
        public static bool VersionCheck(string targetVer, string currentVer)
        {
            int[] sv = KConvert.ConvertArrType<int>(targetVer.Split('.'));
            int[] cv = KConvert.ConvertArrType<int>(currentVer.Split('.'));
            int len = sv.Length;
            if (cv.Length != len) System.Array.Resize<int>(ref cv, len);
            for (int i = 0; i < len; i++)
            {
                if (cv[i] == sv[i]) continue;
                else if (cv[i] < sv[i]) return true;
                else if (cv[i] > sv[i]) return false;
            }
            return false;
        }
        /// <summary>
        /// 返回a/b的结果
        /// </summary>
        /// <param name="a">被除数</param>
        /// <param name="b">除数</param>
        /// <returns></returns>
        public static float Division(float a, float b)
        {
            if (b == 0) return a == 0 ? 0 : 1;
            return a / b;
        }
        /// <summary>
        /// 返回a/b的结果
        /// </summary>
        /// <param name="a">被除数</param>
        /// <param name="b">除数</param>
        /// <returns></returns>
        public static int Division(int a, int b)
        {
            if (b == 0) return a == 0 ? 0 : 1;
            return a / b;
        }

        /// <summary>
        /// 给定值是否在范围内
        /// </summary>
        /// <param name="val">值</param>
        /// <param name="range">范围(1,2,2_,_111,1_100)</param>
        public static bool ValInRange(int val, string range)
        {
            if (string.IsNullOrEmpty(range)) return false;
            int idx, v;
            string[] arr = range.Split(',');
            foreach (string str in arr)
            {
                if (string.IsNullOrEmpty(str)) continue;
                idx = str.IndexOf('_');
                if (idx < 0)
                {
                    if (int.TryParse(str, out v) && val == v)
                    {
                        return true;
                    }
                    continue;
                }
                if (idx == 0)
                {
                    if (int.TryParse(str.Substring(1), out v) && val <= v)
                    {
                        return true;
                    }
                    continue;
                }
                if (idx == str.Length - 1)
                {
                    if (int.TryParse(str.Substring(0, str.Length - 1), out v) && val >= v)
                    {
                        return true;
                    }
                    continue;
                }
                if (int.TryParse(str.Substring(0, idx), out v) && val >= v)
                {
                    if (int.TryParse(str.Substring(idx, str.Length - idx), out v) && val <= v)
                    {
                        return true;
                    }
                }
            }
            return false;
        }
    }
}