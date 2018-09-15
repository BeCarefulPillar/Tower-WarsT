namespace Sfs2X.Requests
{
    using Sfs2X;
    using System;

    public class PingPongRequest : BaseRequest
    {
        public PingPongRequest() : base(RequestType.PingPong)
        {
        }

        public override void Execute(SmartFox sfs)
        {
        }

        public override void Validate(SmartFox sfs)
        {
        }
    }
}

