namespace Sfs2X.Requests.Game
{
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Match;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class SFSGameSettings : RoomSettings
    {
        private int invitationExpiryTime;
        private ISFSObject invitationParams;
        private List<object> invitedPlayers;
        private bool isPublic;
        private bool leaveJoinedLastRoom;
        private int minPlayersToStartGame;
        private bool notifyGameStarted;
        private MatchExpression playerMatchExpression;
        private List<string> searchableRooms;
        private MatchExpression spectatorMatchExpression;

        public SFSGameSettings(string name) : base(name)
        {
            this.isPublic = true;
            this.minPlayersToStartGame = 2;
            this.invitationExpiryTime = 15;
            this.leaveJoinedLastRoom = true;
            this.invitedPlayers = new List<object>();
            this.searchableRooms = new List<string>();
        }

        public int InvitationExpiryTime
        {
            get
            {
                return this.invitationExpiryTime;
            }
            set
            {
                this.invitationExpiryTime = value;
            }
        }

        public ISFSObject InvitationParams
        {
            get
            {
                return this.invitationParams;
            }
            set
            {
                this.invitationParams = value;
            }
        }

        public List<object> InvitedPlayers
        {
            get
            {
                return this.invitedPlayers;
            }
            set
            {
                this.invitedPlayers = value;
            }
        }

        public bool IsPublic
        {
            get
            {
                return this.isPublic;
            }
            set
            {
                this.isPublic = value;
            }
        }

        public bool LeaveLastJoinedRoom
        {
            get
            {
                return this.leaveJoinedLastRoom;
            }
            set
            {
                this.leaveJoinedLastRoom = value;
            }
        }

        public int MinPlayersToStartGame
        {
            get
            {
                return this.minPlayersToStartGame;
            }
            set
            {
                this.minPlayersToStartGame = value;
            }
        }

        public bool NotifyGameStarted
        {
            get
            {
                return this.notifyGameStarted;
            }
            set
            {
                this.notifyGameStarted = value;
            }
        }

        public MatchExpression PlayerMatchExpression
        {
            get
            {
                return this.playerMatchExpression;
            }
            set
            {
                this.playerMatchExpression = value;
            }
        }

        public List<string> SearchableRooms
        {
            get
            {
                return this.searchableRooms;
            }
            set
            {
                this.searchableRooms = value;
            }
        }

        public MatchExpression SpectatorMatchExpression
        {
            get
            {
                return this.spectatorMatchExpression;
            }
            set
            {
                this.spectatorMatchExpression = value;
            }
        }
    }
}

