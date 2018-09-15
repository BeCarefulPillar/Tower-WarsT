namespace Sfs2X.Util
{
    using System;

    public class ConfigData
    {
        private int blueBoxPollingRate = 750;
        private bool debug = false;
        private string host = "127.0.0.1";
        private int httpPort = 0x1f90;
        private int port = 0x26cd;
        private string udpHost = "127.0.0.1";
        private int udpPort = 0x26cd;
        private bool useBlueBox = true;
        private string zone;

        public int BlueBoxPollingRate
        {
            get
            {
                return this.blueBoxPollingRate;
            }
            set
            {
                this.blueBoxPollingRate = value;
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

        public string Host
        {
            get
            {
                return this.host;
            }
            set
            {
                this.host = value;
            }
        }

        public int HttpPort
        {
            get
            {
                return this.httpPort;
            }
            set
            {
                this.httpPort = value;
            }
        }

        public int Port
        {
            get
            {
                return this.port;
            }
            set
            {
                this.port = value;
            }
        }

        public string UdpHost
        {
            get
            {
                return this.udpHost;
            }
            set
            {
                this.udpHost = value;
            }
        }

        public int UdpPort
        {
            get
            {
                return this.udpPort;
            }
            set
            {
                this.udpPort = value;
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

        public string Zone
        {
            get
            {
                return this.zone;
            }
            set
            {
                this.zone = value;
            }
        }
    }
}

