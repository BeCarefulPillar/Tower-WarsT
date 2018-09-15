namespace Sfs2X.Core.Sockets
{
    using Sfs2X.Bitswarm;
    using Sfs2X.FSM;
    using Sfs2X.Logging;
    using System;
    using System.Collections;
    using System.Net;
    using System.Net.Sockets;
    using System.Runtime.CompilerServices;
    using System.Threading;

    public class TCPSocketLayer : ISocketLayer
    {
        private BitSwarmClient bitSwarm;
        private byte[] byteBuffer = new byte[READ_BUFFER_SIZE];
        private TcpClient connection;
        private static int connId = 0;
        private FiniteStateMachine fsm;
        private string ipAddress;//ipv6
        private volatile bool isDisconnecting = false;
        private Logger log;
        private NetworkStream networkStream;
        private ConnectionDelegate onConnect;
        private OnDataDelegate onData = null;
        private ConnectionDelegate onDisconnect;
        private OnErrorDelegate onError = null;
        private static readonly int READ_BUFFER_SIZE = 0x1000;
        private int socketNumber;
        private int socketPollSleep;
        private Thread thrConnect;
        private Thread thrSocketReader;

        public TCPSocketLayer(BitSwarmClient bs)
        {
            this.log = bs.Log;
            this.bitSwarm = bs;
            this.InitStates();
        }

        private void CallOnConnect()
        {
            if (this.onConnect != null)
            {
                this.onConnect();
            }
        }

        private void CallOnData(byte[] data)
        {
            if (this.onData != null)
            {
                this.bitSwarm.ThreadManager.EnqueueDataCall(this.onData, data);
            }
        }

        private void CallOnDisconnect()
        {
            if (this.onDisconnect != null)
            {
                this.onDisconnect();
            }
        }

        private void CallOnError(string msg, SocketError se)
        {
            if (this.onError != null)
            {
                this.onError(msg, se);
            }
        }

        public void Connect(string adr, int port)//ipv6
        {
            if (this.State != States.Disconnected)
            {
                this.LogWarn("Calling connect when the socket is not disconnected");
            }
            else
            {
                this.socketNumber = port;
                this.ipAddress = adr;
                this.fsm.ApplyTransition(Transitions.StartConnect);
                this.thrConnect = new Thread(new ThreadStart(this.ConnectThread));
                this.thrConnect.Start();
            }
        }

        private void ConnectThread()
        {
            string str;
            Thread.CurrentThread.Name = "ConnectionThread" + connId++;
            try
            {
                //this.connection = new TcpClient();
                //this.connection.Client.Connect(this.ipAddress, this.socketNumber);
                this.connection = new TcpClient(this.ipAddress, this.socketNumber);//ipv6
                this.networkStream = this.connection.GetStream();
                this.fsm.ApplyTransition(Transitions.ConnectionSuccess);
                this.CallOnConnect();
                this.thrSocketReader = new Thread(new ThreadStart(this.Read));
                this.thrSocketReader.Start();
            }
            catch (SocketException exception)
            {
                str = "Connection error: " + exception.Message + " " + exception.StackTrace;
                this.HandleError(str, exception.SocketErrorCode);
            }
            catch (Exception exception2)
            {
                str = "General exception on connection: " + exception2.Message + " " + exception2.StackTrace;
                this.HandleError(str);
            }
        }

        public void Disconnect()
        {
            this.Disconnect(null);
        }

        public void Disconnect(string reason)
        {
            if (this.State != States.Connected)
            {
                this.LogWarn("Calling disconnect when the socket is not connected");
            }
            else
            {
                this.isDisconnecting = true;
                try
                {
                    this.connection.Client.Shutdown(SocketShutdown.Both);
                    this.connection.Close();
                    this.networkStream.Close();
                }
                catch (Exception)
                {
                    this.LogWarn(">>> Trying to disconnect a non-connected tcp socket");
                }
                this.HandleDisconnection(reason);
                this.isDisconnecting = false;
            }
        }

        private void HandleBinaryData(byte[] buf, int size)
        {
            byte[] dst = new byte[size];
            Buffer.BlockCopy(buf, 0, dst, 0, size);
            this.CallOnData(dst);
        }

        private void HandleDisconnection()
        {
            this.HandleDisconnection(null);
        }

        private void HandleDisconnection(string reason)
        {
            if (this.State != States.Disconnected)
            {
                this.fsm.ApplyTransition(Transitions.Disconnect);
                if (reason == null)
                {
                    this.CallOnDisconnect();
                }
            }
        }

        private void HandleError(string err)
        {
            this.HandleError(err, SocketError.NotSocket);
        }

        private void HandleError(string err, SocketError se)
        {
            Hashtable data = new Hashtable();
            data["err"] = err;
            data["se"] = se;
            this.bitSwarm.ThreadManager.EnqueueCustom(new ParameterizedThreadStart(this.HandleErrorCallback), data);
        }

        private void HandleErrorCallback(object state)
        {
            Hashtable hashtable = state as Hashtable;
            string msg = (string) hashtable["err"];
            SocketError se = (SocketError) hashtable["se"];
            this.fsm.ApplyTransition(Transitions.ConnectionFailure);
            if (!this.isDisconnecting)
            {
                this.LogError(msg);
                this.CallOnError(msg, se);
            }
            this.HandleDisconnection();
        }

        private void InitStates()
        {
            this.fsm = new FiniteStateMachine();
            this.fsm.AddAllStates(typeof(States));
            this.fsm.AddStateTransition(States.Disconnected, States.Connecting, Transitions.StartConnect);
            this.fsm.AddStateTransition(States.Connecting, States.Connected, Transitions.ConnectionSuccess);
            this.fsm.AddStateTransition(States.Connecting, States.Disconnected, Transitions.ConnectionFailure);
            this.fsm.AddStateTransition(States.Connected, States.Disconnected, Transitions.Disconnect);
            this.fsm.SetCurrentState(States.Disconnected);
        }

        public void Kill()
        {
            this.fsm.ApplyTransition(Transitions.Disconnect);
            this.connection.Close();
        }

        private void LogError(string msg)
        {
            if (this.log != null)
            {
                this.log.Error(new string[] { "TCPSocketLayer: " + msg });
            }
        }

        private void LogWarn(string msg)
        {
            if (this.log != null)
            {
                this.log.Warn(new string[] { "TCPSocketLayer: " + msg });
            }
        }

        private void Read()
        {
            int size = 0;
            while (true)
            {
                try
                {
                    if (this.State != States.Connected)
                    {
                        return;
                    }
                    if (this.socketPollSleep > 0)
                    {
                        Sleep(this.socketPollSleep);
                    }
                    size = this.networkStream.Read(this.byteBuffer, 0, READ_BUFFER_SIZE);
                    if (size < 1)
                    {
                        this.HandleError("Connection closed by the remote side");
                        return;
                    }
                    this.HandleBinaryData(this.byteBuffer, size);
                }
                catch (Exception exception)
                {
                    this.HandleError("General error reading data from socket: " + exception.Message + " " + exception.StackTrace);
                    return;
                }
            }
        }

        private static void Sleep(int ms)
        {
            Thread.Sleep(10);
        }

        public void Write(byte[] data)
        {
            this.WriteSocket(data);
        }

        private void WriteSocket(byte[] buf)
        {
            if (this.State != States.Connected)
            {
                this.LogError("Trying to write to disconnected socket");
            }
            else
            {
                string str;
                try
                {
                    this.networkStream.Write(buf, 0, buf.Length);
                }
                catch (SocketException exception)
                {
                    str = "Error writing to socket: " + exception.Message;
                    this.HandleError(str, exception.SocketErrorCode);
                }
                catch (Exception exception2)
                {
                    str = "General error writing to socket: " + exception2.Message + " " + exception2.StackTrace;
                    this.HandleError(str);
                }
            }
        }

        public bool IsConnected
        {
            get
            {
                return (this.State == States.Connected);
            }
        }

        public ConnectionDelegate OnConnect
        {
            get
            {
                return this.onConnect;
            }
            set
            {
                this.onConnect = value;
            }
        }

        public OnDataDelegate OnData
        {
            get
            {
                return this.onData;
            }
            set
            {
                this.onData = value;
            }
        }

        public ConnectionDelegate OnDisconnect
        {
            get
            {
                return this.onDisconnect;
            }
            set
            {
                this.onDisconnect = value;
            }
        }

        public OnErrorDelegate OnError
        {
            get
            {
                return this.onError;
            }
            set
            {
                this.onError = value;
            }
        }

        public bool RequiresConnection
        {
            get
            {
                return true;
            }
        }

        public int SocketPollSleep
        {
            get
            {
                return this.socketPollSleep;
            }
            set
            {
                this.socketPollSleep = value;
            }
        }

        public States State
        {
            get
            {
                return (States) this.fsm.GetCurrentState();
            }
        }

        public enum States
        {
            Disconnected,
            Connecting,
            Connected
        }

        public enum Transitions
        {
            StartConnect,
            ConnectionSuccess,
            ConnectionFailure,
            Disconnect
        }
    }
}

