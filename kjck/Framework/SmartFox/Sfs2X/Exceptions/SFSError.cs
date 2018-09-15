namespace Sfs2X.Exceptions
{
    using System;

    public class SFSError : Exception
    {
        public SFSError(string message) : base(message)
        {
        }
    }
}

