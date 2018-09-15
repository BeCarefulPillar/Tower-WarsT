namespace Sfs2X.Core
{
    using Sfs2X.Bitswarm;
    using Sfs2X.Exceptions;
    using Sfs2X.FSM;
    using Sfs2X.Logging;
    using Sfs2X.Protocol;
    using Sfs2X.Protocol.Serialization;
    using Sfs2X.Util;
    using System;

    public class SFSIOHandler : IoHandler
    {
        private BitSwarmClient bitSwarm;
        private readonly ByteArray EMPTY_BUFFER = new ByteArray();
        private FiniteStateMachine fsm;
        public static readonly int INT_BYTE_SIZE = 4;
        private Logger log;
        private PendingPacket pendingPacket;
        private IProtocolCodec protocolCodec;
        public static readonly int SHORT_BYTE_SIZE = 2;
        private int skipBytes = 0;

        public SFSIOHandler(BitSwarmClient bitSwarm)
        {
            this.bitSwarm = bitSwarm;
            this.log = bitSwarm.Log;
            this.protocolCodec = new SFSProtocolCodec(this, bitSwarm);
            this.InitStates();
        }

        private ByteArray HandleDataSize(ByteArray data)
        {
            this.log.Debug(new string[] { string.Concat(new object[] { "Handling Header Size. Length: ", data.Length, " (", this.pendingPacket.Header.BigSized ? "big" : "small", ")" }) });
            int num = -1;
            int pos = SHORT_BYTE_SIZE;
            if (this.pendingPacket.Header.BigSized)
            {
                if (data.Length >= INT_BYTE_SIZE)
                {
                    num = data.ReadInt();
                }
                pos = 4;
            }
            else if (data.Length >= SHORT_BYTE_SIZE)
            {
                num = data.ReadUShort();
            }
            this.log.Debug(new string[] { "Data size is " + num });
            if (num != -1)
            {
                this.pendingPacket.Header.ExpectedLength = num;
                data = this.ResizeByteArray(data, pos, data.Length - pos);
                this.fsm.ApplyTransition(PacketReadTransition.SizeReceived);
                return data;
            }
            this.fsm.ApplyTransition(PacketReadTransition.IncompleteSize);
            this.pendingPacket.Buffer.WriteBytes(data.Bytes);
            data = this.EMPTY_BUFFER;
            return data;
        }

        private ByteArray HandleDataSizeFragment(ByteArray data)
        {
            this.log.Debug(new string[] { "Handling Size fragment. Data: " + data.Length });
            int count = this.pendingPacket.Header.BigSized ? (INT_BYTE_SIZE - this.pendingPacket.Buffer.Length) : (SHORT_BYTE_SIZE - this.pendingPacket.Buffer.Length);
            if (data.Length >= count)
            {
                this.pendingPacket.Buffer.WriteBytes(data.Bytes, 0, count);
                int num2 = this.pendingPacket.Header.BigSized ? 4 : 2;
                ByteArray array = new ByteArray();
                array.WriteBytes(this.pendingPacket.Buffer.Bytes, 0, num2);
                array.Position = 0;
                int num3 = this.pendingPacket.Header.BigSized ? array.ReadInt() : array.ReadShort();
                this.log.Debug(new string[] { "DataSize is ready: " + num3 + " bytes" });
                this.pendingPacket.Header.ExpectedLength = num3;
                this.pendingPacket.Buffer = new ByteArray();
                this.fsm.ApplyTransition(PacketReadTransition.WholeSizeReceived);
                if (data.Length > count)
                {
                    data = this.ResizeByteArray(data, count, data.Length - count);
                    return data;
                }
                data = this.EMPTY_BUFFER;
                return data;
            }
            this.pendingPacket.Buffer.WriteBytes(data.Bytes);
            data = this.EMPTY_BUFFER;
            return data;
        }

        private ByteArray HandleInvalidData(ByteArray data)
        {
            if (this.skipBytes == 0)
            {
                this.fsm.ApplyTransition(PacketReadTransition.InvalidDataFinished);
                return data;
            }
            int pos = Math.Min(data.Length, this.skipBytes);
            data = this.ResizeByteArray(data, pos, data.Length - pos);
            this.skipBytes -= pos;
            return data;
        }

        private ByteArray HandleNewPacket(ByteArray data)
        {
            this.log.Debug(new string[] { "Handling New Packet of size " + data.Length });
            byte headerByte = data.ReadByte();
            if (~(headerByte & 0x80) > 0)
            {
                throw new SFSError(string.Concat(new object[] { "Unexpected header byte: ", headerByte, "\n", DefaultObjectDumpFormatter.HexDump(data) }));
            }
            PacketHeader header = PacketHeader.FromBinary(headerByte);
            this.pendingPacket = new PendingPacket(header);
            this.fsm.ApplyTransition(PacketReadTransition.HeaderReceived);
            return this.ResizeByteArray(data, 1, data.Length - 1);
        }

        private ByteArray HandlePacketData(ByteArray data)
        {
            int count = this.pendingPacket.Header.ExpectedLength - this.pendingPacket.Buffer.Length;
            bool flag = data.Length > count;
            ByteArray array = new ByteArray(data.Bytes);
            try
            {
                this.log.Debug(new string[] { string.Concat(new object[] { "Handling Data: ", data.Length, ", previous state: ", this.pendingPacket.Buffer.Length, "/", this.pendingPacket.Header.ExpectedLength }) });
                if (data.Length >= count)
                {
                    this.pendingPacket.Buffer.WriteBytes(data.Bytes, 0, count);
                    this.log.Debug(new string[] { "<<< Packet Complete >>>" });
                    if (this.pendingPacket.Header.Compressed)
                    {
                        this.pendingPacket.Buffer.Uncompress();
                    }
                    this.protocolCodec.OnPacketRead(this.pendingPacket.Buffer);
                    this.fsm.ApplyTransition(PacketReadTransition.PacketFinished);
                }
                else
                {
                    this.pendingPacket.Buffer.WriteBytes(data.Bytes);
                }
                if (flag)
                {
                    data = this.ResizeByteArray(data, count, data.Length - count);
                }
                else
                {
                    data = this.EMPTY_BUFFER;
                }
            }
            catch (Exception exception)
            {
                this.log.Error(new string[] { "Error handling data: " + exception.Message + " " + exception.StackTrace });
                this.skipBytes = count;
                this.fsm.ApplyTransition(PacketReadTransition.InvalidData);
                return array;
            }
            return data;
        }

        private void InitStates()
        {
            this.fsm = new FiniteStateMachine();
            this.fsm.AddAllStates(typeof(PacketReadState));
            this.fsm.AddStateTransition(PacketReadState.WAIT_NEW_PACKET, PacketReadState.WAIT_DATA_SIZE, PacketReadTransition.HeaderReceived);
            this.fsm.AddStateTransition(PacketReadState.WAIT_DATA_SIZE, PacketReadState.WAIT_DATA, PacketReadTransition.SizeReceived);
            this.fsm.AddStateTransition(PacketReadState.WAIT_DATA_SIZE, PacketReadState.WAIT_DATA_SIZE_FRAGMENT, PacketReadTransition.IncompleteSize);
            this.fsm.AddStateTransition(PacketReadState.WAIT_DATA_SIZE_FRAGMENT, PacketReadState.WAIT_DATA, PacketReadTransition.WholeSizeReceived);
            this.fsm.AddStateTransition(PacketReadState.WAIT_DATA, PacketReadState.WAIT_NEW_PACKET, PacketReadTransition.PacketFinished);
            this.fsm.AddStateTransition(PacketReadState.WAIT_DATA, PacketReadState.INVALID_DATA, PacketReadTransition.InvalidData);
            this.fsm.AddStateTransition(PacketReadState.INVALID_DATA, PacketReadState.WAIT_NEW_PACKET, PacketReadTransition.InvalidDataFinished);
            this.fsm.SetCurrentState(PacketReadState.WAIT_NEW_PACKET);
        }

        public void OnDataRead(ByteArray data)
        {
            if (data.Length == 0)
            {
                throw new SFSError("Unexpected empty packet data: no readable bytes available!");
            }
            if ((this.bitSwarm != null) && this.bitSwarm.Sfs.Debug)
            {
                if (data.Length > 0x400)
                {
                    this.log.Info(new string[] { "Data Read: Size > 1024, dump omitted" });
                }
                else
                {
                    this.log.Info(new string[] { "Data Read: " + DefaultObjectDumpFormatter.HexDump(data) });
                }
            }
            data.Position = 0;
            while (data.Length > 0)
            {
                if (this.ReadState == PacketReadState.WAIT_NEW_PACKET)
                {
                    data = this.HandleNewPacket(data);
                }
                else if (this.ReadState == PacketReadState.WAIT_DATA_SIZE)
                {
                    data = this.HandleDataSize(data);
                }
                else if (this.ReadState == PacketReadState.WAIT_DATA_SIZE_FRAGMENT)
                {
                    data = this.HandleDataSizeFragment(data);
                }
                else if (this.ReadState == PacketReadState.WAIT_DATA)
                {
                    data = this.HandlePacketData(data);
                }
                else if (this.ReadState == PacketReadState.INVALID_DATA)
                {
                    data = this.HandleInvalidData(data);
                }
            }
        }

        public void OnDataWrite(IMessage message)
        {
            ByteArray data = message.Content.ToBinary();
            bool compressed = data.Length > this.bitSwarm.CompressionThreshold;
            if (data.Length > this.bitSwarm.MaxMessageSize)
            {
                throw new SFSCodecError(string.Concat(new object[] { "Message size is too big: ", data.Length, ", the server limit is: ", this.bitSwarm.MaxMessageSize }));
            }
            int num = SHORT_BYTE_SIZE;
            if (data.Length > 0xffff)
            {
                num = INT_BYTE_SIZE;
            }
            bool useBlueBox = this.bitSwarm.UseBlueBox;
            PacketHeader header = new PacketHeader(message.IsEncrypted, compressed, useBlueBox, num == INT_BYTE_SIZE);
            if (this.bitSwarm.Debug)
            {
                this.log.Info(new string[] { "Data written: " + message.Content.GetHexDump() });
            }
            this.bitSwarm.ThreadManager.EnqueueSend(new WriteBinaryDataDelegate(this.WriteBinaryData), header, data, message.IsUDP);
        }

        private ByteArray ResizeByteArray(ByteArray array, int pos, int len)
        {
            byte[] dst = new byte[len];
            Buffer.BlockCopy(array.Bytes, pos, dst, 0, len);
            return new ByteArray(dst);
        }

        private void WriteBinaryData(PacketHeader header, ByteArray binData, bool udp)
        {
            ByteArray array = new ByteArray();
            if (header.Compressed)
            {
                binData.Compress();
            }
            array.WriteByte(header.Encode());
            if (header.BigSized)
            {
                array.WriteInt(binData.Length);
            }
            else
            {
                array.WriteUShort(Convert.ToUInt16(binData.Length));
            }
            array.WriteBytes(binData.Bytes);
            if (this.bitSwarm.UseBlueBox)
            {
                this.bitSwarm.HttpClient.Send(array);
            }
            else if (this.bitSwarm.Socket.IsConnected)
            {
                if (udp)
                {
                    this.WriteUDP(array);
                }
                else
                {
                    this.WriteTCP(array);
                }
            }
        }

        private void WriteTCP(ByteArray writeBuffer)
        {
            this.bitSwarm.Socket.Write(writeBuffer.Bytes);
        }

        private void WriteUDP(ByteArray writeBuffer)
        {
            this.bitSwarm.UdpManager.Send(writeBuffer);
        }

        public IProtocolCodec Codec
        {
            get
            {
                return this.protocolCodec;
            }
        }

        private PacketReadState ReadState
        {
            get
            {
                return (PacketReadState) this.fsm.GetCurrentState();
            }
        }
    }
}

