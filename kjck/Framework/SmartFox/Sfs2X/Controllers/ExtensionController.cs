namespace Sfs2X.Controllers
{
    using Sfs2X.Bitswarm;
    using Sfs2X.Core;
    using Sfs2X.Entities.Data;
    using System;
    using System.Collections;

    public class ExtensionController : BaseController
    {
        public static readonly string KEY_CMD = "c";
        public static readonly string KEY_PARAMS = "p";
        public static readonly string KEY_ROOM = "r";

        public ExtensionController(BitSwarmClient bitSwarm) : base(bitSwarm)
        {
        }

        public override void HandleMessage(IMessage message)
        {
            if (base.sfs.Debug)
            {
                base.log.Info(new string[] { message.ToString() });
            }
            ISFSObject content = message.Content;
            Hashtable data = new Hashtable();
            data["cmd"] = content.GetUtfString(KEY_CMD);
            data["params"] = content.GetSFSObject(KEY_PARAMS);
            if (content.ContainsKey(KEY_ROOM))
            {
                data["sourceRoom"] = content.GetInt(KEY_ROOM);
            }
            if (message.IsUDP)
            {
                data["packetId"] = message.PacketId;
            }
            base.sfs.DispatchEvent(new SFSEvent(SFSEvent.EXTENSION_RESPONSE, data));
        }
    }
}

