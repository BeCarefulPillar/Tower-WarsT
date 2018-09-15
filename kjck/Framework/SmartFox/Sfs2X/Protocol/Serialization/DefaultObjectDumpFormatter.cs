namespace Sfs2X.Protocol.Serialization
{
    using Sfs2X.Exceptions;
    using Sfs2X.Util;
    using System;
    using System.Text;

    public class DefaultObjectDumpFormatter
    {
        public static readonly char DOT = '.';
        public static readonly int HEX_BYTES_PER_LINE = 0x10;
        public static int MAX_DUMP_LENGTH = 0x400;
        public static readonly char NEW_LINE = '\n';
        public static readonly char TAB = '\t';
        public static readonly char TOKEN_DIVIDER = ';';
        public static readonly char TOKEN_INDENT_CLOSE = '}';
        public static readonly char TOKEN_INDENT_OPEN = '{';

        private static string GetFormatTabs(int howMany)
        {
            return StrFill(TAB, howMany);
        }

        public static string HexDump(ByteArray ba)
        {
            return HexDump(ba, HEX_BYTES_PER_LINE);
        }

        public static string HexDump(ByteArray ba, int bytesPerLine)
        {
            StringBuilder builder = new StringBuilder();
            builder.Append("Binary Size: " + ba.Length.ToString() + NEW_LINE);
            if (ba.Length > MAX_DUMP_LENGTH)
            {
                builder.Append("** Data larger than max dump size of " + MAX_DUMP_LENGTH + ". Data not displayed");
                return builder.ToString();
            }
            StringBuilder builder2 = new StringBuilder();
            StringBuilder builder3 = new StringBuilder();
            int index = 0;
            int num2 = 0;
            do
            {
                char dOT;
                byte num3 = ba.Bytes[index];
                string str = string.Format("{0:x2}", num3);
                if (str.Length == 1)
                {
                    str = "0" + str;
                }
                builder2.Append(str + " ");
                if ((num3 >= 0x21) && (num3 <= 0x7e))
                {
                    dOT = Convert.ToChar(num3);
                }
                else
                {
                    dOT = DOT;
                }
                builder3.Append(dOT);
                if (++num2 == bytesPerLine)
                {
                    num2 = 0;
                    builder.Append(string.Concat(new object[] { builder2.ToString(), TAB, builder3.ToString(), NEW_LINE }));
                    builder2 = new StringBuilder();
                    builder3 = new StringBuilder();
                }
            }
            while (++index < ba.Length);
            if (num2 != 0)
            {
                for (int i = bytesPerLine - num2; i > 0; i--)
                {
                    builder2.Append("   ");
                    builder3.Append(" ");
                }
                builder.Append(string.Concat(new object[] { builder2.ToString(), TAB, builder3.ToString(), NEW_LINE }));
            }
            return builder.ToString();
        }

        public static string PrettyPrintDump(string rawDump)
        {
            StringBuilder builder = new StringBuilder();
            int howMany = 0;
            for (int i = 0; i < rawDump.Length; i++)
            {
                char ch = rawDump[i];
                if (ch == TOKEN_INDENT_OPEN)
                {
                    howMany++;
                    builder.Append(NEW_LINE + GetFormatTabs(howMany));
                }
                else if (ch == TOKEN_INDENT_CLOSE)
                {
                    howMany--;
                    if (howMany < 0)
                    {
                        throw new SFSError("DumpFormatter: the indentPos is negative. TOKENS ARE NOT BALANCED!");
                    }
                    builder.Append(NEW_LINE + GetFormatTabs(howMany));
                }
                else if (ch == TOKEN_DIVIDER)
                {
                    builder.Append(NEW_LINE + GetFormatTabs(howMany));
                }
                else
                {
                    builder.Append(ch);
                }
            }
            if (howMany != 0)
            {
                throw new SFSError("DumpFormatter: the indentPos is not == 0. TOKENS ARE NOT BALANCED!");
            }
            return builder.ToString();
        }

        private static string StrFill(char ch, int howMany)
        {
            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < howMany; i++)
            {
                builder.Append(ch);
            }
            return builder.ToString();
        }
    }
}

