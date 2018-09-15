namespace Sfs2X.Bitswarm
{
    using Sfs2X;
    using Sfs2X.Core;
    using Sfs2X.Core.Sockets;
    using Sfs2X.Entities.Data;
    using Sfs2X.Logging;
    using Sfs2X.Protocol.Serialization;
    using Sfs2X.Util;
    using System;
    using System.Collections;
    using System.Net;
    using System.Net.Sockets;
    using System.Threading;

    public class UDPManager : IUDPManager
    {
        private int currentAttempt;
        private bool initSuccess = false;
        private Timer initThread;
        private object initThreadLocker = new object();
        private bool locked = false;
        private Logger log;
        private readonly int MAX_RETRY = 3;
        private long packetId;
        private readonly int RESPONSE_TIMEOUT = 0xbb8;
        private SmartFox sfs;
        private ISocketLayer udpSocket;

        public UDPManager(SmartFox sfs)
        {
            this.sfs = sfs;
            this.packetId = 0L;
            if (sfs != null)
            {
                this.log = sfs.Log;
            }
            else
            {
                this.log = new Logger(null);
            }
            this.currentAttempt = 1;
        }

        public void Disconnect()
        {
            this.udpSocket.Disconnect();
            this.Reset();
        }

        public void Initialize(string udpAddr, int udpPort)
        {
            if (this.initSuccess)
            {
                this.log.Warn(new string[] { "UDP Channel already initialized!" });
            }
            else if (!this.locked)
            {
                this.locked = true;
                this.udpSocket = new UDPSocketLayer(this.sfs);
                this.udpSocket.OnData = new OnDataDelegate(this.OnUDPData);
                this.udpSocket.OnError = new OnErrorDelegate(this.OnUDPError);
                //IPAddress adr = IPAddress.Parse(udpAddr);
                //this.udpSocket.Connect(adr, udpPort);
                this.udpSocket.Connect(udpAddr, udpPort);//ipv6
                this.SendInitializationRequest();
            }
            else
            {
                this.log.Warn(new string[] { "UPD initialization is already in progress!" });
            }
        }

        public bool isConnected()
        {
            return this.udpSocket.IsConnected;
        }

        private void OnTimeout(object state)
        {
            if (!this.initSuccess)
            {
                lock (this.initThreadLocker)
                {
                    if (this.initThread == null)
                    {
                        return;
                    }
                }
                if (this.currentAttempt < this.MAX_RETRY)
                {
                    this.currentAttempt++;
                    this.log.Debug(new string[] { "UDP Init Attempt: " + this.currentAttempt });
                    this.SendInitializationRequest();
                    this.StartTimer();
                }
                else
                {
                    this.currentAttempt = 0;
                    this.locked = false;
                    Hashtable data = new Hashtable();
                    data["success"] = false;
                    this.sfs.DispatchEvent(new SFSEvent(SFSEvent.UDP_INIT, data));
                }
            }
        }

        private void OnUDPData(byte[] bt)
        {
            ByteArray ba = new ByteArray(bt);
            if (ba.BytesAvailable < 4)
            {
                this.log.Warn(new string[] { "Too small UDP packet. Len: " + ba.Length });
            }
            else
            {
                if (this.sfs.Debug)
                {
                    this.log.Info(new string[] { "UDP Data Read: " + DefaultObjectDumpFormatter.HexDump(ba) });
                }
                bool flag = (ba.ReadByte() & 0x20) > 0;
                short num2 = ba.ReadShort();
                if (num2 != ba.BytesAvailable)
                {
                    this.log.Warn(new string[] { string.Concat(new object[] { "Insufficient UDP data. Expected: ", num2, ", got: ", ba.BytesAvailable }) });
                }
                else
                {
                    ByteArray array2 = new ByteArray(ba.ReadBytes(ba.BytesAvailable));
                    if (flag)
                    {
                        array2.Uncompress();
                    }
                    ISFSObject packet = SFSObject.NewFromBinaryData(array2);
                    if (packet.ContainsKey("h"))
                    {
                        if (!this.initSuccess)
                        {
                            this.StopTimer();
                            this.locked = false;
                            this.initSuccess = true;
                            Hashtable data = new Hashtable();
                            data["success"] = true;
                            this.sfs.DispatchEvent(new SFSEvent(SFSEvent.UDP_INIT, data));
                        }
                    }
                    else
                    {
                        this.sfs.GetSocketEngine().IoHandler.Codec.OnPacketRead(packet);
                    }
                }
            }
        }

        private void OnUDPError(string error, SocketError se)
        {
            this.log.Warn(new string[] { "Unexpected UDP I/O Error. " + error + " [" + se.ToString() + "]" });
        }

        public void Reset()
        {
            this.StopTimer();
            this.currentAttempt = 1;
            this.initSuccess = false;
            this.locked = false;
            this.packetId = 0L;
        }

        public void Send(ByteArray binaryData)
        {
            if (this.initSuccess)
            {
                try
                {
                    this.udpSocket.Write(binaryData.Bytes);
                    if (this.sfs.Debug)
                    {
                        this.log.Info(new string[] { "UDP Data written: " + DefaultObjectDumpFormatter.HexDump(binaryData) });
                    }
                }
                catch (Exception exception)
                {
                    this.log.Warn(new string[] { "WriteUDP operation failed due to Error: " + exception.Message + " " + exception.StackTrace });
                }
            }
            else
            {
                this.log.Warn(new string[] { "UDP protocol is not initialized yet. Pleas use the initUDP() method." });
            }
        }

        private void SendInitializationRequest()
        {
            ISFSObject obj2 = new SFSObject();
            obj2.PutByte("c", 1);
            obj2.PutByte("h", 1);
            obj2.PutLong("i", this.NextUdpPacketId);
            obj2.PutInt("u", this.sfs.MySelf.Id);
            ByteArray array = obj2.ToBinary();
            ByteArray array2 = new ByteArray();
            array2.WriteByte((byte) 0x80);
            array2.WriteShort(Convert.ToInt16(array.Length));
            array2.WriteBytes(array.Bytes);
            this.udpSocket.Write(array2.Bytes);
            this.StartTimer();
        }

        private void StartTimer()
        {
            if (this.initThread != null)
            {
                this.initThread.Dispose();
            }
            this.initThread = new Timer(new TimerCallback(this.OnTimeout), null, this.RESPONSE_TIMEOUT, -1);
        }

        private void StopTimer()
        {
            lock (this.initThreadLocker)
            {
                if (this.initThread != null)
                {
                    this.initThread.Dispose();
                    this.initThread = null;
                }
            }
        }

        public bool Inited
        {
            get
            {
                return this.initSuccess;
            }
        }

        public long NextUdpPacketId
        {
            get
            {
                long num2;
                this.packetId = (num2 = this.packetId) + 1L;
                return num2;
            }
        }
    }
}

