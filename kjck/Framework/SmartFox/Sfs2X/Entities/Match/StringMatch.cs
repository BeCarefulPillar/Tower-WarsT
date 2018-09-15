namespace Sfs2X.Entities.Match
{
    using System;

    public class StringMatch : IMatcher
    {
        public static readonly StringMatch CONTAINS = new StringMatch("contains");
        public static readonly StringMatch ENDS_WITH = new StringMatch("endsWith");
        public static readonly StringMatch EQUALS = new StringMatch("==");
        public static readonly StringMatch NOT_EQUALS = new StringMatch("!=");
        public static readonly StringMatch STARTS_WITH = new StringMatch("startsWith");
        private string symbol;
        private static readonly int TYPE_ID = 2;

        public StringMatch(string symbol)
        {
            this.symbol = symbol;
        }

        public string Symbol
        {
            get
            {
                return this.symbol;
            }
        }

        public int Type
        {
            get
            {
                return TYPE_ID;
            }
        }
    }
}

