namespace Sfs2X.Bitswarm
{
    using System;

    public interface IController
    {
        void HandleMessage(IMessage message);

        int Id { get; set; }
    }
}

