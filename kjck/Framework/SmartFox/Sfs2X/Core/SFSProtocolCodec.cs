namespace Sfs2X.Core
{
    using Sfs2X.Bitswarm;
    using Sfs2X.Entities.Data;
    using Sfs2X.Exceptions;
    using Sfs2X.Logging;
    using Sfs2X.Protocol;
    using Sfs2X.Util;
    using System;

    public class SFSProtocolCodec : IProtocolCodec
    {
        private static readonly string ACTION_ID = "a";
        private BitSwarmClient bitSwarm;
        private static readonly string CONTROLLER_ID = "c";
        private IoHandler ioHandler = null;
        private Logger log;
        private static readonly string PARAM_ID = "p";
        private static readonly string UDP_PACKET_ID = "i";
        private static readonly string USER_ID = "u";

        public SFSProtocolCodec(IoHandler ioHandler, BitSwarmClient bitSwarm)
        {
            this.ioHandler = ioHandler;
            this.log = bitSwarm.Log;
            this.bitSwarm = bitSwarm;
        }

        private void DispatchRequest(ISFSObject requestObject)
        {
            IMessage message = new Message();
            if (requestObject.IsNull(CONTROLLER_ID))
            {
                throw new SFSCodecError("Request rejected: No Controller ID in request!");
            }
            if (requestObject.IsNull(ACTION_ID))
            {
                throw new SFSCodecError("Request rejected: No Action ID in request!");
            }
            message.Id = Convert.ToInt32(requestObject.GetShort(ACTION_ID));
            message.Content = requestObject.GetSFSObject(PARAM_ID);
            message.IsUDP = requestObject.ContainsKey(UDP_PACKET_ID);
            if (message.IsUDP)
            {
                message.PacketId = requestObject.GetLong(UDP_PACKET_ID);
            }
            int @byte = requestObject.GetByte(CONTROLLER_ID);
            IController controller = this.bitSwarm.GetController(@byte);
            if (controller == null)
            {
                throw new SFSError("Cannot handle server response. Unknown controller, id: " + @byte);
            }
            controller.HandleMessage(message);
        }

        public void OnPacketRead(ISFSObject packet)
        {
            this.DispatchRequest(packet);
        }

        public void OnPacketRead(ByteArray packet)
        {
            ISFSObject requestObject = SFSObject.NewFromBinaryData(packet);
            this.DispatchRequest(requestObject);
        }

        public void OnPacketWrite(IMessage message)
        {
            if (this.bitSwarm.Debug)
            {
                this.log.Debug(new string[] { "Writing message " + message.Content.GetHexDump() });
            }
            ISFSObject obj2 = null;
            if (message.IsUDP)
            {
                obj2 = this.PrepareUDPPacket(message);
            }
            else
            {
                obj2 = this.PrepareTCPPacket(message);
            }
            message.Content = obj2;
            this.ioHandler.OnDataWrite(message);
        }

        private ISFSObject PrepareTCPPacket(IMessage message)
        {
            ISFSObject obj2 = new SFSObject();
            obj2.PutByte(CONTROLLER_ID, Convert.ToByte(message.TargetController));
            obj2.PutShort(ACTION_ID, Convert.ToInt16(message.Id));
            obj2.PutSFSObject(PARAM_ID, message.Content);
            return obj2;
        }

        private ISFSObject PrepareUDPPacket(IMessage message)
        {
            ISFSObject obj2 = new SFSObject();
            obj2.PutByte(CONTROLLER_ID, Convert.ToByte(message.TargetController));
            obj2.PutInt(USER_ID, (this.bitSwarm.Sfs.MySelf != null) ? this.bitSwarm.Sfs.MySelf.Id : -1);
            obj2.PutLong(UDP_PACKET_ID, this.bitSwarm.NextUdpPacketId());
            obj2.PutSFSObject(PARAM_ID, message.Content);
            return obj2;
        }

        public IoHandler IOHandler
        {
            get
            {
                return this.ioHandler;
            }
            set
            {
                if (this.ioHandler != null)
                {
                    throw new SFSError("IOHandler is already defined for thir ProtocolHandler instance: " + this);
                }
                this.ioHandler = value;
            }
        }
    }
}

