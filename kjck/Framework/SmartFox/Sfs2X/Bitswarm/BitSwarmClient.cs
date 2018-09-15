namespace Sfs2X.Bitswarm
{
    using Sfs2X;
    using Sfs2X.Bitswarm.BBox;
    using Sfs2X.Controllers;
    using Sfs2X.Core;
    using Sfs2X.Core.Sockets;
    using Sfs2X.Exceptions;
    using Sfs2X.Logging;
    using Sfs2X.Util;
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Net;
    using System.Net.Sockets;
    using System.Runtime.CompilerServices;
    using System.Timers;

    public class BitSwarmClient : IDispatchable
    {
        private bool attemptingReconnection;
        private BBClient bbClient;
        private bool bbConnected;
        private int compressionThreshold;
        private string connectionMode;
        private Dictionary<int, IController> controllers;
        private bool controllersInited;
        private EventDispatcher dispatcher;
        private ExtensionController extController;
        private DateTime firstReconnAttempt;
        private Sfs2X.Bitswarm.IoHandler ioHandler;
        private string lastIpAddress;
        private int lastTcpPort;
        private Logger log;
        private bool manualDisconnection;
        private int maxMessageSize;
        private int reconnCounter;
        private readonly double reconnectionDelayMillis;
        private int reconnectionSeconds;
        private Timer retryTimer;
        private SmartFox sfs;
        private ISocketLayer socket;
        private SystemController sysController;
        private Sfs2X.Core.ThreadManager threadManager;
        private IUDPManager udpManager;
        private volatile bool useBlueBox;

        public BitSwarmClient()
        {
            this.reconnectionDelayMillis = 1000.0;
            this.socket = null;
            this.controllers = new Dictionary<int, IController>();
            this.compressionThreshold = 0x1e8480;
            this.maxMessageSize = 0x2710;
            this.reconnectionSeconds = 0;
            this.attemptingReconnection = false;
            this.firstReconnAttempt = DateTime.MinValue;
            this.reconnCounter = 1;
            this.controllersInited = false;
            this.useBlueBox = false;
            this.bbConnected = false;
            this.threadManager = new Sfs2X.Core.ThreadManager();
            this.manualDisconnection = false;
            this.retryTimer = null;
            this.sfs = null;
            this.log = null;
        }

        public BitSwarmClient(SmartFox sfs)
        {
            this.reconnectionDelayMillis = 1000.0;
            this.socket = null;
            this.controllers = new Dictionary<int, IController>();
            this.compressionThreshold = 0x1e8480;
            this.maxMessageSize = 0x2710;
            this.reconnectionSeconds = 0;
            this.attemptingReconnection = false;
            this.firstReconnAttempt = DateTime.MinValue;
            this.reconnCounter = 1;
            this.controllersInited = false;
            this.useBlueBox = false;
            this.bbConnected = false;
            this.threadManager = new Sfs2X.Core.ThreadManager();
            this.manualDisconnection = false;
            this.retryTimer = null;
            this.sfs = sfs;
            this.log = sfs.Log;
        }

        private void AddController(int id, IController controller)
        {
            if (controller == null)
            {
                throw new ArgumentException("Controller is null, it can't be added.");
            }
            if (this.controllers.ContainsKey(id))
            {
                throw new ArgumentException(string.Concat(new object[] { "A controller with id: ", id, " already exists! Controller can't be added: ", controller }));
            }
            this.controllers[id] = controller;
        }

        private void AddCustomController(int id, Type controllerType)
        {
            IController controller = Activator.CreateInstance(controllerType) as IController;
            this.AddController(id, controller);
        }

        public void AddEventListener(string eventType, EventListenerDelegate listener)
        {
            this.dispatcher.AddEventListener(eventType, listener);
        }

        public void Connect()
        {
            this.Connect("127.0.0.1", 0x26cd);
        }

        public void Connect(string ip, int port)
        {
            this.lastIpAddress = ip;
            this.lastTcpPort = port;
            this.threadManager.Start();
            if (this.useBlueBox)
            {
                this.connectionMode = Sfs2X.Bitswarm.ConnectionModes.HTTP;
                this.bbClient.PollSpeed = (this.sfs.Config != null) ? this.sfs.Config.BlueBoxPollingRate : 750;
                this.bbClient.Connect(ip, port);
            }
            else
            {
                //this.socket.Connect(IPAddress.Parse(this.lastIpAddress), this.lastTcpPort);
                this.socket.Connect(this.lastIpAddress, this.lastTcpPort);//ipv6
                this.connectionMode = Sfs2X.Bitswarm.ConnectionModes.SOCKET;
            }
        }

        public void Destroy()
        {
            this.socket.OnConnect = (ConnectionDelegate) Delegate.Remove(this.socket.OnConnect, new ConnectionDelegate(this.OnSocketConnect));
            this.socket.OnDisconnect = (ConnectionDelegate) Delegate.Remove(this.socket.OnDisconnect, new ConnectionDelegate(this.OnSocketClose));
            this.socket.OnData = (OnDataDelegate) Delegate.Remove(this.socket.OnData, new OnDataDelegate(this.OnSocketData));
            this.socket.OnError = (OnErrorDelegate) Delegate.Remove(this.socket.OnError, new OnErrorDelegate(this.OnSocketError));
            if (this.socket.IsConnected)
            {
                this.socket.Disconnect();
            }
            this.socket = null;
            this.threadManager.Stop();
        }

        public void Disconnect()
        {
            this.Disconnect(null);
        }

        public void Disconnect(string reason)
        {
            if (this.useBlueBox)
            {
                this.bbClient.Close();
            }
            else
            {
                this.socket.Disconnect(reason);
                if (this.udpManager != null)
                {
                    this.udpManager.Disconnect();
                }
            }
            this.ReleaseResources();
        }

        private void DispatchEvent(BitSwarmEvent evt)
        {
            this.dispatcher.DispatchEvent(evt);
        }

        public void EnableBlueBoxDebug(bool val)
        {
            this.bbClient.IsDebug = val;
        }

        private void ExecuteDisconnection()
        {
            Hashtable arguments = new Hashtable();
            arguments["reason"] = ClientDisconnectionReason.UNKNOWN;
            this.DispatchEvent(new BitSwarmEvent(BitSwarmEvent.DISCONNECT, arguments));
            this.ReleaseResources();
        }

        public void ForceBlueBox(bool val)
        {
            if (this.bbConnected)
            {
                throw new Exception("You can't change the BlueBox mode while the connection is running");
            }
            this.useBlueBox = val;
        }

        public IController GetController(int id)
        {
            return this.controllers[id];
        }

        public void Init()
        {
            if (this.dispatcher == null)
            {
                this.dispatcher = new EventDispatcher(this);
            }
            if (!this.controllersInited)
            {
                this.InitControllers();
                this.controllersInited = true;
            }
            if (this.socket == null)
            {
                this.socket = new TCPSocketLayer(this);
                this.socket.OnConnect = (ConnectionDelegate) Delegate.Combine(this.socket.OnConnect, new ConnectionDelegate(this.OnSocketConnect));
                this.socket.OnDisconnect = (ConnectionDelegate) Delegate.Combine(this.socket.OnDisconnect, new ConnectionDelegate(this.OnSocketClose));
                this.socket.OnData = (OnDataDelegate) Delegate.Combine(this.socket.OnData, new OnDataDelegate(this.OnSocketData));
                this.socket.OnError = (OnErrorDelegate) Delegate.Combine(this.socket.OnError, new OnErrorDelegate(this.OnSocketError));
                this.bbClient = new BBClient(this);
                this.bbClient.AddEventListener(BBEvent.CONNECT, new EventListenerDelegate(this.OnBBConnect));
                this.bbClient.AddEventListener(BBEvent.DATA, new EventListenerDelegate(this.OnBBData));
                this.bbClient.AddEventListener(BBEvent.DISCONNECT, new EventListenerDelegate(this.OnBBDisconnect));
                this.bbClient.AddEventListener(BBEvent.IO_ERROR, new EventListenerDelegate(this.OnBBError));
                this.bbClient.AddEventListener(BBEvent.SECURITY_ERROR, new EventListenerDelegate(this.OnBBError));
            }
        }

        private void InitControllers()
        {
            this.sysController = new SystemController(this);
            this.extController = new ExtensionController(this);
            this.AddController(0, this.sysController);
            this.AddController(1, this.extController);
        }

        public void KillConnection()
        {
            if (!this.useBlueBox)
            {
                this.socket.Kill();
                this.OnSocketClose();
            }
        }

        public long NextUdpPacketId()
        {
            return this.udpManager.NextUdpPacketId;
        }

        private void OnBBConnect(BaseEvent e)
        {
            this.bbConnected = true;
            BitSwarmEvent evt = new BitSwarmEvent(BitSwarmEvent.CONNECT) {
                Params = new Hashtable()
            };
            evt.Params["success"] = true;
            evt.Params["isReconnection"] = false;
            this.DispatchEvent(evt);
        }

        private void OnBBData(BaseEvent e)
        {
            BBEvent event2 = e as BBEvent;
            ByteArray buffer = (ByteArray) event2.Params["data"];
            this.ioHandler.OnDataRead(buffer);
        }

        private void OnBBDisconnect(BaseEvent e)
        {
            this.bbConnected = false;
            this.useBlueBox = false;
            if (this.manualDisconnection)
            {
                this.manualDisconnection = false;
                this.ExecuteDisconnection();
            }
        }

        private void OnBBError(BaseEvent e)
        {
            BBEvent event2 = e as BBEvent;
            this.log.Error(new string[] { "## BlueBox Error: " + ((string) event2.Params["message"]) });
            BitSwarmEvent evt = new BitSwarmEvent(BitSwarmEvent.IO_ERROR) {
                Params = new Hashtable()
            };
            evt.Params["message"] = event2.Params["message"];
            this.DispatchEvent(evt);
        }

        private void OnRetryConnectionEvent(object source, ElapsedEventArgs e)
        {
            this.retryTimer.Enabled = false;
            this.retryTimer.Stop();
            //this.socket.Connect(IPAddress.Parse(this.lastIpAddress), this.lastTcpPort);
            if (this.socket != null) this.socket.Connect(this.lastIpAddress, this.lastTcpPort);//ipv6
        }

        private void OnSocketClose()
        {
            if (this.sfs.GetReconnectionSeconds() == 0)
            {
                this.firstReconnAttempt = DateTime.MinValue;
                this.ExecuteDisconnection();
            }
            else if (this.attemptingReconnection)
            {
                this.Reconnect();
            }
            else
            {
                this.attemptingReconnection = true;
                this.firstReconnAttempt = DateTime.Now;
                this.reconnCounter = 1;
                this.DispatchEvent(new BitSwarmEvent(BitSwarmEvent.RECONNECTION_TRY));
                this.Reconnect();
            }
        }

        private void OnSocketConnect()
        {
            BitSwarmEvent evt = new BitSwarmEvent(BitSwarmEvent.CONNECT);
            Hashtable hashtable = new Hashtable();
            hashtable["success"] = true;
            hashtable["isReconnection"] = this.attemptingReconnection;
            evt.Params = hashtable;
            this.DispatchEvent(evt);
        }

        private void OnSocketData(byte[] data)
        {
            try
            {
                ByteArray buffer = new ByteArray(data);
                this.ioHandler.OnDataRead(buffer);
            }
            catch (Exception exception)
            {
                this.log.Error(new string[] { "## SocketDataError: " + exception.Message });
                BitSwarmEvent evt = new BitSwarmEvent(BitSwarmEvent.DATA_ERROR);
                Hashtable hashtable = new Hashtable();
                hashtable["message"] = exception.ToString();
                evt.Params = hashtable;
                this.DispatchEvent(evt);
            }
        }

        private void OnSocketError(string message, SocketError se)
        {
            this.manualDisconnection = false;
            if (this.attemptingReconnection)
            {
                this.Reconnect();
            }
            else
            {
                BitSwarmEvent evt = new BitSwarmEvent(BitSwarmEvent.IO_ERROR) {
                    Params = new Hashtable()
                };
                evt.Params["message"] = message + " ==> " + se.ToString();
                this.DispatchEvent(evt);
            }
        }

        private void Reconnect()
        {
            if (this.attemptingReconnection)
            {
                int reconnectionSeconds = this.sfs.GetReconnectionSeconds();
                DateTime now = DateTime.Now;
                TimeSpan span = (TimeSpan) ((this.firstReconnAttempt + new TimeSpan(0, 0, reconnectionSeconds)) - now);
                if (span > TimeSpan.Zero)
                {
                    this.log.Info(new string[] { string.Concat(new object[] { "Reconnection attempt: ", this.reconnCounter, " - time left:", span.TotalSeconds, " sec." }) });
                    this.SetTimeout(new ElapsedEventHandler(this.OnRetryConnectionEvent), this.reconnectionDelayMillis);
                    this.reconnCounter++;
                }
                else
                {
                    this.ExecuteDisconnection();
                }
            }
        }

        private void ReleaseResources()
        {
            this.threadManager.Stop();
            if ((this.udpManager != null) && this.udpManager.Inited)
            {
                this.udpManager.Disconnect();
            }
        }

        public void Send(IMessage message)
        {
            this.ioHandler.Codec.OnPacketWrite(message);
        }

        private void SetTimeout(ElapsedEventHandler handler, double timeout)
        {
            if (this.retryTimer == null)
            {
                this.retryTimer = new Timer(timeout);
                this.retryTimer.Elapsed += handler;
            }
            this.retryTimer.AutoReset = false;
            this.retryTimer.Enabled = true;
            this.retryTimer.Start();
        }

        public void StopReconnection()
        {
            this.attemptingReconnection = false;
            this.firstReconnAttempt = DateTime.MinValue;
            if (this.socket.IsConnected)
            {
                this.socket.Disconnect();
            }
            this.ExecuteDisconnection();
        }

        public int CompressionThreshold
        {
            get
            {
                return this.compressionThreshold;
            }
            set
            {
                if (value <= 100)
                {
                    throw new ArgumentException("Compression threshold cannot be < 100 bytes.");
                }
                this.compressionThreshold = value;
            }
        }

        public bool Connected
        {
            get
            {
                if (this.useBlueBox)
                {
                    return this.bbConnected;
                }
                if (this.socket == null)
                {
                    return false;
                }
                return this.socket.IsConnected;
            }
        }

        public string ConnectionIp
        {
            get
            {
                if (!this.Connected)
                {
                    return "Not Connected";
                }
                return this.lastIpAddress;
            }
        }

        public string ConnectionMode
        {
            get
            {
                return this.connectionMode;
            }
        }

        public int ConnectionPort
        {
            get
            {
                if (!this.Connected)
                {
                    return -1;
                }
                return this.lastTcpPort;
            }
        }

        public bool Debug
        {
            get
            {
                return ((this.sfs == null) || this.sfs.Debug);
            }
        }

        public EventDispatcher Dispatcher
        {
            get
            {
                return this.dispatcher;
            }
            set
            {
                this.dispatcher = value;
            }
        }

        public ExtensionController ExtController
        {
            get
            {
                return this.extController;
            }
        }

        public BBClient HttpClient
        {
            get
            {
                return this.bbClient;
            }
        }

        public Sfs2X.Bitswarm.IoHandler IoHandler
        {
            get
            {
                return this.ioHandler;
            }
            set
            {
                if (this.ioHandler != null)
                {
                    throw new SFSError("IOHandler is already set!");
                }
                this.ioHandler = value;
            }
        }

        public bool IsReconnecting
        {
            get
            {
                return this.attemptingReconnection;
            }
            set
            {
                this.attemptingReconnection = value;
            }
        }

        public Logger Log
        {
            get
            {
                if (this.sfs == null)
                {
                    return new Logger(null);
                }
                return this.sfs.Log;
            }
        }

        public int MaxMessageSize
        {
            get
            {
                return this.maxMessageSize;
            }
            set
            {
                this.maxMessageSize = value;
            }
        }

        public int ReconnectionSeconds
        {
            get
            {
                if (this.reconnectionSeconds < 0)
                {
                    return 0;
                }
                return this.reconnectionSeconds;
            }
            set
            {
                this.reconnectionSeconds = value;
            }
        }

        public SmartFox Sfs
        {
            get
            {
                return this.sfs;
            }
        }

        public ISocketLayer Socket
        {
            get
            {
                return this.socket;
            }
        }

        public SystemController SysController
        {
            get
            {
                return this.sysController;
            }
        }

        public Sfs2X.Core.ThreadManager ThreadManager
        {
            get
            {
                return this.threadManager;
            }
        }

        public IUDPManager UdpManager
        {
            get
            {
                return this.udpManager;
            }
            set
            {
                this.udpManager = value;
            }
        }

        public bool UseBlueBox
        {
            get
            {
                return this.useBlueBox;
            }
        }
    }
}

