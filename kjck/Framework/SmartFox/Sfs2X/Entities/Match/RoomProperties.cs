﻿namespace Sfs2X.Entities.Match
{
    using System;

    public class RoomProperties
    {
        public static readonly string GROUP_ID = "${G}";
        public static readonly string HAS_FREE_PLAYER_SLOTS = "${HFP}";
        public static readonly string IS_GAME = "${ISG}";
        public static readonly string IS_PRIVATE = "${ISP}";
        public static readonly string IS_TYPE_SFSGAME = "${IST}";
        public static readonly string MAX_SPECTATORS = "${MXS}";
        public static readonly string MAX_USERS = "${MXU}";
        public static readonly string NAME = "${N}";
        public static readonly string SPECTATOR_COUNT = "${SC}";
        public static readonly string USER_COUNT = "${UC}";

        public RoomProperties()
        {
            throw new ArgumentException("This class cannot be instantiated");
        }
    }
}

