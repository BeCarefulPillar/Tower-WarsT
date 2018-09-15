namespace Sfs2X.Requests
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Variables;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests.MMO;
    using System;
    using System.Collections.Generic;

    public class CreateRoomRequest : BaseRequest
    {
        private bool autoJoin;
        public static readonly string KEY_AUTOJOIN = "aj";
        public static readonly string KEY_EVENTS = "ev";
        public static readonly string KEY_EXTCLASS = "xc";
        public static readonly string KEY_EXTID = "xn";
        public static readonly string KEY_EXTPROP = "xp";
        public static readonly string KEY_GROUP_ID = "g";
        public static readonly string KEY_ISGAME = "ig";
        public static readonly string KEY_MAXSPECTATORS = "ms";
        public static readonly string KEY_MAXUSERS = "mu";
        public static readonly string KEY_MAXVARS = "mv";
        public static readonly string KEY_MMO_DEFAULT_AOI = "maoi";
        public static readonly string KEY_MMO_MAP_HIGH_LIMIT = "mlhm";
        public static readonly string KEY_MMO_MAP_LOW_LIMIT = "mllm";
        public static readonly string KEY_MMO_PROXIMITY_UPDATE_MILLIS = "mpum";
        public static readonly string KEY_MMO_SEND_ENTRY_POINT = "msep";
        public static readonly string KEY_MMO_USER_MAX_LIMBO_SECONDS = "muls";
        public static readonly string KEY_NAME = "n";
        public static readonly string KEY_PASSWORD = "p";
        public static readonly string KEY_PERMISSIONS = "pm";
        public static readonly string KEY_ROOM = "r";
        public static readonly string KEY_ROOM_TO_LEAVE = "rl";
        public static readonly string KEY_ROOMVARS = "rv";
        private Room roomToLeave;
        private RoomSettings settings;

        public CreateRoomRequest(RoomSettings settings) : base(RequestType.CreateRoom)
        {
            this.Init(settings, false, null);
        }

        public CreateRoomRequest(RoomSettings settings, bool autoJoin) : base(RequestType.CreateRoom)
        {
            this.Init(settings, autoJoin, null);
        }

        public CreateRoomRequest(RoomSettings settings, bool autoJoin, Room roomToLeave) : base(RequestType.CreateRoom)
        {
            this.Init(settings, autoJoin, roomToLeave);
        }

        public override void Execute(SmartFox sfs)
        {
            base.sfso.PutUtfString(KEY_NAME, this.settings.Name);
            base.sfso.PutUtfString(KEY_GROUP_ID, this.settings.GroupId);
            base.sfso.PutUtfString(KEY_PASSWORD, this.settings.Password);
            base.sfso.PutBool(KEY_ISGAME, this.settings.IsGame);
            base.sfso.PutShort(KEY_MAXUSERS, this.settings.MaxUsers);
            base.sfso.PutShort(KEY_MAXSPECTATORS, this.settings.MaxSpectators);
            base.sfso.PutShort(KEY_MAXVARS, this.settings.MaxVariables);
            if ((this.settings.Variables != null) && (this.settings.Variables.Count > 0))
            {
                ISFSArray val = SFSArray.NewInstance();
                foreach (object obj2 in this.settings.Variables)
                {
                    if (obj2 is RoomVariable)
                    {
                        val.AddSFSArray((obj2 as RoomVariable).ToSFSArray());
                    }
                }
                base.sfso.PutSFSArray(KEY_ROOMVARS, val);
            }
            if (this.settings.Permissions != null)
            {
                base.sfso.PutBoolArray(KEY_PERMISSIONS, new List<bool> { this.settings.Permissions.AllowNameChange, this.settings.Permissions.AllowPasswordStateChange, this.settings.Permissions.AllowPublicMessages, this.settings.Permissions.AllowResizing }.ToArray());
            }
            if (this.settings.Events != null)
            {
                base.sfso.PutBoolArray(KEY_EVENTS, new List<bool> { this.settings.Events.AllowUserEnter, this.settings.Events.AllowUserExit, this.settings.Events.AllowUserCountChange, this.settings.Events.AllowUserVariablesUpdate }.ToArray());
            }
            if (this.settings.Extension != null)
            {
                base.sfso.PutUtfString(KEY_EXTID, this.settings.Extension.Id);
                base.sfso.PutUtfString(KEY_EXTCLASS, this.settings.Extension.ClassName);
                if ((this.settings.Extension.PropertiesFile != null) && (this.settings.Extension.PropertiesFile.Length > 0))
                {
                    base.sfso.PutUtfString(KEY_EXTPROP, this.settings.Extension.PropertiesFile);
                }
            }
            if (this.settings is MMORoomSettings)
            {
                MMORoomSettings settings = this.settings as MMORoomSettings;
                if (settings.DefaultAOI.IsFloat())
                {
                    base.sfso.PutFloatArray(KEY_MMO_DEFAULT_AOI, settings.DefaultAOI.ToFloatArray());
                    if (settings.MapLimits != null)
                    {
                        base.sfso.PutFloatArray(KEY_MMO_MAP_LOW_LIMIT, settings.MapLimits.LowerLimit.ToFloatArray());
                        base.sfso.PutFloatArray(KEY_MMO_MAP_HIGH_LIMIT, settings.MapLimits.HigherLimit.ToFloatArray());
                    }
                }
                else
                {
                    base.sfso.PutIntArray(KEY_MMO_DEFAULT_AOI, settings.DefaultAOI.ToIntArray());
                    if (settings.MapLimits != null)
                    {
                        base.sfso.PutIntArray(KEY_MMO_MAP_LOW_LIMIT, settings.MapLimits.LowerLimit.ToIntArray());
                        base.sfso.PutIntArray(KEY_MMO_MAP_HIGH_LIMIT, settings.MapLimits.HigherLimit.ToIntArray());
                    }
                }
                base.sfso.PutShort(KEY_MMO_USER_MAX_LIMBO_SECONDS, (short) settings.UserMaxLimboSeconds);
                base.sfso.PutShort(KEY_MMO_PROXIMITY_UPDATE_MILLIS, (short) settings.ProximityListUpdateMillis);
                base.sfso.PutBool(KEY_MMO_SEND_ENTRY_POINT, settings.SendAOIEntryPoint);
            }
            base.sfso.PutBool(KEY_AUTOJOIN, this.autoJoin);
            if (this.roomToLeave != null)
            {
                base.sfso.PutInt(KEY_ROOM_TO_LEAVE, this.roomToLeave.Id);
            }
        }

        private void Init(RoomSettings settings, bool autoJoin, Room roomToLeave)
        {
            this.settings = settings;
            this.autoJoin = autoJoin;
            this.roomToLeave = roomToLeave;
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if ((this.settings.Name == null) || (this.settings.Name.Length == 0))
            {
                errors.Add("Missing room name");
            }
            if (this.settings.MaxUsers <= 0)
            {
                errors.Add("maxUsers must be > 0");
            }
            if (this.settings.Extension != null)
            {
                if ((this.settings.Extension.ClassName == null) || (this.settings.Extension.ClassName.Length == 0))
                {
                    errors.Add("Missing Extension class name");
                }
                if ((this.settings.Extension.Id == null) || (this.settings.Extension.Id.Length == 0))
                {
                    errors.Add("Missing Extension id");
                }
            }
            if (this.settings is MMORoomSettings)
            {
                MMORoomSettings settings = this.settings as MMORoomSettings;
                if (settings.DefaultAOI == null)
                {
                    errors.Add("Missing default AOI (area of interest)");
                }
                if ((settings.MapLimits != null) && ((settings.MapLimits.LowerLimit == null) || (settings.MapLimits.HigherLimit == null)))
                {
                    errors.Add("Map limits must be both defined");
                }
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("CreateRoom request error", errors);
            }
        }
    }
}

