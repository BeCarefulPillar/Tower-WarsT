namespace Sfs2X.Requests
{
    using System;

    public class RoomExtension
    {
        private string className;
        private string id;
        private string propertiesFile;

        public RoomExtension(string id, string className)
        {
            this.id = id;
            this.className = className;
            this.propertiesFile = "";
        }

        public string ClassName
        {
            get
            {
                return this.className;
            }
        }

        public string Id
        {
            get
            {
                return this.id;
            }
        }

        public string PropertiesFile
        {
            get
            {
                return this.propertiesFile;
            }
            set
            {
                this.propertiesFile = value;
            }
        }
    }
}

