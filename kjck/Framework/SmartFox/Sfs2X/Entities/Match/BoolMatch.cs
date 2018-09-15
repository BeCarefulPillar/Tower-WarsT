namespace Sfs2X.Entities.Match
{
    using System;

    public class BoolMatch : IMatcher
    {
        public static readonly BoolMatch EQUALS = new BoolMatch("==");
        public static readonly BoolMatch NOT_EQUALS = new BoolMatch("!=");
        private string symbol;
        private static readonly int TYPE_ID = 0;

        public BoolMatch(string symbol)
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

