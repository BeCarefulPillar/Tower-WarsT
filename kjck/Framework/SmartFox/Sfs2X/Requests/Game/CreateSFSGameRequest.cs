namespace Sfs2X.Requests.Game
{
    using Sfs2X;
    using Sfs2X.Entities;
    using Sfs2X.Exceptions;
    using Sfs2X.Requests;
    using System;
    using System.Collections.Generic;

    public class CreateSFSGameRequest : BaseRequest
    {
        private CreateRoomRequest createRoomRequest;
        public static readonly string KEY_INVITATION_EXPIRY = "gie";
        public static readonly string KEY_INVITATION_PARAMS = "ip";
        public static readonly string KEY_INVITED_PLAYERS = "ginp";
        public static readonly string KEY_IS_PUBLIC = "gip";
        public static readonly string KEY_LEAVE_ROOM = "glr";
        public static readonly string KEY_MIN_PLAYERS = "gmp";
        public static readonly string KEY_NOTIFY_GAME_STARTED = "gns";
        public static readonly string KEY_PLAYER_MATCH_EXP = "gpme";
        public static readonly string KEY_SEARCHABLE_ROOMS = "gsr";
        public static readonly string KEY_SPECTATOR_MATCH_EXP = "gsme";
        private SFSGameSettings settings;

        public CreateSFSGameRequest(SFSGameSettings settings) : base(RequestType.CreateSFSGame)
        {
            this.settings = settings;
            this.createRoomRequest = new CreateRoomRequest(settings, false, null);
        }

        public override void Execute(SmartFox sfs)
        {
            this.createRoomRequest.Execute(sfs);
            base.sfso = this.createRoomRequest.Message.Content;
            base.sfso.PutBool(KEY_IS_PUBLIC, this.settings.IsPublic);
            base.sfso.PutShort(KEY_MIN_PLAYERS, (short) this.settings.MinPlayersToStartGame);
            base.sfso.PutShort(KEY_INVITATION_EXPIRY, (short) this.settings.InvitationExpiryTime);
            base.sfso.PutBool(KEY_LEAVE_ROOM, this.settings.LeaveLastJoinedRoom);
            base.sfso.PutBool(KEY_NOTIFY_GAME_STARTED, this.settings.NotifyGameStarted);
            if (this.settings.PlayerMatchExpression != null)
            {
                base.sfso.PutSFSArray(KEY_PLAYER_MATCH_EXP, this.settings.PlayerMatchExpression.ToSFSArray());
            }
            if (this.settings.SpectatorMatchExpression != null)
            {
                base.sfso.PutSFSArray(KEY_SPECTATOR_MATCH_EXP, this.settings.SpectatorMatchExpression.ToSFSArray());
            }
            if (this.settings.InvitedPlayers != null)
            {
                List<int> list = new List<int>();
                foreach (object obj2 in this.settings.InvitedPlayers)
                {
                    if (obj2 is User)
                    {
                        list.Add((obj2 as User).Id);
                    }
                    else if (obj2 is Buddy)
                    {
                        list.Add((obj2 as Buddy).Id);
                    }
                }
                base.sfso.PutIntArray(KEY_INVITED_PLAYERS, list.ToArray());
            }
            if (this.settings.SearchableRooms != null)
            {
                base.sfso.PutUtfStringArray(KEY_SEARCHABLE_ROOMS, this.settings.SearchableRooms.ToArray());
            }
            if (this.settings.InvitationParams != null)
            {
                base.sfso.PutSFSObject(KEY_INVITATION_PARAMS, this.settings.InvitationParams);
            }
        }

        public override void Validate(SmartFox sfs)
        {
            List<string> errors = new List<string>();
            try
            {
                this.createRoomRequest.Validate(sfs);
            }
            catch (SFSValidationError error)
            {
                errors = error.Errors;
            }
            if (this.settings.MinPlayersToStartGame > this.settings.MaxUsers)
            {
                errors.Add("minPlayersToStartGame cannot be greater than maxUsers");
            }
            if ((this.settings.InvitationExpiryTime < InviteUsersRequest.MIN_EXPIRY_TIME) || (this.settings.InvitationExpiryTime > InviteUsersRequest.MAX_EXPIRY_TIME))
            {
                errors.Add(string.Concat(new object[] { "Expiry time value is out of range (", InviteUsersRequest.MIN_EXPIRY_TIME, "-", InviteUsersRequest.MAX_EXPIRY_TIME, ")" }));
            }
            if ((this.settings.InvitedPlayers != null) && (this.settings.InvitedPlayers.Count > InviteUsersRequest.MAX_INVITATIONS_FROM_CLIENT_SIDE))
            {
                errors.Add("Cannot invite more than " + InviteUsersRequest.MAX_INVITATIONS_FROM_CLIENT_SIDE + " players from client side");
            }
            if (errors.Count > 0)
            {
                throw new SFSValidationError("CreateSFSGame request error", errors);
            }
        }
    }
}

