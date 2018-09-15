using Kiol.Zip.GZip;
using Kiol.Util;
using Encoding = System.Text.Encoding;
using MemoryStream = System.IO.MemoryStream;

namespace Kiol.Util
{
    public static class Encryption
    {
        /// <summary>
        /// 默认的加密跳位
        /// </summary>
        public const int DEFAULT_ENCRYPT_SKIP = 16;
        /// <summary>
        /// 加密字节流
        /// </summary>
        /// <param name="data">要加密的字节流</param>
        /// <returns>加密后的字节流</returns>
        public static byte[] Encrypt(byte[] data)
        {
            if (data != null && data.Length > 1)
            {
                for (int i = 1; i < data.Length; i++)
                {
                    data[i - 1] = (byte)~data[i - 1];
                    data[i] = (byte)(data[i - 1] ^ data[i]);
                }
            }
            return data;
        }
        /// <summary>
        /// 解密字节流
        /// </summary>
        /// <param name="data">被加密的字节流</param>
        /// <returns>解密后的字节流</returns>
        public static byte[] Decrypt(byte[] data)
        {
            if (data != null && data.Length > 1)
            {
                for (int i = data.Length - 1; i > 0; i--)
                {
                    data[i] = (byte)(data[i - 1] ^ data[i]);
                    data[i - 1] = (byte)~data[i - 1];
                }
            }
            return data;
        }
        /// <summary>
        /// 加密字节流
        /// </summary>
        /// <param name="data">要加密的字节流</param>
        /// <param name="skip">跳位</param>
        /// <returns>加密后的字节流</returns>
        public static byte[] Encrypt(byte[] data, int skip)
        {
            if (skip > 0 && data != null && data.Length > 1)
            {
                int idx = 0;
                byte key = data[0] = (byte)(~data[0]);
                if (skip * 2 > data.Length)
                {
                    while (++idx < data.Length) key = data[idx] = (byte)(~(key ^ data[idx]));
                }
                else
                {
                    while ((idx = idx + (idx / skip) + 1) < data.Length)
                    {
                        key = data[idx] = (byte)(~(key ^ data[idx]));
                    }
                }
            }
            return data;
        }
        /// <summary>
        /// 解密字节流
        /// </summary>
        /// <param name="data">被加密的字节流</param>
        /// <param name="skip">跳位</param>
        /// <returns>解密后的字节流</returns>
        public static byte[] Decrypt(byte[] data, int skip)
        {
            if (skip > 0 && data != null && data.Length > 1)
            {
                int idx = 0;
                byte key = data[0], cur;
                data[0] = (byte)(~data[0]);
                if (skip * 2 > data.Length)
                {
                    while (++idx < data.Length)
                    {
                        cur = data[idx];
                        data[idx] = (byte)(~(key ^ data[idx]));
                        key = cur;
                    }
                }
                else
                {
                    while ((idx = idx + (idx / skip) + 1) < data.Length)
                    {
                        cur = data[idx];
                        data[idx] = (byte)(~(key ^ data[idx]));
                        key = cur;
                    }
                }
            }
            return data;
        }

        /// <summary>
        /// 用密钥加密整型数据
        /// </summary>
        /// <param name="value">整数</param>
        /// <param name="key">密钥</param>
        /// <returns>加密后的整数</returns>
        public static int Encrypt(int value, int key)
        {
            return ~value ^ key;
        }
        /// <summary>
        /// 用密钥解密整型数据
        /// </summary>
        /// <param name="value">整数</param>
        /// <param name="key">密钥</param>
        /// <returns>解密后的整型数据</returns>
        public static int Decrypt(int value, int key)
        {
            return ~(value ^ key);
        }
        /// <summary>
        /// 加密整型数据
        /// </summary>
        /// <param name="value">整数</param>
        /// <returns>加密后的整数</returns>
        public static int Encrypt(int value)
        {
            int k = ~value & 0xf;
            k = ((k ^ ((value & 0xf0) >> 4)) << 4) | k;
            k = ((k ^ ((value & 0xff00) >> 8)) << 8) | k;
            return ((k ^ ((int)(value & 0xffff0000) >> 16)) << 16) | k;
        }
        /// <summary>
        /// 解密整型数据
        /// </summary>
        /// <param name="value">整数</param>
        /// <returns>解密后的整型数据</returns>
        public static int Decrypt(int value)
        {
            return ((((int)(value & 0xffff0000) >> 16) ^ (value & 0xffff)) << 16) | ((((value & 0xff00) >> 8) ^ (value & 0xff)) << 8) | ((((value & 0xf0) >> 4) ^ (value & 0xf)) << 4) | (~value & 0xf);
        }

        /************************字符串加解密************************/
        /// <summary>
        /// 用utf8编码加密字符串
        /// </summary>
        /// <param name="str">要加密的字符串</param>
        public static byte[] Encrypt(string str) { return Encrypt(Encoding.UTF8.GetBytes(str)); }
        /// <summary>
        /// 加密字符串
        /// </summary>
        /// <param name="str">要加密的字符串</param>
        /// <param name="encoding">字符串编码方式</param>
        public static byte[] Encrypt(string str, Encoding encoding) { return Encrypt(encoding.GetBytes(str)); }
        /// <summary>
        /// 解密成utf8字符串
        /// </summary>
        /// <param name="data">编码数据</param>
        public static string DecryptStr(byte[] data)
        {
            if (data != null && data.Length > 0)
            {
                byte[] ed = Decrypt(data);
                return Encoding.UTF8.GetString(ed, 0, ed.Length);
            }
            return "";
        }
        /// <summary>
        /// 解密成成字符串
        /// </summary>
        /// <param name="data">编码数据</param>
        /// <param name="encoding">字符串编码方式</param>
        /// <returns></returns>
        public static string DecryptStr(byte[] data, Encoding encoding)
        {
            if (data != null && data.Length > 0)
            {
                byte[] ed = Decrypt(data);
                return encoding.GetString(ed, 0, ed.Length);
            }
            return "";
        }
        /************************压缩部分************************/
        /// <summary>
        /// 压缩字节流
        /// </summary>
        /// <param name="data">要压缩的字节流</param>
        /// <param name="encrypt">加密跳位</param>
        /// <returns>压缩(加密)后的数据</returns>
        public static byte[] Compress(byte[] data, int encrypt = 0)
        {
            if (data != null && data.Length > 0)
            {
                MemoryStream outStream = null;
                GZipOutputStream gzs = null;
                try
                {
                    outStream = new MemoryStream();
                    gzs = new GZipOutputStream(outStream);
                    gzs.Write(data, 0, data.Length);
                    gzs.Finish();
                    gzs.Flush();
                    data = outStream.ToArray();
                    if (encrypt > 0) Encrypt(data, encrypt);
                }
                catch (System.Exception e)
                {
                    KLogger.Log(e.Message);
                }
                finally
                {
                    if (gzs != null)
                    {
                        gzs.Dispose();
                        gzs.Close();
                    }
                    if (outStream != null)
                    {
                        outStream.Dispose();
                        outStream.Close();
                    }
                }
            }
            return data;
        }
        /// <summary>
        /// 解压字节流
        /// </summary>
        /// <param name="data">被压缩的字节流</param>
        /// <param name="decrypt">解密跳位</param>
        /// <returns>解压(解密)后的数据</returns>
        public static byte[] Decompress(byte[] data, int decrypt = 0)
        {
            if (data != null && data.Length > 0)
            {
                MemoryStream outStream = null;
                MemoryStream inStream = null;
                GZipInputStream gzs = null;
                try
                {
                    if (decrypt > 0) Decrypt(data, decrypt);

                    outStream = new MemoryStream();
                    inStream = new MemoryStream(data);
                    gzs = new GZipInputStream(inStream);

                    int count = 0;
                    byte[] buffer = new byte[1024];
                    while ((count = gzs.Read(buffer, 0, buffer.Length)) != 0)
                    {
                        outStream.Write(buffer, 0, count);
                    }
                    data = outStream.ToArray();
                }
                catch (System.Exception e)
                {
                    KLogger.Log(e.Message);
                    data = null;
                }
                finally
                {
                    if (gzs != null)
                    {
                        gzs.Dispose();
                        gzs.Close();
                    }
                    if (outStream != null)
                    {
                        outStream.Dispose();
                        outStream.Close();
                    }
                    if (inStream != null)
                    {
                        inStream.Dispose();
                        inStream.Close();
                    }
                }
            }
            return data;
        }
        /// <summary>
        /// 用utf8编码压缩字符串
        /// </summary>
        /// <param name="str">要压缩的字符串</param>
        /// <param name="encrypt">加密跳位</param>
        /// <returns>压缩(加密)后的数据</returns>
        public static byte[] Compress(string str, int encrypt = 0) { return Compress(Encoding.UTF8.GetBytes(str), encrypt); }
        /// <summary>
        /// 加密字符串
        /// </summary>
        /// <param name="str">要压缩的字符串</param>
        /// <param name="encoding">字符串编码方式</param>
        /// <param name="encrypt">加密跳位</param>
        /// <returns>压缩(加密)后的数据</returns>
        public static byte[] Compress(string str, Encoding encoding, int encrypt = 0) { return Compress(encoding.GetBytes(str), encrypt); }
        /// <summary>
        /// 解压成utf8字符串
        /// </summary>
        /// <param name="data">压缩数据</param>
        /// <param name="decrypt">解密跳位</param>
        /// <returns>解压(解密)后的字符串</returns>
        public static string DecompressStr(byte[] data, int decrypt = 0)
        {
            if (data != null && data.Length > 0)
            {
                byte[] ed = Decompress(data, decrypt);
                return Encoding.UTF8.GetString(ed, 0, ed.Length);
            }
            return "";
        }
        /// <summary>
        /// 解压成成字符串
        /// </summary>
        /// <param name="data">压缩数据</param>
        /// <param name="encoding">字符串编码方式</param>
        /// <param name="decrypt">解密跳位</param>
        /// <returns>解压(解密)后的字符串</returns>
        public static string DecompressStr(byte[] data, Encoding encoding, int decrypt = 0)
        {
            if (data != null && data.Length > 0)
            {
                byte[] ed = Decompress(data, decrypt);
                return encoding.GetString(ed, 0, ed.Length);
            }
            return "";
        }
    }
}