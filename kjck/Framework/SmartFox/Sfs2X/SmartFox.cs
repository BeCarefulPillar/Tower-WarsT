namespace Sfs2X
{
    using Sfs2X.Bitswarm;
    using Sfs2X.Core;
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Managers;
    using Sfs2X.Exceptions;
    using Sfs2X.Logging;
    using Sfs2X.Requests;
    using Sfs2X.Util;
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Net;
    using System.Timers;

    public class SmartFox : IDispatchable
    {
        private bool autoConnectOnConfig;
        private int bbConnectionAttempt;
        private BitSwarmClient bitSwarm;
        private IBuddyManager buddyManager;
        private const char CLIENT_TYPE_SEPARATOR = ':';
        private string clientDetails;
        private ConfigData config;
        private string currentZone;
        private bool debug;
        private const int DEFAULT_HTTP_PORT = 0x1f90;
        private Timer disconnectTimer;
        private EventDispatcher dispatcher;
        private object eventsLocker;
        private Queue<BaseEvent> eventsQueue;
        private bool inited;
        private bool isConnecting;
        private bool isJoining;
        private Sfs2X.Util.LagMonitor lagMonitor;
        private string lastIpAddress;
        private Room lastJoinedRoom;
        private Sfs2X.Logging.Logger log;
        private int majVersion;
        private const int MAX_BB_CONNECT_ATTEMPTS = 3;
        private int minVersion;
        private User mySelf;
        private IRoomManager roomManager;
        private string sessionToken;
        private int subVersion;
        private bool threadSafeMode;
        private bool useBlueBox;
        private IUserManager userManager;

        public SmartFox()
        {
            this.majVersion = 1;
            this.minVersion = 5;
            this.subVersion = 7;
            this.clientDetails = "Unity";
            this.useBlueBox = true;
            this.isJoining = false;
            this.inited = false;
            this.debug = false;
            this.threadSafeMode = true;
            this.isConnecting = false;
            this.autoConnectOnConfig = false;
            this.eventsLocker = new object();
            this.eventsQueue = new Queue<BaseEvent>();
            this.bbConnectionAttempt = 0;
            this.disconnectTimer = null;
            this.log = new Sfs2X.Logging.Logger(this);
            this.debug = false;
            this.Initialize();
        }

        public SmartFox(bool debug)
        {
            this.majVersion = 1;
            this.minVersion = 5;
            this.subVersion = 7;
            this.clientDetails = "Unity";
            this.useBlueBox = true;
            this.isJoining = false;
            this.inited = false;
            this.debug = false;
            this.threadSafeMode = true;
            this.isConnecting = false;
            this.autoConnectOnConfig = false;
            this.eventsLocker = new object();
            this.eventsQueue = new Queue<BaseEvent>();
            this.bbConnectionAttempt = 0;
            this.disconnectTimer = null;
            this.log = new Sfs2X.Logging.Logger(this);
            this.log.EnableEventDispatching = true;
            if (debug)
            {
                this.log.LoggingLevel = Sfs2X.Logging.LogLevel.DEBUG;
            }
            this.debug = debug;
            this.Initialize();
        }

        public void AddEventListener(string eventType, EventListenerDelegate listener)
        {
            this.dispatcher.AddEventListener(eventType, listener);
        }

        public void AddJoinedRoom(Room room)
        {
            if (this.roomManager.ContainsRoom(room.Id))
            {
                throw new SFSError(string.Concat(new object[] { "Unexpected: joined room already exists for this User: ", this.mySelf.Name, ", Room: ", room }));
            }
            this.roomManager.AddRoom(room);
            this.lastJoinedRoom = room;
        }

        public void AddLogListener(Sfs2X.Logging.LogLevel logLevel, EventListenerDelegate eventListener)
        {
            this.AddEventListener(LoggerEvent.LogEventType(logLevel), eventListener);
            this.log.EnableEventDispatching = true;
        }

        public void Connect()
        {
            this.Connect(null, -1);
        }

        public void Connect(ConfigData cfg)
        {
            this.ValidateConfig(cfg);
            this.Connect(cfg.Host, cfg.Port);
        }

        public void Connect(string host)
        {
            this.Connect(host, -1);
        }

        public void Connect(string host, int port)
        {
            if (this.IsConnected)
            {
                this.log.Warn(new string[] { "Already connected" });
            }
            else if (this.isConnecting)
            {
                this.log.Warn(new string[] { "A connection attempt is already in progress" });
            }
            else
            {
                if (this.config != null)
                {
                    if (host == null)
                    {
                        host = this.config.Host;
                    }
                    if (port == -1)
                    {
                        port = this.config.Port;
                    }
                }
                if ((host == null) || (host.Length == 0))
                {
                    throw new ArgumentException("Invalid connection host/address");
                }
                if ((port < 0) || (port > 0xffff))
                {
                    throw new ArgumentException("Invalid connection port");
                }
                //try
                //{
                //    IPAddress.Parse(host);
                //}
                //catch (FormatException)
                //{
                //    try
                //    {
                //        host = Dns.GetHostEntry(host).AddressList[0].ToString();
                //    }
                //    catch (Exception exception)
                //    {
                //        string str = "Failed to lookup hostname " + host + ". Connection failed. Reason " + exception.Message;
                //        this.log.Error(new string[] { str });
                //        Hashtable data = new Hashtable();
                //        data["success"] = false;
                //        data["errorMessage"] = str;
                //        this.DispatchEvent(new SFSEvent(SFSEvent.CONNECTION, data));
                //        return;
                //    }
                //}
                this.lastIpAddress = host;
                this.isConnecting = true;
                this.bitSwarm.Connect(host, port);
            }
        }

        public void Disconnect()
        {
            if (this.IsConnected)
            {
                if (this.bitSwarm.ReconnectionSeconds > 0)
                {
                    this.Send(new ManualDisconnectionRequest());
                }
                this.DisconnectConnection(100);
            }
            else
            {
                this.log.Info(new string[] { "You are not connected" });
            }
        }

        private void DisconnectConnection(int timeout)
        {
            if (this.disconnectTimer == null)
            {
                this.disconnectTimer = new Timer();
            }
            this.disconnectTimer.AutoReset = false;
            this.disconnectTimer.Elapsed += new ElapsedEventHandler(this.OnDisconnectConnectionEvent);
            this.disconnectTimer.Enabled = true;
        }

        internal void DispatchEvent(BaseEvent evt)
        {
            if (!this.threadSafeMode)
            {
                this.Dispatcher.DispatchEvent(evt);
            }
            else
            {
                this.EnqueueEvent(evt);
            }
        }

        public void EnableLagMonitor(bool enabled)
        {
            this.EnableLagMonitor(enabled, 4, 10);
        }

        public void EnableLagMonitor(bool enabled, int interval)
        {
            this.EnableLagMonitor(enabled, interval, 10);
        }

        public void EnableLagMonitor(bool enabled, int interval, int queueSize)
        {
            if (this.mySelf == null)
            {
                this.log.Warn(new string[] { "Lag Monitoring requires that you are logged in a Zone!" });
            }
            else if (enabled)
            {
                this.lagMonitor = new Sfs2X.Util.LagMonitor(this, interval, queueSize);
                this.lagMonitor.Start();
            }
            else
            {
                this.lagMonitor.Stop();
            }
        }

        private void EnqueueEvent(BaseEvent evt)
        {
            lock (this.eventsLocker)
            {
                this.eventsQueue.Enqueue(evt);
            }
        }

        public int GetReconnectionSeconds()
        {
            return this.bitSwarm.ReconnectionSeconds;
        }

        public Room GetRoomById(int id)
        {
            return this.roomManager.GetRoomById(id);
        }

        public Room GetRoomByName(string name)
        {
            return this.roomManager.GetRoomByName(name);
        }

        public List<Room> GetRoomListFromGroup(string groupId)
        {
            return this.roomManager.GetRoomListFromGroup(groupId);
        }

        public BitSwarmClient GetSocketEngine()
        {
            return this.bitSwarm;
        }

        public void HandleClientDisconnection(string reason)
        {
            this.bitSwarm.ReconnectionSeconds = 0;
            this.bitSwarm.Disconnect(reason);
            this.Reset();
            if (reason != null)
            {
                Hashtable data = new Hashtable();
                data.Add("reason", reason);
                this.DispatchEvent(new SFSEvent(SFSEvent.CONNECTION_LOST, data));
            }
        }

        private void HandleConnectionProblem(BaseEvent e)
        {
            if ((this.IsConnecting && this.useBlueBox) && (this.bbConnectionAttempt < 3))
            {
                this.bbConnectionAttempt++;
                this.bitSwarm.ForceBlueBox(true);
                int port = (this.config != null) ? this.config.HttpPort : 0x1f90;
                this.bitSwarm.Connect(this.lastIpAddress, port);
                this.DispatchEvent(new SFSEvent(SFSEvent.CONNECTION_ATTEMPT_HTTP, new Hashtable()));
            }
            else
            {
                this.bitSwarm.ForceBlueBox(false);
                this.bbConnectionAttempt = 0;
                BitSwarmEvent event2 = e as BitSwarmEvent;
                Hashtable data = new Hashtable();
                data["success"] = false;
                data["errorMessage"] = event2.Params["message"];
                this.DispatchEvent(new SFSEvent(SFSEvent.CONNECTION, data));
                this.isConnecting = false;
                this.bitSwarm.Destroy();
            }
        }

        public void HandleHandShake(BaseEvent evt)
        {
            Hashtable hashtable;
            ISFSObject obj2 = evt.Params["message"] as ISFSObject;
            if (obj2.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                this.sessionToken = obj2.GetUtfString(HandshakeRequest.KEY_SESSION_TOKEN);
                this.bitSwarm.CompressionThreshold = obj2.GetInt(HandshakeRequest.KEY_COMPRESSION_THRESHOLD);
                this.bitSwarm.MaxMessageSize = obj2.GetInt(HandshakeRequest.KEY_MAX_MESSAGE_SIZE);
                if (this.debug)
                {
                    this.log.Debug(new string[] { string.Format("Handshake response: tk => {0}, ct => {1}", this.sessionToken, this.bitSwarm.CompressionThreshold) });
                }
                if (this.bitSwarm.IsReconnecting)
                {
                    this.bitSwarm.IsReconnecting = false;
                    this.DispatchEvent(new SFSEvent(SFSEvent.CONNECTION_RESUME));
                }
                else
                {
                    this.isConnecting = false;
                    hashtable = new Hashtable();
                    hashtable["success"] = true;
                    this.DispatchEvent(new SFSEvent(SFSEvent.CONNECTION, hashtable));
                }
            }
            else
            {
                short @short = obj2.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, this.log, obj2.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                hashtable = new Hashtable();
                hashtable["success"] = false;
                hashtable["errorMessage"] = str;
                hashtable["errorCode"] = @short;
                this.DispatchEvent(new SFSEvent(SFSEvent.CONNECTION, hashtable));
            }
        }

        public void HandleLogin(BaseEvent evt)
        {
            this.currentZone = evt.Params["zone"] as string;
        }

        public void HandleLogout()
        {
            if ((this.lagMonitor != null) && this.lagMonitor.IsRunning)
            {
                this.lagMonitor.Stop();
            }
            this.userManager = new SFSGlobalUserManager(this);
            this.roomManager = new SFSRoomManager(this);
            this.isJoining = false;
            this.lastJoinedRoom = null;
            this.currentZone = null;
            this.mySelf = null;
        }

        public void HandleReconnectionFailure()
        {
            this.SetReconnectionSeconds(0);
            this.bitSwarm.StopReconnection();
        }

        private void Initialize()
        {
            if (!this.inited)
            {
                if (this.dispatcher == null)
                {
                    this.dispatcher = new EventDispatcher(this);
                }
                this.bitSwarm = new BitSwarmClient(this);
                this.bitSwarm.IoHandler = new SFSIOHandler(this.bitSwarm);
                this.bitSwarm.Init();
                this.bitSwarm.Dispatcher.AddEventListener(BitSwarmEvent.CONNECT, new EventListenerDelegate(this.OnSocketConnect));
                this.bitSwarm.Dispatcher.AddEventListener(BitSwarmEvent.DISCONNECT, new EventListenerDelegate(this.OnSocketClose));
                this.bitSwarm.Dispatcher.AddEventListener(BitSwarmEvent.RECONNECTION_TRY, new EventListenerDelegate(this.OnSocketReconnectionTry));
                this.bitSwarm.Dispatcher.AddEventListener(BitSwarmEvent.IO_ERROR, new EventListenerDelegate(this.OnSocketIOError));
                this.bitSwarm.Dispatcher.AddEventListener(BitSwarmEvent.SECURITY_ERROR, new EventListenerDelegate(this.OnSocketSecurityError));
                this.bitSwarm.Dispatcher.AddEventListener(BitSwarmEvent.DATA_ERROR, new EventListenerDelegate(this.OnSocketDataError));
                this.inited = true;
                this.Reset();
            }
        }

        public void InitUDP()
        {
            this.InitUDP(null, -1);
        }

        public void InitUDP(string udpHost)
        {
            this.InitUDP(udpHost, -1);
        }

        public void InitUDP(string udpHost, int udpPort)
        {
            if (!this.IsConnected)
            {
                this.Logger.Warn(new string[] { "Cannot initialize UDP protocol until the client is connected to SFS2X." });
            }
            else
            {
                if (this.config != null)
                {
                    if (udpHost == null)
                    {
                        udpHost = this.config.UdpHost;
                    }
                    if (udpPort == -1)
                    {
                        udpPort = this.config.UdpPort;
                    }
                }
                if ((udpHost == null) || (udpHost.Length == 0))
                {
                    throw new ArgumentException("Invalid UDP host/address");
                }
                if ((udpPort < 0) || (udpPort > 0xffff))
                {
                    throw new ArgumentException("Invalid UDP port range");
                }
                //try
                //{
                //    IPAddress.Parse(udpHost);
                //}
                //catch (FormatException)
                //{
                //    try
                //    {
                //        udpHost = Dns.GetHostEntry(udpHost).AddressList[0].ToString();
                //    }
                //    catch (Exception exception)
                //    {
                //        string str = "Failed to lookup hostname " + udpHost + ". UDP init failed. Reason " + exception.Message;
                //        this.log.Error(new string[] { str });
                //        Hashtable data = new Hashtable();
                //        data["success"] = false;
                //        this.DispatchEvent(new SFSEvent(SFSEvent.UDP_INIT, data));
                //        return;
                //    }
                //}//ipv6
                if (!((this.bitSwarm.UdpManager != null) && this.bitSwarm.UdpManager.Inited))
                {
                    IUDPManager manager = new UDPManager(this);
                    this.bitSwarm.UdpManager = manager;
                }
                try
                {
                    this.bitSwarm.UdpManager.Initialize(udpHost, udpPort);
                }
                catch (Exception exception2)
                {
                    this.log.Error(new string[] { "Exception initializing UDP: " + exception2.Message });
                }
            }
        }

        public void KillConnection()
        {
            this.bitSwarm.KillConnection();
        }

        public void LoadConfig()
        {
            this.LoadConfig("sfs-config.xml", true);
        }

        public void LoadConfig(bool connectOnSuccess)
        {
            this.LoadConfig("sfs-config.xml", connectOnSuccess);
        }

        public void LoadConfig(string filePath)
        {
            this.LoadConfig(filePath, true);
        }

        public void LoadConfig(string filePath, bool connectOnSuccess)
        {
            ConfigLoader loader = new ConfigLoader(this);
            loader.Dispatcher.AddEventListener(SFSEvent.CONFIG_LOAD_SUCCESS, new EventListenerDelegate(this.OnConfigLoadSuccess));
            loader.Dispatcher.AddEventListener(SFSEvent.CONFIG_LOAD_FAILURE, new EventListenerDelegate(this.OnConfigLoadFailure));
            this.autoConnectOnConfig = connectOnSuccess;
            loader.LoadConfig(filePath);
        }

        private void OnConfigLoadFailure(BaseEvent e)
        {
            SFSEvent event2 = e as SFSEvent;
            this.log.Error(new string[] { "Failed to load config: " + ((string) event2.Params["message"]) });
            ConfigLoader target = event2.Target as ConfigLoader;
            target.Dispatcher.RemoveEventListener(SFSEvent.CONFIG_LOAD_SUCCESS, new EventListenerDelegate(this.OnConfigLoadSuccess));
            target.Dispatcher.RemoveEventListener(SFSEvent.CONFIG_LOAD_FAILURE, new EventListenerDelegate(this.OnConfigLoadFailure));
            BaseEvent evt = new SFSEvent(SFSEvent.CONFIG_LOAD_FAILURE);
            this.DispatchEvent(evt);
        }

        private void OnConfigLoadSuccess(BaseEvent e)
        {
            SFSEvent event2 = e as SFSEvent;
            ConfigLoader target = event2.Target as ConfigLoader;
            ConfigData cfgData = event2.Params["cfg"] as ConfigData;
            target.Dispatcher.RemoveEventListener(SFSEvent.CONFIG_LOAD_SUCCESS, new EventListenerDelegate(this.OnConfigLoadSuccess));
            target.Dispatcher.RemoveEventListener(SFSEvent.CONFIG_LOAD_FAILURE, new EventListenerDelegate(this.OnConfigLoadFailure));
            this.ValidateConfig(cfgData);
            Hashtable data = new Hashtable();
            data["config"] = cfgData;
            BaseEvent evt = new SFSEvent(SFSEvent.CONFIG_LOAD_SUCCESS, data);
            this.DispatchEvent(evt);
            if (this.autoConnectOnConfig)
            {
                this.Connect(this.config.Host, this.config.Port);
            }
        }

        private void OnDisconnectConnectionEvent(object source, ElapsedEventArgs e)
        {
            this.disconnectTimer.Enabled = false;
            this.HandleClientDisconnection(ClientDisconnectionReason.MANUAL);
        }

        private void OnSocketClose(BaseEvent e)
        {
            BitSwarmEvent event2 = e as BitSwarmEvent;
            this.Reset();
            Hashtable data = new Hashtable();
            data["reason"] = event2.Params["reason"];
            this.DispatchEvent(new SFSEvent(SFSEvent.CONNECTION_LOST, data));
        }

        private void OnSocketConnect(BaseEvent e)
        {
            BitSwarmEvent event2 = e as BitSwarmEvent;
            if ((bool) event2.Params["success"])
            {
                this.SendHandshakeRequest((bool) event2.Params["isReconnection"]);
            }
            else
            {
                this.log.Warn(new string[] { "Connection attempt failed" });
                this.HandleConnectionProblem(event2);
            }
        }

        private void OnSocketDataError(BaseEvent e)
        {
            Hashtable data = new Hashtable();
            data["errorMessage"] = e.Params["message"];
            this.DispatchEvent(new SFSEvent(SFSEvent.SOCKET_ERROR, data));
        }

        private void OnSocketIOError(BaseEvent e)
        {
            BitSwarmEvent event2 = e as BitSwarmEvent;
            if (this.isConnecting)
            {
                this.HandleConnectionProblem(event2);
            }
        }

        private void OnSocketReconnectionTry(BaseEvent e)
        {
            this.DispatchEvent(new SFSEvent(SFSEvent.CONNECTION_RETRY));
        }

        private void OnSocketSecurityError(BaseEvent e)
        {
            BitSwarmEvent event2 = e as BitSwarmEvent;
            if (this.isConnecting)
            {
                this.HandleConnectionProblem(event2);
            }
        }

        public void ProcessEvents()
        {
            if (this.threadSafeMode)
            {
                BaseEvent[] eventArray;
                lock (this.eventsLocker)
                {
                    eventArray = this.eventsQueue.ToArray();
                    this.eventsQueue.Clear();
                }
                foreach (BaseEvent event2 in eventArray)
                {
                    this.Dispatcher.DispatchEvent(event2);
                }
            }
        }

        public void RemoveAllEventListeners()
        {
            this.dispatcher.RemoveAll();
        }

        public void RemoveEventListener(string eventType, EventListenerDelegate listener)
        {
            this.dispatcher.RemoveEventListener(eventType, listener);
        }

        public void RemoveJoinedRoom(Room room)
        {
            this.roomManager.RemoveRoom(room);
            if (this.JoinedRooms.Count > 0)
            {
                this.lastJoinedRoom = this.JoinedRooms[this.JoinedRooms.Count - 1];
            }
        }

        public void RemoveLogListener(Sfs2X.Logging.LogLevel logLevel, EventListenerDelegate eventListener)
        {
            this.RemoveEventListener(LoggerEvent.LogEventType(logLevel), eventListener);
        }

        private void Reset()
        {
            this.bbConnectionAttempt = 0;
            this.userManager = new SFSGlobalUserManager(this);
            this.roomManager = new SFSRoomManager(this);
            this.buddyManager = new SFSBuddyManager(this);
            if (this.lagMonitor != null)
            {
                this.lagMonitor.Destroy();
            }
            this.isJoining = false;
            this.currentZone = null;
            this.lastJoinedRoom = null;
            this.sessionToken = null;
            this.mySelf = null;
        }

        public void Send(IRequest request)
        {
            if (!this.IsConnected)
            {
                this.log.Warn(new string[] { "You are not connected. Request cannot be sent: " + request });
            }
            else
            {
                try
                {
                    if (request is JoinRoomRequest)
                    {
                        if (this.isJoining)
                        {
                            return;
                        }
                        this.isJoining = true;
                    }
                    request.Validate(this);
                    request.Execute(this);
                    this.bitSwarm.Send(request.Message);
                }
                catch (SFSValidationError error)
                {
                    string message = error.Message;
                    foreach (string str2 in error.Errors)
                    {
                        message = message + "\t" + str2 + "\n";
                    }
                    this.log.Warn(new string[] { message });
                }
                catch (SFSCodecError error2)
                {
                    this.log.Warn(new string[] { error2.Message });
                }
            }
        }

        private void SendHandshakeRequest(bool isReconnection)
        {
            IRequest request = new HandshakeRequest(this.Version, isReconnection ? this.sessionToken : null, this.clientDetails);
            this.Send(request);
        }

        public void SetClientDetails(string platformId, string version)
        {
            if (this.IsConnected)
            {
                this.log.Warn(new string[] { "SetClientDetails must be called before the connection is started" });
            }
            else
            {
                this.clientDetails = (platformId != null) ? platformId.Replace(':', ' ') : "";
                this.clientDetails = this.clientDetails + ':';
                this.clientDetails = this.clientDetails + ((version != null) ? version.Replace(':', ' ') : "");
            }
        }

        public void SetReconnectionSeconds(int seconds)
        {
            this.bitSwarm.ReconnectionSeconds = seconds;
        }

        private void ValidateConfig(ConfigData cfgData)
        {
            if ((cfgData.Host == null) || (cfgData.Host.Length == 0))
            {
                throw new ArgumentException("Invalid Host/IpAddress in external config file");
            }
            if ((cfgData.Port < 0) || (cfgData.Port > 0xffff))
            {
                throw new ArgumentException("Invalid TCP port in external config file");
            }
            if ((cfgData.Zone == null) || (cfgData.Zone.Length == 0))
            {
                throw new ArgumentException("Invalid Zone name in external config file");
            }
            this.config = cfgData;
            this.debug = cfgData.Debug;
            this.useBlueBox = cfgData.UseBlueBox;
        }

        public BitSwarmClient BitSwarm
        {
            get
            {
                return this.bitSwarm;
            }
        }

        public IBuddyManager BuddyManager
        {
            get
            {
                return this.buddyManager;
            }
        }

        public int CompressionThreshold
        {
            get
            {
                return this.bitSwarm.CompressionThreshold;
            }
        }

        public ConfigData Config
        {
            get
            {
                return this.config;
            }
        }

        public string ConnectionMode
        {
            get
            {
                return this.bitSwarm.ConnectionMode;
            }
        }

        public string CurrentIp
        {
            get
            {
                return this.bitSwarm.ConnectionIp;
            }
        }

        public int CurrentPort
        {
            get
            {
                return this.bitSwarm.ConnectionPort;
            }
        }

        public string CurrentZone
        {
            get
            {
                return this.currentZone;
            }
        }

        public bool Debug
        {
            get
            {
                return this.debug;
            }
            set
            {
                this.debug = value;
            }
        }

        public EventDispatcher Dispatcher
        {
            get
            {
                return this.dispatcher;
            }
        }

        public string HttpUploadURI
        {
            get
            {
                if ((this.config == null) || (this.mySelf == null))
                {
                    return null;
                }
                return string.Concat(new object[] { "http://", this.config.Host, ":", this.config.HttpPort, "/BlueBox/SFS2XFileUpload?sessHashId=", this.sessionToken });
            }
        }

        public bool IsConnected
        {
            get
            {
                bool connected = false;
                if (this.bitSwarm != null)
                {
                    connected = this.bitSwarm.Connected;
                }
                return connected;
            }
        }

        public bool IsConnecting
        {
            get
            {
                return this.isConnecting;
            }
        }

        public bool IsJoining
        {
            get
            {
                return this.isJoining;
            }
            set
            {
                this.isJoining = value;
            }
        }

        public List<Room> JoinedRooms
        {
            get
            {
                return this.roomManager.GetJoinedRooms();
            }
        }

        public Sfs2X.Util.LagMonitor LagMonitor
        {
            get
            {
                return this.lagMonitor;
            }
        }

        public Room LastJoinedRoom
        {
            get
            {
                return this.lastJoinedRoom;
            }
            set
            {
                this.lastJoinedRoom = value;
            }
        }

        public Sfs2X.Logging.Logger Log
        {
            get
            {
                return this.log;
            }
        }

        public Sfs2X.Logging.Logger Logger
        {
            get
            {
                return this.log;
            }
        }

        public int MaxMessageSize
        {
            get
            {
                return this.bitSwarm.MaxMessageSize;
            }
        }

        public User MySelf
        {
            get
            {
                return this.mySelf;
            }
            set
            {
                this.mySelf = value;
            }
        }

        public List<Room> RoomList
        {
            get
            {
                return this.roomManager.GetRoomList();
            }
        }

        public IRoomManager RoomManager
        {
            get
            {
                return this.roomManager;
            }
        }

        public string SessionToken
        {
            get
            {
                return this.sessionToken;
            }
        }

        public bool ThreadSafeMode
        {
            get
            {
                return this.threadSafeMode;
            }
            set
            {
                this.threadSafeMode = value;
            }
        }

        public bool UdpAvailable
        {
            get
            {
                return true;
            }
        }

        public bool UdpInited
        {
            get
            {
                return ((this.bitSwarm.UdpManager != null) && this.bitSwarm.UdpManager.Inited);
            }
        }

        public bool UseBlueBox
        {
            get
            {
                return this.useBlueBox;
            }
            set
            {
                this.useBlueBox = value;
            }
        }

        public IUserManager UserManager
        {
            get
            {
                return this.userManager;
            }
        }

        public string Version
        {
            get
            {
                return string.Concat(new object[] { this.majVersion, ".", this.minVersion, ".", this.subVersion });
            }
        }
    }
}

