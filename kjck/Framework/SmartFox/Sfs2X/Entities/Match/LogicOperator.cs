namespace Sfs2X.Entities.Match
{
    using System;

    public class LogicOperator
    {
        public static readonly LogicOperator AND = new LogicOperator("AND");
        private string id;
        public static readonly LogicOperator OR = new LogicOperator("OR");

        public LogicOperator(string id)
        {
            this.id = id;
        }

        public string Id
        {
            get
            {
                return this.id;
            }
        }
    }
}

