namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Bitswarm;
    using System;

    public interface IRequest
    {
        void Execute(SmartFox sfs);
        void Validate(SmartFox sfs);

        bool IsEncrypted { get; set; }

        IMessage Message { get; }

        int TargetController { get; set; }
    }
}

