namespace Sfs2X.Entities.Match
{
    using System;

    public class NumberMatch : IMatcher
    {
        public static readonly NumberMatch EQUALS = new NumberMatch("==");
        public static readonly NumberMatch GREATER_OR_EQUAL_THAN = new NumberMatch(">=");
        public static readonly NumberMatch GREATER_THAN = new NumberMatch(">");
        public static readonly NumberMatch LESS_OR_EQUAL_THAN = new NumberMatch("<=");
        public static readonly NumberMatch LESS_THAN = new NumberMatch("<");
        public static readonly NumberMatch NOT_EQUALS = new NumberMatch("!=");
        private string symbol;
        private static readonly int TYPE_ID = 1;

        public NumberMatch(string symbol)
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

