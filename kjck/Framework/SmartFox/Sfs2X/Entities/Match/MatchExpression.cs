namespace Sfs2X.Entities.Match
{
    using Sfs2X.Entities.Data;
    using System;
    using System.Text;

    public class MatchExpression
    {
        private IMatcher condition;
        internal LogicOperator logicOp;
        internal MatchExpression next;
        internal MatchExpression parent;
        private string varName;
        private object varValue;

        public MatchExpression(string varName, IMatcher condition, object varValue)
        {
            this.varName = varName;
            this.condition = condition;
            this.varValue = varValue;
        }

        public MatchExpression And(string varName, IMatcher condition, object varValue)
        {
            this.next = ChainedMatchExpression(varName, condition, varValue, LogicOperator.AND, this);
            return this.next;
        }

        public string AsString()
        {
            StringBuilder builder = new StringBuilder();
            if (this.logicOp != null)
            {
                builder.Append(" " + this.logicOp.Id + " ");
            }
            builder.Append("(");
            builder.Append(string.Concat(new object[] { this.varName, " ", this.condition.Symbol, " ", (this.varValue is string) ? ("'" + this.varValue + "'") : this.varValue }));
            builder.Append(")");
            return builder.ToString();
        }

        internal static MatchExpression ChainedMatchExpression(string varName, IMatcher condition, object value, LogicOperator logicOp, MatchExpression parent)
        {
            return new MatchExpression(varName, condition, value) { logicOp = logicOp, parent = parent };
        }

        private ISFSArray ExpressionAsSFSArray()
        {
            ISFSArray array = new SFSArray();
            if (this.logicOp != null)
            {
                array.AddUtfString(this.logicOp.Id);
            }
            else
            {
                array.AddNull();
            }
            array.AddUtfString(this.varName);
            array.AddByte((byte) this.condition.Type);
            array.AddUtfString(this.condition.Symbol);
            if (this.condition.Type == 0)
            {
                array.AddBool(Convert.ToBoolean(this.varValue));
                return array;
            }
            if (this.condition.Type == 1)
            {
                array.AddDouble(Convert.ToDouble(this.varValue));
                return array;
            }
            array.AddUtfString(Convert.ToString(this.varValue));
            return array;
        }

        public bool HasNext()
        {
            return (this.next != null);
        }

        public MatchExpression Next()
        {
            return this.next;
        }

        public MatchExpression Or(string varName, IMatcher condition, object varValue)
        {
            this.next = ChainedMatchExpression(varName, condition, varValue, LogicOperator.OR, this);
            return this.next;
        }

        public MatchExpression Rewind()
        {
            MatchExpression parent = this;
            while (true)
            {
                if (parent.parent == null)
                {
                    return parent;
                }
                parent = parent.parent;
            }
        }

        public ISFSArray ToSFSArray()
        {
            MatchExpression expression = this.Rewind();
            ISFSArray array = new SFSArray();
            array.AddSFSArray(expression.ExpressionAsSFSArray());
            while (expression.HasNext())
            {
                array.AddSFSArray(expression.Next().ExpressionAsSFSArray());
            }
            return array;
        }

        public override string ToString()
        {
            MatchExpression expression = this.Rewind();
            StringBuilder builder = new StringBuilder(expression.AsString());
            while (expression.HasNext())
            {
                builder.Append(expression.next.AsString());
            }
            return builder.ToString();
        }

        public IMatcher Condition
        {
            get
            {
                return this.condition;
            }
        }

        public LogicOperator LogicOp
        {
            get
            {
                return this.logicOp;
            }
        }

        public string VarName
        {
            get
            {
                return this.varName;
            }
        }

        public object VarValue
        {
            get
            {
                return this.varValue;
            }
        }
    }
}

