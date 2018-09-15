namespace Sfs2X.Util
{
    using Sfs2X;
    using Sfs2X.Core;
    using System;
    using System.Collections;
    using System.IO;

    public class ConfigLoader : IDispatchable
    {
        private EventDispatcher dispatcher;
        private XMLNode rootNode;
        private SmartFox smartFox;
        private XMLParser xmlParser;

        public ConfigLoader(SmartFox smartFox)
        {
            this.smartFox = smartFox;
            this.dispatcher = new EventDispatcher(this);
        }

        public void AddEventListener(string eventType, EventListenerDelegate listener)
        {
            this.dispatcher.AddEventListener(eventType, listener);
        }

        private string GetNodeText(XMLNode rootNode, string nodeName)
        {
            if (rootNode[nodeName] == null)
            {
                return null;
            }
            return ((rootNode[nodeName] as XMLNodeList)[0] as XMLNode)["_text"].ToString();
        }

        public void LoadConfig(string filePath)
        {
            try
            {
                string content = "";
                content = File.OpenText(filePath).ReadToEnd();
                this.xmlParser = new XMLParser();
                this.rootNode = this.xmlParser.Parse(content);
            }
            catch (Exception exception)
            {
                Console.WriteLine("Error loading config file: " + exception.Message);
                this.OnConfigLoadFailure("Error loading config file: " + exception.Message);
                return;
            }
            this.TryParse();
        }

        private void OnConfigLoadFailure(string msg)
        {
            Hashtable data = new Hashtable();
            data["message"] = msg;
            SFSEvent evt = new SFSEvent(SFSEvent.CONFIG_LOAD_FAILURE, data);
            this.dispatcher.DispatchEvent(evt);
        }

        private void TryParse()
        {
            ConfigData data = new ConfigData();
            try
            {
                XMLNodeList list = this.rootNode["SmartFoxConfig"] as XMLNodeList;
                XMLNode rootNode = list[0] as XMLNode;
                if (this.GetNodeText(rootNode, "ip") == null)
                {
                    this.smartFox.Log.Error(new string[] { "Required config node missing: ip" });
                }
                if (this.GetNodeText(rootNode, "port") == null)
                {
                    this.smartFox.Log.Error(new string[] { "Required config node missing: port" });
                }
                if (this.GetNodeText(rootNode, "udpIp") == null)
                {
                    this.smartFox.Log.Error(new string[] { "Required config node missing: udpIp" });
                }
                if (this.GetNodeText(rootNode, "udpPort") == null)
                {
                    this.smartFox.Log.Error(new string[] { "Required config node missing: udpPort" });
                }
                if (this.GetNodeText(rootNode, "zone") == null)
                {
                    this.smartFox.Log.Error(new string[] { "Required config node missing: zone" });
                }
                data.Host = this.GetNodeText(rootNode, "ip");
                data.Port = Convert.ToInt32(this.GetNodeText(rootNode, "port"));
                data.UdpHost = this.GetNodeText(rootNode, "udpIp");
                data.UdpPort = Convert.ToInt32(this.GetNodeText(rootNode, "udpPort"));
                data.Zone = this.GetNodeText(rootNode, "zone");
                if (this.GetNodeText(rootNode, "debug") != null)
                {
                    data.Debug = this.GetNodeText(rootNode, "debug").ToLower() == "true";
                }
                if (this.GetNodeText(rootNode, "useBlueBox") != null)
                {
                    data.UseBlueBox = this.GetNodeText(rootNode, "useBlueBox").ToLower() == "true";
                }
                if ((this.GetNodeText(rootNode, "httpPort") != null) && (this.GetNodeText(rootNode, "httpPort") != ""))
                {
                    data.HttpPort = Convert.ToInt32(this.GetNodeText(rootNode, "httpPort"));
                }
                if ((this.GetNodeText(rootNode, "blueBoxPollingRate") != null) && (this.GetNodeText(rootNode, "blueBoxPollingRate") != ""))
                {
                    data.BlueBoxPollingRate = Convert.ToInt32(this.GetNodeText(rootNode, "blueBoxPollingRate"));
                }
            }
            catch (Exception exception)
            {
                this.OnConfigLoadFailure("Error parsing config file: " + exception.Message + " " + exception.StackTrace);
                return;
            }
            Hashtable hashtable = new Hashtable();
            hashtable["cfg"] = data;
            SFSEvent evt = new SFSEvent(SFSEvent.CONFIG_LOAD_SUCCESS, hashtable);
            this.dispatcher.DispatchEvent(evt);
        }

        public EventDispatcher Dispatcher
        {
            get
            {
                return this.dispatcher;
            }
        }
    }
}

