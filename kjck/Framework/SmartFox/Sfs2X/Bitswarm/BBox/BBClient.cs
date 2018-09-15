namespace Sfs2X.Bitswarm.BBox
{
    using Sfs2X.Bitswarm;
    using Sfs2X.Core;
    using Sfs2X.Http;
    using Sfs2X.Logging;
    using Sfs2X.Util;
    using System;
    using System.Collections;
    using System.Threading;

    public class BBClient : IDispatchable
    {
        private const string BB_DEFAULT_HOST = "localhost";
        private const int BB_DEFAULT_PORT = 0x1f90;
        private const string BB_NULL = "null";
        public const string BB_SERVLET = "BlueBox/BlueBox.do";
        private string bbUrl;
        private const string CMD_CONNECT = "connect";
        private const string CMD_DATA = "data";
        private const string CMD_DISCONNECT = "disconnect";
        private const string CMD_POLL = "poll";
        private bool debug;
        private const int DEFAULT_POLL_SPEED = 300;
        private EventDispatcher dispatcher;
        private const string ERR_INVALID_SESSION = "err01";
        private string host = "localhost";
        private bool isConnected = false;
        private Logger log;
        private const int MAX_POLL_SPEED = 0x1388;
        private const int MIN_POLL_SPEED = 50;
        private int pollSpeed = 300;
        private Timer pollTimer = null;
        private int port = 0x1f90;
        private const char SEP = '|';
        private string sessId;
        private const string SFS_HTTP = "sfsHttp";

        public BBClient(BitSwarmClient bs)
        {
            this.debug = bs.Debug;
            this.log = bs.Log;
            if (this.dispatcher == null)
            {
                this.dispatcher = new EventDispatcher(this);
            }
        }

        public void AddEventListener(string eventType, EventListenerDelegate listener)
        {
            this.dispatcher.AddEventListener(eventType, listener);
        }

        public void Close()
        {
            this.HandleConnectionLost(true);
        }

        public void Connect(string host, int port)
        {
            if (this.isConnected)
            {
                throw new Exception("BlueBox session is already connected");
            }
            this.host = host;
            this.port = port;
            this.bbUrl = string.Concat(new object[] { "http://", host, ":", port, "/BlueBox/BlueBox.do" });
            if (this.debug)
            {
                this.log.Debug(new string[] { "[ BB-Connect ]: " + this.bbUrl });
            }
            this.SendRequest("connect");
        }

        private ByteArray DecodeResponse(string rawData)
        {
            return new ByteArray(Convert.FromBase64String(rawData));
        }

        private void DispatchEvent(BaseEvent evt)
        {
            this.dispatcher.DispatchEvent(evt);
        }

        private string EncodeRequest(string cmd)
        {
            return this.EncodeRequest(cmd, null);
        }

        private string EncodeRequest(string cmd, object data)
        {
            string str2 = "";
            if (cmd == null)
            {
                cmd = "null";
            }
            if (data == null)
            {
                str2 = "null";
            }
            else if (data is ByteArray)
            {
                str2 = Convert.ToBase64String(((ByteArray) data).Bytes);
            }
            return (((this.sessId == null) ? "null" : this.sessId) + Convert.ToString('|') + cmd + Convert.ToString('|') + str2);
        }

        private SFSWebClient GetWebClient()
        {
            SFSWebClient client = new SFSWebClient();
            client.OnHttpResponse = (HttpResponseDelegate)Delegate.Combine(client.OnHttpResponse, new HttpResponseDelegate(this.OnHttpResponse));
            //client = new SFSWebClient { OnHttpResponse = (HttpResponseDelegate)Delegate.Combine(client.OnHttpResponse, new HttpResponseDelegate(this.OnHttpResponse)) };
            return client;
        }

        private void HandleConnectionLost(bool fireEvent)
        {
            if (this.isConnected)
            {
                this.isConnected = false;
                this.sessId = null;
                this.pollTimer.Dispose();
                if (fireEvent)
                {
                    this.DispatchEvent(new BBEvent(BBEvent.DISCONNECT));
                }
            }
        }

        internal void OnHttpResponse(bool error, string response)
        {
            Hashtable hashtable;
            if (error)
            {
                hashtable = new Hashtable();
                hashtable["message"] = response;
                this.HandleConnectionLost(true);
                this.DispatchEvent(new BBEvent(BBEvent.IO_ERROR, hashtable));
            }
            else
            {
                try
                {
                    if (this.debug)
                    {
                        this.log.Debug(new string[] { "[ BB-Receive ]: " + response.ToString() });
                    }
                    string[] strArray = response.Split(new char[] { '|' });
                    if (strArray.Length >= 2)
                    {
                        string str = strArray[0];
                        string rawData = strArray[1];
                        switch (str)
                        {
                            case "connect":
                                this.sessId = rawData;
                                this.isConnected = true;
                                this.DispatchEvent(new BBEvent(BBEvent.CONNECT));
                                this.Poll(null);
                                return;

                            case "poll":
                            {
                                ByteArray array = null;
                                if (rawData != "null")
                                {
                                    array = this.DecodeResponse(rawData);
                                }
                                if (this.isConnected)
                                {
                                    this.pollTimer = new Timer(new TimerCallback(this.Poll), null, this.pollSpeed, -1);
                                }
                                if (rawData != "null")
                                {
                                    hashtable = new Hashtable();
                                    hashtable["data"] = array;
                                    this.DispatchEvent(new BBEvent(BBEvent.DATA, hashtable));
                                }
                                break;
                            }
                            case "err01":
                                hashtable = new Hashtable();
                                hashtable["message"] = "Invalid http session !";
                                this.HandleConnectionLost(false);
                                this.DispatchEvent(new BBEvent(BBEvent.IO_ERROR, hashtable));
                                break;
                        }
                    }
                }
                catch (Exception exception)
                {
                    hashtable = new Hashtable();
                    hashtable["message"] = exception.Message + " " + exception.StackTrace;
                    this.HandleConnectionLost(false);
                    this.DispatchEvent(new BBEvent(BBEvent.IO_ERROR, hashtable));
                }
            }
        }

        private void Poll(object state)
        {
            if (this.isConnected)
            {
                this.SendRequest("poll");
            }
        }

        public void Send(ByteArray binData)
        {
            if (!this.isConnected)
            {
                throw new Exception("Can't send data, BlueBox connection is not active");
            }
            this.SendRequest("data", binData);
        }

        private void SendRequest(string cmd)
        {
            this.SendRequest(cmd, null);
        }

        private void SendRequest(string cmd, object data)
        {
            string stringToEscape = this.EncodeRequest(cmd, data);
            string encodedData = Uri.EscapeDataString(stringToEscape);
            if (this.debug)
            {
                this.log.Debug(new string[] { "[ BB-Send ]: " + stringToEscape });
            }
            this.GetWebClient().UploadValuesAsync(new Uri(this.bbUrl), "sfsHttp", encodedData);
        }

        public EventDispatcher Dispatcher
        {
            get
            {
                return this.dispatcher;
            }
        }

        public string Host
        {
            get
            {
                return this.host;
            }
        }

        public bool IsConnected
        {
            get
            {
                return (this.sessId != null);
            }
        }

        public bool IsDebug
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

        public int PollSpeed
        {
            get
            {
                return this.pollSpeed;
            }
            set
            {
                this.pollSpeed = ((value >= 50) && (value <= 0x1388)) ? value : 300;
            }
        }

        public int Port
        {
            get
            {
                return this.port;
            }
        }

        public string SessionId
        {
            get
            {
                return this.sessId;
            }
        }
    }
}

