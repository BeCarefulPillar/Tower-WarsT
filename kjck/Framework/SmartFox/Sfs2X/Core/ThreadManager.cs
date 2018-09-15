namespace Sfs2X.Core
{
    using Sfs2X.Core.Sockets;
    using Sfs2X.Util;
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Threading;

    public class ThreadManager
    {
        private bool inHasQueuedItems = false;
        private object inQueueLocker = new object();
        private Thread inThread;
        private Queue<Hashtable> inThreadQueue = new Queue<Hashtable>();
        private bool outHasQueuedItems = false;
        private object outQueueLocker = new object();
        private Thread outThread;
        private Queue<Hashtable> outThreadQueue = new Queue<Hashtable>();
        private bool running = false;

        public void EnqueueCustom(ParameterizedThreadStart callback, Hashtable data)
        {
            data["callback"] = callback;
            lock (this.inQueueLocker)
            {
                this.inThreadQueue.Enqueue(data);
                this.inHasQueuedItems = true;
            }
        }

        public void EnqueueDataCall(OnDataDelegate callback, byte[] data)
        {
            Hashtable item = new Hashtable();
            item["callback"] = callback;
            item["data"] = data;
            lock (this.inQueueLocker)
            {
                this.inThreadQueue.Enqueue(item);
                this.inHasQueuedItems = true;
            }
        }

        public void EnqueueSend(WriteBinaryDataDelegate callback, PacketHeader header, ByteArray data, bool udp)
        {
            Hashtable item = new Hashtable();
            item["callback"] = callback;
            item["header"] = header;
            item["data"] = data;
            item["udp"] = udp;
            lock (this.outQueueLocker)
            {
                this.outThreadQueue.Enqueue(item);
                this.outHasQueuedItems = true;
            }
        }

        private void InThread()
        {
            while (this.running)
            {
                Sleep(5);
                if (this.inHasQueuedItems)
                {
                    lock (this.inQueueLocker)
                    {
                        while (this.inThreadQueue.Count > 0)
                        {
                            Hashtable item = this.inThreadQueue.Dequeue();
                            this.ProcessItem(item);
                        }
                        this.inHasQueuedItems = false;
                    }
                }
            }
        }

        private void OutThread()
        {
            while (this.running)
            {
                Sleep(5);
                if (this.outHasQueuedItems)
                {
                    lock (this.outQueueLocker)
                    {
                        while (this.outThreadQueue.Count > 0)
                        {
                            Hashtable item = this.outThreadQueue.Dequeue();
                            this.ProcessOutItem(item);
                        }
                        this.outHasQueuedItems = false;
                    }
                }
            }
        }

        private void ProcessItem(Hashtable item)
        {
            object obj2 = item["callback"];
            OnDataDelegate delegate2 = obj2 as OnDataDelegate;
            if (delegate2 != null)
            {
                byte[] msg = (byte[]) item["data"];
                delegate2(msg);
            }
            else
            {
                ParameterizedThreadStart start = obj2 as ParameterizedThreadStart;
                if (start != null)
                {
                    start(item);
                }
            }
        }

        private void ProcessOutItem(Hashtable item)
        {
            object obj2 = item["callback"];
            WriteBinaryDataDelegate delegate2 = obj2 as WriteBinaryDataDelegate;
            if (delegate2 != null)
            {
                ByteArray binData = item["data"] as ByteArray;
                PacketHeader header = item["header"] as PacketHeader;
                bool udp = (bool) item["udp"];
                delegate2(header, binData, udp);
            }
        }

        private static void Sleep(int ms)
        {
            Thread.Sleep(ms);
        }

        public void Start()
        {
            if (!this.running)
            {
                this.running = true;
                if (this.inThread == null)
                {
                    this.inThread = new Thread(new ThreadStart(this.InThread));
                    this.inThread.IsBackground = true;
                    this.inThread.Start();
                }
                if (this.outThread == null)
                {
                    this.outThread = new Thread(new ThreadStart(this.OutThread));
                    this.outThread.IsBackground = true;
                    this.outThread.Start();
                }
            }
        }

        public void Stop()
        {
            new Thread(new ThreadStart(this.StopThread)).Start();
        }

        private void StopThread()
        {
            this.running = false;
            if (this.inThread != null)
            {
                this.inThread.Join();
            }
            if (this.outThread != null)
            {
                this.outThread.Join();
            }
            this.inThread = null;
            this.outThread = null;
        }
    }
}

