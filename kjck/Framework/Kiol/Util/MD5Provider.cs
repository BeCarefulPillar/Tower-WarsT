using System;
using System.Text;

namespace Kiol.Util
{
    public class MD5Provider
    {
        public static string GetMD5(string str, bool subStr = true)
        {
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] fromData = System.Text.Encoding.UTF8.GetBytes(str);
            byte[] targetData = md5.ComputeHash(fromData);
            string byte2String = BitConverter.ToString(targetData).Replace("-", "");
            return subStr ? byte2String.Substring(10, 15) : byte2String;
        }
    }
}
