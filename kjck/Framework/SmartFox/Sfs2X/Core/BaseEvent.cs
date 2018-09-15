namespace Sfs2X.Core
{
    using System;
    using System.Collections;

    public class BaseEvent
    {
        protected Hashtable arguments;
        protected object target;
        protected string type;

        public BaseEvent(string type)
        {
            this.Type = type;
            if (this.arguments == null)
            {
                this.arguments = new Hashtable();
            }
        }

        public BaseEvent(string type, Hashtable args)
        {
            this.Type = type;
            this.arguments = args;
            if (this.arguments == null)
            {
                this.arguments = new Hashtable();
            }
        }

        public BaseEvent Clone()
        {
            return new BaseEvent(this.type, this.arguments);
        }

        public override string ToString()
        {
            return (this.type + " [ " + ((this.target != null) ? this.target.ToString() : "null") + "]");
        }

        public IDictionary Params
        {
            get
            {
                return this.arguments;
            }
            set
            {
                this.arguments = value as Hashtable;
            }
        }

        public object Target
        {
            get
            {
                return this.target;
            }
            set
            {
                this.target = value;
            }
        }

        public string Type
        {
            get
            {
                return this.type;
            }
            set
            {
                this.type = value;
            }
        }
    }
}

