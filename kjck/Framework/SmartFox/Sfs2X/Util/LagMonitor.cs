namespace Sfs2X.Util
{
    using Sfs2X;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;
    using System.Timers;

    public class LagMonitor
    {
        //private int interval;
        private int lastReqTime;
        private Timer pollTimer;
        private int queueSize;
        private SmartFox sfs;
        private List<int> valueQueue;

        public LagMonitor(SmartFox sfs) : this(sfs, 4, 10)
        {
        }

        public LagMonitor(SmartFox sfs, int interval) : this(sfs, interval, 10)
        {
        }

        public LagMonitor(SmartFox sfs, int interval, int queueSize)
        {
            if (interval < 1)
            {
                interval = 1;
            }
            this.sfs = sfs;
            this.valueQueue = new List<int>();
            //this.interval = interval;
            this.queueSize = queueSize;
            this.pollTimer = new Timer();
            this.pollTimer.Enabled = false;
            this.pollTimer.AutoReset = true;
            this.pollTimer.Elapsed += new ElapsedEventHandler(this.OnPollEvent);
            this.pollTimer.Interval = interval * 0x3e8;
        }

        public void Destroy()
        {
            this.Stop();
            this.pollTimer.Dispose();
            this.sfs = null;
        }

        public int OnPingPong()
        {
            int item = DateTime.Now.Millisecond - this.lastReqTime;
            if (this.valueQueue.Count >= this.queueSize)
            {
                this.valueQueue.RemoveAt(0);
            }
            this.valueQueue.Add(item);
            return this.AveragePingTime;
        }

        private void OnPollEvent(object source, ElapsedEventArgs e)
        {
            this.lastReqTime = DateTime.Now.Millisecond;
            this.sfs.Send(new PingPongRequest());
        }

        public void Start()
        {
            if (!this.IsRunning)
            {
                this.pollTimer.Start();
            }
        }

        public void Stop()
        {
            if (this.IsRunning)
            {
                this.pollTimer.Stop();
            }
        }

        public int AveragePingTime
        {
            get
            {
                if (this.valueQueue.Count == 0)
                {
                    return 0;
                }
                int num = 0;
                foreach (int num2 in this.valueQueue)
                {
                    num += num2;
                }
                return (num / this.valueQueue.Count);
            }
        }

        public bool IsRunning
        {
            get
            {
                return this.pollTimer.Enabled;
            }
        }

        public int LastPingTime
        {
            get
            {
                if (this.valueQueue.Count > 0)
                {
                    return this.valueQueue[this.valueQueue.Count - 1];
                }
                return 0;
            }
        }
    }
}

