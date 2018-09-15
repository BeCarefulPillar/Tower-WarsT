namespace Sfs2X.Exceptions
{
    using System;
    using System.Collections.Generic;

    public class SFSValidationError : Exception
    {
        private List<string> errors;

        public SFSValidationError(string message, ICollection<string> errors) : base(message)
        {
            this.errors = new List<string>(errors);
        }

        public List<string> Errors
        {
            get
            {
                return this.errors;
            }
        }
    }
}

