namespace Sfs2X.Requests
{
    using Sfs2X;
    using System;

    public class ManualDisconnectionRequest : BaseRequest
    {
        public ManualDisconnectionRequest() : base(RequestType.ManualDisconnection)
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

