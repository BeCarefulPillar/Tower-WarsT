namespace Sfs2X.Core.Sockets
{
    using Sfs2X;
    using Sfs2X.Bitswarm;
    using Sfs2X.Logging;
    using System;
    using System.Collections;
    using System.Net;
    using System.Net.Sockets;
    using System.Runtime.CompilerServices;
    using System.Threading;

    public class UDPSocketLayer : ISocketLayer
    {
        private BitSwarmClient bitSwarm;
        private byte[] byteBuffer;
        private bool connected = false;
        private UdpClient connection;
        private string ipAddress;//ipv6
        private volatile bool isDisconnecting = false;
        private Logger log;
        private OnDataDelegate onData = null;
        private OnErrorDelegate onError = null;
        private IPEndPoint sender;
        private int socketNumber;
        private int socketPollSleep;
        private Thread thrSocketReader;

        public UDPSocketLayer(SmartFox sfs)
        {
            if (sfs != null)
            {
                this.log = sfs.Log;
                this.bitSwarm = sfs.BitSwarm;
            }
        }

        private void CallOnData(byte[] data)
        {
            if (this.onData != null)
            {
                this.bitSwarm.ThreadManager.EnqueueDataCall(this.onData, data);
            }
        }

        private void CallOnError(string msg, SocketError se)
        {
            if (this.onError != null)
            {
                this.onError(msg, se);
            }
        }

        private void CloseConnection()
        {
            try
            {
                this.connection.Client.Shutdown(SocketShutdown.Both);
                this.connection.Close();
            }
            catch (Exception)
            {
            }
            this.connected = false;
        }

        public void Connect(string adr, int port)//ipv6
        {
            string str;
            this.socketNumber = port;
            this.ipAddress = adr;
            try
            {
                this.connection = new UdpClient(this.ipAddress, this.socketNumber);
                this.sender = new IPEndPoint(IPAddress.IPv6Any, 0);
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
            this.isDisconnecting = true;
            this.CloseConnection();
            this.isDisconnecting = false;
        }

        public void Disconnect(string reason)
        {
        }

        private void HandleBinaryData(byte[] buf)
        {
            this.CallOnData(buf);
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
            if (!this.isDisconnecting)
            {
                this.CloseConnection();
                this.LogError(msg);
                this.CallOnError(msg, se);
            }
        }

        public void Kill()
        {
            throw new NotSupportedException();
        }

        private void LogError(string msg)
        {
            if (this.log != null)
            {
                this.log.Error(new string[] { "UDPSocketLayer: " + msg });
            }
        }

        private void LogWarn(string msg)
        {
            if (this.log != null)
            {
                this.log.Warn(new string[] { "UDPSocketLayer: " + msg });
            }
        }

        private void Read()
        {
            this.connected = true;
            while (this.connected)
            {
                try
                {
                    if (this.socketPollSleep > 0)
                    {
                        Sleep(this.socketPollSleep);
                    }
                    this.byteBuffer = this.connection.Receive(ref this.sender);
                    if ((this.byteBuffer == null) || (this.byteBuffer.Length == 0))
                    {
                        continue;
                    }
                    this.HandleBinaryData(this.byteBuffer);
                }
                catch (SocketException exception)
                {
                    this.HandleError("Error reading data from socket: " + exception.Message, exception.SocketErrorCode);
                }
                catch (ThreadAbortException)
                {
                    break;
                }
                catch (Exception exception2)
                {
                    this.HandleError("General error reading data from socket: " + exception2.Message + " " + exception2.StackTrace);
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
            string str;
            try
            {
                this.connection.Send(buf, buf.Length);
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

        public bool IsConnected
        {
            get
            {
                return this.connected;
            }
        }

        public ConnectionDelegate OnConnect
        {
            get
            {
                throw new NotSupportedException();
            }
            set
            {
                throw new NotSupportedException();
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
                throw new NotSupportedException();
            }
            set
            {
                throw new NotSupportedException();
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
                return false;
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
    }
}

