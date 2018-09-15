using UnityEngine;
using System.Text;
using Kiol.Reflection;
using Delegate = System.Delegate;

public static class SystemExtend
{
    #region object
    /// <summary>
    /// 类型转换
    /// </summary>
    public static T Cast<T>(this object obj, T def)
    {
        if (obj == null) return def;
        try
        {
            return (T)System.Convert.ChangeType(obj, typeof(T));
        }
        catch
        {
            return def;
        }
    }
    /// <summary>
    /// 类型转换
    /// </summary>
    public static T Cast<T>(this object obj)
    {
        if (obj == null) return default(T);
        try
        {
            return (T)System.Convert.ChangeType(obj, typeof(T));
        }
        catch
        {
            return default(T);
        }
    }
    #endregion

    #region Delegate
    /// <summary>
    /// 给定的委托是否可用
    /// </summary>
    public static bool IsAvailable(this Delegate d) { return d != null && (d.GetDelegateMethod().IsStatic || (d.Target != null && !d.Target.Equals(null))); }
    #endregion

    #region Int
    /// <summary>
    /// 转换为中文显示
    /// </summary>
    public static string ToCnString(this int num)
    {
        if (num == 0) return "零";
        int len = 32;
        int b = 0;
        bool res = num < 0;
        if (res) num = -num;
        char[] chars = new char[len];
        int index = 0;
        bool zero = false;
        while (true)
        {
            switch (num % 10)
            {
                default:
                case 0:
                    if (zero)
                    {
                        chars[index++] = '零';
                        zero = false;
                    }
                    break;
                case 1: chars[index++] = '一'; zero = true; break;
                case 2: chars[index++] = '二'; zero = true; break;
                case 3: chars[index++] = '三'; zero = true; break;
                case 4: chars[index++] = '四'; zero = true; break;
                case 5: chars[index++] = '五'; zero = true; break;
                case 6: chars[index++] = '六'; zero = true; break;
                case 7: chars[index++] = '七'; zero = true; break;
                case 8: chars[index++] = '八'; zero = true; break;
                case 9: chars[index++] = '九'; zero = true; break;
            }
            num /= 10;
            if (num > 0)
            {
                switch (b % 4)
                {
                    case 0: if (num % 10 != 0) chars[index++] = '十'; break;
                    case 1: if (num % 10 != 0) chars[index++] = '百'; break;
                    case 2: if (num % 10 != 0) chars[index++] = '千'; break;
                    case 3:
                        if (b % 8 == 7)
                        {
                            if (num % 10 == 0) chars[index++] = '零';
                            chars[index++] = '亿';
                            zero = false;
                        }
                        else if (num % 10000 != 0)
                        {
                            if (num % 10 == 0) chars[index++] = '零';
                            chars[index++] = '万';
                            zero = false;
                        }
                        break;
                }
                b++;
            }
            else
            {
                if (index > 1 && chars[index - 1] == '一' && chars[index - 2] == '十') index--;
                break;
            }
        }
        if (res) chars[index++] = '负';
        //System.Array.Resize<char>(ref chars, index);
        System.Array.Reverse(chars);
        return new string(chars, len - index, index);
    }
    /// <summary>
    /// 数字缩写
    /// </summary>
    public static string ToAbridge(this int num)
    {
        if (num > 1000000000)
        {
            return (num / 100000000) + "亿";
        }
        else if (num > 1000000)
        {
            return (num / 10000) + "万";
        }
        return num.ToString();
    }
    /// <summary>
    /// 数字缩写
    /// </summary>
    public static string ToAbridge(this long num)
    {
        if (num > 10000000000L)
        {
            return (num / 100000000L) + "亿";
        }
        else if (num > 1000000L)
        {
            return (num / 10000L) + "万";
        }
        return num.ToString();
    }
    #endregion

    #region String
    /// <summary>
    /// 解析为Int32
    /// </summary>
    /// <param name="str"></param>
    /// <returns></returns>
    public static int ParseToInt(this string str) { int v = 0; return int.TryParse(str, out v) ? v : 0; }
    /// <summary>
    /// 解析为Int32
    /// </summary>
    /// <param name="str"></param>
    /// <returns></returns>
    public static int ParseToInt(this string str, int def) { int v = 0; return int.TryParse(str, out v) ? v : def; }
    /// <summary>
    /// 计算两个字符串的相似度
    /// </summary>
    /// <param name="str1">字符串1</param>
    /// <param name="str2">字符串2</param>
    /// <returns>相似度(0-1)</returns>
    public static float LevenshteinDistancePercent(string str1, string str2)
    {
        int n = string.IsNullOrEmpty(str1) ? 0 : str1.Length;
        int m = string.IsNullOrEmpty(str2) ? 0 : str2.Length;

        if (n == 0) return m == 0 ? 1f : 0f;
        if (m == 0) return 0f;

        int[,] matrix = new int[n + 1, m + 1];
        char ch1, ch2;

        for (int i = 0; i <= n; i++) matrix[i, 0] = i;
        for (int j = 0; j <= m; j++) matrix[0, j] = j;

        for (int i = 1; i <= n; i++)
        {
            ch1 = str1[i - 1];
            for (int j = 1; j <= m; j++)
            {
                ch2 = str2[j - 1];
                matrix[i, j] = Mathf.Min(Mathf.Min(matrix[i - 1, j] + 1, matrix[i, j - 1] + 1), matrix[i - 1, j - 1] + (ch1.Equals(ch2) ? 0 : 1));
            }
        }

        return 1f - (float)matrix[n, m] / (float)Mathf.Max(n, m);
    }
    /// <summary>
    /// 剔除utf8 BOM
    /// </summary>
    public static string TrimBOM(this string str)
    {
        return string.IsNullOrEmpty(str) || str[0] != 65279 ? str : str.Substring(1);
    }
    /// <summary>
    /// 是否包含一些json中不允许出现的字符
    /// </summary>
    public static bool ContainsJsonChar(this string str)
    {
        return str.Contains("\"") ||
            str.Contains("\'") ||
            str.Contains(",") ||
            str.Contains("|") ||
            str.Contains("{") ||
            str.Contains("}") ||
            str.Contains("[") ||
            str.Contains("]") ||
            str.Contains("\\") ||
            str.Contains("#") ||
            str.Contains(":") ||
            str.Contains(".") ||
            str.Contains("?") ||
            str.Contains("<") ||
            str.Contains(">") ||
            str.Contains("(") ||
            str.Contains(")") ||
            str.Contains("*") ||
            str.Contains("&");
    }
    /// <summary>
    /// 将jsom字符替换才空格
    /// </summary>
    public static string ReplaceJsonChar(this string str)
    {
        return str.Replace('\"', ' ').Replace('\'', ' ').Replace(',', ' ').Replace('|', ' ').Replace('{', ' ').Replace('}', ' ').Replace('[', ' ').Replace(']', ' ').Replace('\\', ' ');
    }
    /// <summary>
    /// 获取string.Format()格式字符串的参数个数
    /// </summary>
    public static int GetFormatParamCount(this string str)
    {
        if (string.IsNullOrEmpty(str)) return 0;
        int cnt = 0;
        bool flag = false;
        for (int i = 0; i < str.Length; i++)
        {
            char c = str[i];
            if (flag)
            {
                if (c == '}')
                {
                    cnt++;
                    flag = false;
                }
                else
                {
                    flag = char.IsDigit(c);
                }
            }
            else if (c == '{')
            {
                flag = true;
            }
        }
        return cnt;
    }
    /// <summary>
    /// 获取分隔字符指定索引位置的字符串
    /// </summary>
    /// <param name="sep">分隔符</param>
    /// <param name="pos">查找位置</param>
    /// <param name="def">若未查找到返回的默认值</param>
    /// <returns></returns>
    public static string GetSplitString(this string str, char sep, int pos, string def = "")
    {
        if (string.IsNullOrEmpty(str) || sep == 0 || pos < 0) return def;
        int i = 0;
        while (true)
        {
            int d = str.IndexOf(sep, i);
            if (pos-- == 0)
            {
                return str.Substring(i, (d < 0 ? str.Length : d) - i);
            }
            else if (d < 0 || pos < 0)
            {
                return def;
            }
            else
            {
                i = d + 1;
            }
        }
    }
    /// <summary>
    /// 获取分隔字符串指定索引位置的字符串
    /// </summary>
    /// <param name="sep">分隔字符串</param>
    /// <param name="pos">查找位置</param>
    /// <param name="def">若未查找到返回的默认值</param>
    /// <returns></returns>
    public static string GetSplitString(this string str, string sep, int pos, string def = "")
    {
        if (string.IsNullOrEmpty(str) || string.IsNullOrEmpty(sep) || pos < 0) return def;
        int sl = sep.Length;
        int i = 0;
        while (true)
        {
            int d = str.IndexOf(sep, i);
            if (pos-- == 0)
            {
                return str.Substring(i, (d < 0 ? str.Length : d) - i);
            }
            else if (d < 0 || pos < 0)
            {
                return def;
            }
            else
            {
                i = d + sl;
            }
        }
    }
    /// <summary>
    /// 替换字符串中格式化参数
    /// </summary>
    /// <param name="str">带格式的字符串(含有{?})</param>
    /// <param name="replace">替换回调 object replace(rep) </param>
    public static string StrFormatReplace(this string str, System.Func<string, object> replace)
    {
        if (replace == null || string.IsNullOrEmpty(str)) return str;
        int len = str.Length, begin = -1, end = 0, colon = 0;
        StringBuilder ret = new StringBuilder(len);
        for (int i = 0; i < len; i++)
        {
            char c = str[i];
            if (c == '{')
            {
                begin = i;
                continue;
            }
            if (c == ':')
            {
                colon = i;
                continue;
            }
            if (c == '}' && begin >= 0)
            {
                ret.Append(str.Substring(end, begin - end));
                if (colon > begin)
                {
                    object rep = replace(str.Substring(begin + 1, colon - begin - 1));
                    if (rep is System.IFormattable)
                    {
                        ret.Append((rep as System.IFormattable).ToString(str.Substring(colon + 1, i - colon - 1), null));
                    }
                    else
                    {
                        ret.Append(rep);
                    }
                }
                else
                {
                    ret.Append(replace(str.Substring(begin + 1, i - begin - 1)));
                }
                end = i + 1;
                begin = -1;
            }
        }
        ret.Append(str.Substring(end, len - end));
        return ret.ToString();
    }
    /// <summary>
    /// 字符串中是否含义不可见字符(用于名字过滤)
    /// </summary>
    public static bool HasInvisibleChar(this string str, Font font, int size)
    {
        if (string.IsNullOrEmpty(str)) return false;
        if (font)
        {
            CharacterInfo ci;
            foreach (char c in str)
            {
                if (char.IsWhiteSpace(c) || c == 0) return true;
                if (font.GetCharacterInfo(c, out ci, size))
                {
                    if (ci.advance < size / 8f)
                    {
                        return true;
                    }
                }
                else
                {
                    return true;
                }
            }
        }
        else
        {
            foreach (char c in str) if (char.IsWhiteSpace(c) || c == 0) return true;
        }
        return false;
    }
    #endregion
}
