namespace Sfs2X.Requests.MMO
{
    using Sfs2X.Entities.Data;
    using Sfs2X.Requests;
    using System;

    public class MMORoomSettings : RoomSettings
    {
        private Vec3D defaultAOI;
        private Sfs2X.Requests.MMO.MapLimits mapLimits;
        private int proximityListUpdateMillis;
        private bool sendAOIEntryPoint;
        private int userMaxLimboSeconds;

        public MMORoomSettings(string name) : base(name)
        {
            this.userMaxLimboSeconds = 50;
            this.proximityListUpdateMillis = 250;
            this.sendAOIEntryPoint = true;
        }

        public Vec3D DefaultAOI
        {
            get
            {
                return this.defaultAOI;
            }
            set
            {
                this.defaultAOI = value;
            }
        }

        public Sfs2X.Requests.MMO.MapLimits MapLimits
        {
            get
            {
                return this.mapLimits;
            }
            set
            {
                this.mapLimits = value;
            }
        }

        public int ProximityListUpdateMillis
        {
            get
            {
                return this.proximityListUpdateMillis;
            }
            set
            {
                this.proximityListUpdateMillis = value;
            }
        }

        public bool SendAOIEntryPoint
        {
            get
            {
                return this.sendAOIEntryPoint;
            }
            set
            {
                this.sendAOIEntryPoint = value;
            }
        }

        public int UserMaxLimboSeconds
        {
            get
            {
                return this.userMaxLimboSeconds;
            }
            set
            {
                this.userMaxLimboSeconds = value;
            }
        }
    }
}

