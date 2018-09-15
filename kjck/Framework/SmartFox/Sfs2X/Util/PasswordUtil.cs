namespace Sfs2X.Util
{
    using System;
    using System.Security.Cryptography;
    using System.Text;

    public class PasswordUtil
    {
        public static string MD5Password(string pass)
        {
            StringBuilder builder = new StringBuilder(string.Empty);
            foreach (byte num in new MD5CryptoServiceProvider().ComputeHash(Encoding.Default.GetBytes(pass)))
            {
                builder.Append(num.ToString("x2"));
            }
            return builder.ToString();
        }
    }
}

