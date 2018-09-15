namespace Sfs2X.Requests.Game
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Entities.Match;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class QuickJoinGameRequest : BaseRequest
    {
        private bool isSearchListRoom;
        private bool isSearchListString;
        public static readonly string KEY_GROUP_LIST = "gl";
        public static readonly string KEY_MATCH_EXPRESSION = "me";
        public static readonly string KEY_ROOM_LIST = "rl";
        public static readonly string KEY_ROOM_TO_LEAVE = "tl";
        private MatchExpression matchExpression;
        private static readonly int MAX_ROOMS = 0x20;
        private Room roomToLeave;
        private List<Room> whereToSearchRoom;
        private List<string> whereToSearchString;

        public QuickJoinGameRequest(MatchExpression matchExpression, List<Room> whereToSearch) : base(RequestType.QuickJoinGame)
        {
            this.isSearchListString = false;
            this.isSearchListRoom = false;
            this.Init(matchExpression, whereToSearch, null);
        }

        public QuickJoinGameRequest(MatchExpression matchExpression, List<string> whereToSearch) : base(RequestType.QuickJoinGame)
        {
            this.isSearchListString = false;
            this.isSearchListRoom = false;
            this.Init(matchExpression, whereToSearch, null);
        }

        public QuickJoinGameRequest(MatchExpression matchExpression, List<Room> whereToSearch, Room roomToLeave) : base(RequestType.QuickJoinGame)
        {
            this.isSearchListString = false;
            this.isSearchListRoom = false;
            this.Init(matchExpression, whereToSearch, roomToLeave);
        }

        public QuickJoinGameRequest(MatchExpression matchExpression, List<string> whereToSearch, Room roomToLeave) : base(RequestType.QuickJoinGame)
        {
            this.isSearchListString = false;
            this.isSearchListRoom = false;
            this.Init(matchExpression, whereToSearch, roomToLeave);
        }

        public override void Execute(SmartFox sfs)
        {
            if (this.isSearchListString)
            {
                base.sfso.PutUtfStringArray(KEY_GROUP_LIST, this.whereToSearchString.ToArray());
            }
            else if (this.isSearchListRoom)
            {
                List<int> list = new List<int>();
                foreach (Room room in this.whereToSearchRoom)
                {
                    list.Add(room.Id);
                }
                base.sfso.PutIntArray(KEY_ROOM_LIST, list.ToArray());
            }
            if (this.roomToLeave != null)
            {
                base.sfso.PutInt(KEY_ROOM_TO_LEAVE, this.roomToLeave.Id);
            }
            if (this.matchExpression != null)
            {
                base.sfso.PutSFSArray(KEY_MATCH_EXPRESSION, this.matchExpression.ToSFSArray());
            }
        }

        private void Init(MatchExpression matchExpression, List<Room> whereToSearch, Room roomToLeave)
        {
            this.matchExpression = matchExpression;
            this.whereToSearchRoom = whereToSearch;
            this.roomToLeave = roomToLeave;
            this.isSearchListRoom = true;
        }

        private void Init(MatchExpression matchExpression, List<string> whereToSearch, Room roomToLeave)
        {
            this.matchExpression = matchExpression;
            this.whereToSearchString = whereToSearch;
            this.roomToLeave = roomToLeave;
            this.isSearchListString = true;
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            if (this.isSearchListRoom)
            {
                if ((this.whereToSearchRoom == null) || (this.whereToSearchRoom.Count < 1))
                {
                    errors.Add("Missing whereToSearch parameter");
                }
                else if (this.whereToSearchRoom.Count > MAX_ROOMS)
                {
                    errors.Add("Too many Rooms specified in the whereToSearch parameter. Client limit is: " + MAX_ROOMS);
                }
            }
            if (this.isSearchListString)
            {
                if ((this.whereToSearchString == null) || (this.whereToSearchString.Count < 1))
                {
                    errors.Add("Missing whereToSearch parameter");
                }
                else if (this.whereToSearchString.Count > MAX_ROOMS)
                {
                    errors.Add("Too many Rooms specified in the whereToSearch parameter. Client limit is: " + MAX_ROOMS);
                }
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("QuickJoinGame request error", errors);
            }
        }
    }
}

