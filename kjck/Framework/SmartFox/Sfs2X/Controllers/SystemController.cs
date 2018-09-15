namespace Sfs2X.Controllers
{
    using Sfs2X.Bitswarm;
    using Sfs2X.Core;
    using Sfs2X.Entities;
    using Sfs2X.Entities.Data;
    using Sfs2X.Entities.Invitation;
    using Sfs2X.Entities.Managers;
    using Sfs2X.Entities.Variables;
    using Sfs2X.Requests;
    using Sfs2X.Requests.Buddylist;
    using Sfs2X.Requests.Game;
    using Sfs2X.Requests.MMO;
    using Sfs2X.Util;
    using System;
    using System.Collections;
    using System.Collections.Generic;

    public class SystemController : BaseController
    {
        private Dictionary<int, RequestDelegate> requestHandlers;

        public SystemController(BitSwarmClient bitSwarm) : base(bitSwarm)
        {
            this.requestHandlers = new Dictionary<int, RequestDelegate>();
            this.InitRequestHandlers();
        }

        private void FnAddBuddy(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable args = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                Buddy buddy = SFSBuddy.FromSFSArray(content.GetSFSArray(AddBuddyRequest.KEY_BUDDY_NAME));
                base.sfs.BuddyManager.AddBuddy(buddy);
                args["buddy"] = buddy;
                base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_ADD, args));
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                args["errorMessage"] = str;
                args["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_ERROR, args));
            }
        }

        private void FnBlockBuddy(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable args = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                string utfString = content.GetUtfString(BlockBuddyRequest.KEY_BUDDY_NAME);
                Buddy buddyByName = base.sfs.BuddyManager.GetBuddyByName(utfString);
                if (buddyByName != null)
                {
                    buddyByName.IsBlocked = content.GetBool(BlockBuddyRequest.KEY_BUDDY_BLOCK_STATE);
                    args["buddy"] = buddyByName;
                    base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_BLOCK, args));
                }
                else
                {
                    base.log.Warn(new string[] { "BlockBuddy failed, buddy not found: " + utfString + ", in local BuddyList" });
                }
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str2 = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                args["errorMessage"] = str2;
                args["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_ERROR, args));
            }
        }

        private void FnChangeRoomCapacity(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                int @int = content.GetInt(ChangeRoomCapacityRequest.KEY_ROOM);
                Room roomById = base.sfs.RoomManager.GetRoomById(@int);
                if (roomById != null)
                {
                    base.sfs.RoomManager.ChangeRoomCapacity(roomById, content.GetInt(ChangeRoomCapacityRequest.KEY_USER_SIZE), content.GetInt(ChangeRoomCapacityRequest.KEY_SPEC_SIZE));
                    data["room"] = roomById;
                    base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_CAPACITY_CHANGE, data));
                }
                else
                {
                    base.log.Warn(new string[] { "Room not found, ID:" + @int + ", Room capacity change failed." });
                }
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str;
                data["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_CAPACITY_CHANGE_ERROR, data));
            }
        }

        private void FnChangeRoomName(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                int @int = content.GetInt(ChangeRoomNameRequest.KEY_ROOM);
                Room roomById = base.sfs.RoomManager.GetRoomById(@int);
                if (roomById != null)
                {
                    data["oldName"] = roomById.Name;
                    base.sfs.RoomManager.ChangeRoomName(roomById, content.GetUtfString(ChangeRoomNameRequest.KEY_NAME));
                    data["room"] = roomById;
                    base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_NAME_CHANGE, data));
                }
                else
                {
                    base.log.Warn(new string[] { "Room not found, ID:" + @int + ", Room name change failed." });
                }
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str;
                data["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_NAME_CHANGE_ERROR, data));
            }
        }

        private void FnChangeRoomPassword(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                int @int = content.GetInt(ChangeRoomPasswordStateRequest.KEY_ROOM);
                Room roomById = base.sfs.RoomManager.GetRoomById(@int);
                if (roomById != null)
                {
                    base.sfs.RoomManager.ChangeRoomPasswordState(roomById, content.GetBool(ChangeRoomPasswordStateRequest.KEY_PASS));
                    data["room"] = roomById;
                    base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_PASSWORD_STATE_CHANGE, data));
                }
                else
                {
                    base.log.Warn(new string[] { "Room not found, ID:" + @int + ", Room password change failed." });
                }
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str;
                data["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_PASSWORD_STATE_CHANGE_ERROR, data));
            }
        }

        private void FnClientDisconnection(IMessage msg)
        {
            int @byte = msg.Content.GetByte("dr");
            base.sfs.HandleClientDisconnection(ClientDisconnectionReason.GetReason(@byte));
        }

        private void FnCreateRoom(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                IRoomManager roomManager = base.sfs.RoomManager;
                Room room = SFSRoom.FromSFSArray(content.GetSFSArray(CreateRoomRequest.KEY_ROOM));
                room.RoomManager = base.sfs.RoomManager;
                roomManager.AddRoom(room);
                data["room"] = room;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_ADD, data));
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str;
                data["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_CREATION_ERROR, data));
            }
        }

        private void FnFindRooms(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            ISFSArray sFSArray = content.GetSFSArray(FindRoomsRequest.KEY_FILTERED_ROOMS);
            List<Room> list = new List<Room>();
            for (int i = 0; i < sFSArray.Size(); i++)
            {
                Room item = SFSRoom.FromSFSArray(sFSArray.GetSFSArray(i));
                Room roomById = base.sfs.RoomManager.GetRoomById(item.Id);
                if (roomById != null)
                {
                    item.IsJoined = roomById.IsJoined;
                }
                list.Add(item);
            }
            data["rooms"] = list;
            base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_FIND_RESULT, data));
        }

        private void FnFindUsers(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            ISFSArray sFSArray = content.GetSFSArray(FindUsersRequest.KEY_FILTERED_USERS);
            List<User> list = new List<User>();
            User mySelf = base.sfs.MySelf;
            for (int i = 0; i < sFSArray.Size(); i++)
            {
                User item = SFSUser.FromSFSArray(sFSArray.GetSFSArray(i));
                if (item.Id == mySelf.Id)
                {
                    item = mySelf;
                }
                list.Add(item);
            }
            data["users"] = list;
            base.sfs.DispatchEvent(new SFSEvent(SFSEvent.USER_FIND_RESULT, data));
        }

        private void FnGenericMessage(IMessage msg)
        {
            ISFSObject content = msg.Content;
            switch (content.GetByte(GenericMessageRequest.KEY_MESSAGE_TYPE))
            {
                case 0:
                    this.HandlePublicMessage(content);
                    break;

                case 1:
                    this.HandlePrivateMessage(content);
                    break;

                case 2:
                    this.HandleModMessage(content);
                    break;

                case 3:
                    this.HandleAdminMessage(content);
                    break;

                case 4:
                    this.HandleObjectMessage(content);
                    break;

                case 5:
                    this.HandleBuddyMessage(content);
                    break;
            }
        }

        private void FnGoOnline(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable args = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                string utfString = content.GetUtfString(GoOnlineRequest.KEY_BUDDY_NAME);
                Buddy buddyByName = base.sfs.BuddyManager.GetBuddyByName(utfString);
                bool flag = utfString == base.sfs.MySelf.Name;
                int @byte = content.GetByte(GoOnlineRequest.KEY_ONLINE);
                bool val = @byte == 0;
                bool myOnlineState = true;
                if (flag)
                {
                    if (base.sfs.BuddyManager.MyOnlineState != val)
                    {
                        base.log.Warn(new string[] { "Unexpected: MyOnlineState is not in synch with the server. Resynching: " + val });
                        base.sfs.BuddyManager.MyOnlineState = val;
                    }
                }
                else if (buddyByName != null)
                {
                    buddyByName.Id = content.GetInt(GoOnlineRequest.KEY_BUDDY_ID);
                    BuddyVariable bVar = new SFSBuddyVariable(ReservedBuddyVariables.BV_ONLINE, val);
                    buddyByName.SetVariable(bVar);
                    if (@byte == 2)
                    {
                        buddyByName.ClearVolatileVariables();
                    }
                    myOnlineState = base.sfs.BuddyManager.MyOnlineState;
                }
                else
                {
                    base.log.Warn(new string[] { "GoOnline error, buddy not found: " + utfString + ", in local BuddyList." });
                    return;
                }
                if (myOnlineState)
                {
                    args["buddy"] = buddyByName;
                    args["isItMe"] = flag;
                    base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_ONLINE_STATE_UPDATE, args));
                }
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str2 = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                args["errorMessage"] = str2;
                args["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_ERROR, args));
            }
        }

        private void FnHandshake(IMessage msg)
        {
            Hashtable data = new Hashtable();
            data["message"] = msg.Content;
            SFSEvent evt = new SFSEvent(SFSEvent.HANDSHAKE, data);
            base.sfs.HandleHandShake(evt);
            base.sfs.DispatchEvent(evt);
        }

        private void FnInitBuddyList(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable args = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                int num;
                ISFSArray sFSArray = content.GetSFSArray(InitBuddyListRequest.KEY_BLIST);
                ISFSArray array2 = content.GetSFSArray(InitBuddyListRequest.KEY_MY_VARS);
                string[] utfStringArray = content.GetUtfStringArray(InitBuddyListRequest.KEY_BUDDY_STATES);
                base.sfs.BuddyManager.ClearAll();
                for (num = 0; num < sFSArray.Size(); num++)
                {
                    Buddy buddy = SFSBuddy.FromSFSArray(sFSArray.GetSFSArray(num));
                    base.sfs.BuddyManager.AddBuddy(buddy);
                }
                if (utfStringArray != null)
                {
                    base.sfs.BuddyManager.BuddyStates = new List<string>(utfStringArray);
                }
                List<BuddyVariable> list = new List<BuddyVariable>();
                for (num = 0; num < array2.Size(); num++)
                {
                    list.Add(SFSBuddyVariable.FromSFSArray(array2.GetSFSArray(num)));
                }
                base.sfs.BuddyManager.MyVariables = list;
                base.sfs.BuddyManager.Inited = true;
                args["buddyList"] = base.sfs.BuddyManager.BuddyList;
                args["myVariables"] = base.sfs.BuddyManager.MyVariables;
                base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_LIST_INIT, args));
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                args["errorMessage"] = str;
                args["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_ERROR, args));
            }
        }

        private void FnInvitationReply(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                User userById = null;
                if (content.ContainsKey(InviteUsersRequest.KEY_USER_ID))
                {
                    userById = base.sfs.UserManager.GetUserById(content.GetInt(InviteUsersRequest.KEY_USER_ID));
                }
                else
                {
                    userById = SFSUser.FromSFSArray(content.GetSFSArray(InviteUsersRequest.KEY_USER));
                }
                int @byte = content.GetByte(InviteUsersRequest.KEY_REPLY_ID);
                ISFSObject sFSObject = content.GetSFSObject(InviteUsersRequest.KEY_PARAMS);
                data["invitee"] = userById;
                data["reply"] = @byte;
                data["data"] = sFSObject;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.INVITATION_REPLY, data));
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str;
                data["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.INVITATION_REPLY_ERROR, data));
            }
        }

        private void FnInviteUsers(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            User inviter = null;
            if (content.ContainsKey(InviteUsersRequest.KEY_USER_ID))
            {
                inviter = base.sfs.UserManager.GetUserById(content.GetInt(InviteUsersRequest.KEY_USER_ID));
            }
            else
            {
                inviter = SFSUser.FromSFSArray(content.GetSFSArray(InviteUsersRequest.KEY_USER));
            }
            int @short = content.GetShort(InviteUsersRequest.KEY_TIME);
            int @int = content.GetInt(InviteUsersRequest.KEY_INVITATION_ID);
            ISFSObject sFSObject = content.GetSFSObject(InviteUsersRequest.KEY_PARAMS);
            Sfs2X.Entities.Invitation.Invitation invitation = new SFSInvitation(inviter, base.sfs.MySelf, @short, sFSObject) {
                Id = @int
            };
            data["invitation"] = invitation;
            base.sfs.DispatchEvent(new SFSEvent(SFSEvent.INVITATION, data));
        }

        private void FnJoinRoom(IMessage msg)
        {
            IRoomManager roomManager = base.sfs.RoomManager;
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            base.sfs.IsJoining = false;
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                ISFSArray sFSArray = content.GetSFSArray(JoinRoomRequest.KEY_ROOM);
                ISFSArray array2 = content.GetSFSArray(JoinRoomRequest.KEY_USER_LIST);
                Room room = SFSRoom.FromSFSArray(sFSArray);
                room.RoomManager = base.sfs.RoomManager;
                room = roomManager.ReplaceRoom(room, roomManager.ContainsGroup(room.GroupId));
                for (int i = 0; i < array2.Size(); i++)
                {
                    ISFSArray userObj = array2.GetSFSArray(i);
                    User user = this.GetOrCreateUser(userObj, true, room);
                    user.SetPlayerId(userObj.GetShort(3), room);
                    room.AddUser(user);
                }
                room.IsJoined = true;
                base.sfs.LastJoinedRoom = room;
                data["room"] = room;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_JOIN, data));
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str;
                data["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_JOIN_ERROR, data));
            }
        }

        private void FnLogin(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                this.PopulateRoomList(content.GetSFSArray(LoginRequest.KEY_ROOMLIST));
                base.sfs.MySelf = new SFSUser(content.GetInt(LoginRequest.KEY_ID), content.GetUtfString(LoginRequest.KEY_USER_NAME), true);
                base.sfs.MySelf.UserManager = base.sfs.UserManager;
                base.sfs.MySelf.PrivilegeId = content.GetShort(LoginRequest.KEY_PRIVILEGE_ID);
                base.sfs.UserManager.AddUser(base.sfs.MySelf);
                base.sfs.SetReconnectionSeconds(content.GetShort(LoginRequest.KEY_RECONNECTION_SECONDS));
                base.sfs.MySelf.PrivilegeId = content.GetShort(LoginRequest.KEY_PRIVILEGE_ID);
                data["zone"] = content.GetUtfString(LoginRequest.KEY_ZONE_NAME);
                data["user"] = base.sfs.MySelf;
                data["data"] = content.GetSFSObject(LoginRequest.KEY_PARAMS);
                SFSEvent evt = new SFSEvent(SFSEvent.LOGIN, data);
                base.sfs.HandleLogin(evt);
                base.sfs.DispatchEvent(evt);
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str;
                data["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.LOGIN_ERROR, data));
            }
        }

        private void FnLogout(IMessage msg)
        {
            base.sfs.HandleLogout();
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            data["zoneName"] = content.GetUtfString(LogoutRequest.KEY_ZONE_NAME);
            base.sfs.DispatchEvent(new SFSEvent(SFSEvent.LOGOUT, data));
        }

        private void FnPingPong(IMessage msg)
        {
            int num = base.sfs.LagMonitor.OnPingPong();
            Hashtable data = new Hashtable();
            data["lagValue"] = num;
            base.sfs.DispatchEvent(new SFSEvent(SFSEvent.PING_PONG, data));
        }

        private void FnPlayerToSpectator(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                int @int = content.GetInt(PlayerToSpectatorRequest.KEY_ROOM_ID);
                int userId = content.GetInt(PlayerToSpectatorRequest.KEY_USER_ID);
                User userById = base.sfs.UserManager.GetUserById(userId);
                Room roomById = base.sfs.RoomManager.GetRoomById(@int);
                if (roomById != null)
                {
                    if (userById != null)
                    {
                        if (userById.IsJoinedInRoom(roomById))
                        {
                            userById.SetPlayerId(-1, roomById);
                            data["room"] = roomById;
                            data["user"] = userById;
                            base.sfs.DispatchEvent(new SFSEvent(SFSEvent.PLAYER_TO_SPECTATOR, data));
                        }
                        else
                        {
                            base.log.Warn(new string[] { string.Concat(new object[] { "User: ", userById, " not joined in Room: ", roomById, ", PlayerToSpectator failed." }) });
                        }
                    }
                    else
                    {
                        base.log.Warn(new string[] { "User not found, ID:" + userId + ", PlayerToSpectator failed." });
                    }
                }
                else
                {
                    base.log.Warn(new string[] { "Room not found, ID:" + @int + ", PlayerToSpectator failed." });
                }
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str;
                data["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.PLAYER_TO_SPECTATOR_ERROR, data));
            }
        }

        private void FnQuickJoinGame(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            if (content.ContainsKey(BaseRequest.KEY_ERROR_CODE))
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str;
                data["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_JOIN_ERROR, data));
            }
        }

        private void FnReconnectionFailure(IMessage msg)
        {
            base.sfs.HandleReconnectionFailure();
        }

        private void FnRemoveBuddy(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable args = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                string utfString = content.GetUtfString(RemoveBuddyRequest.KEY_BUDDY_NAME);
                Buddy buddy = base.sfs.BuddyManager.RemoveBuddyByName(utfString);
                if (buddy != null)
                {
                    args["buddy"] = buddy;
                    base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_REMOVE, args));
                }
                else
                {
                    base.log.Warn(new string[] { "RemoveBuddy failed, buddy not found: " + utfString });
                }
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str2 = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                args["errorMessage"] = str2;
                args["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_ERROR, args));
            }
        }

        private void FnRoomLost(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            int @int = content.GetInt("r");
            Room roomById = base.sfs.RoomManager.GetRoomById(@int);
            IUserManager userManager = base.sfs.UserManager;
            if (roomById != null)
            {
                base.sfs.RoomManager.RemoveRoom(roomById);
                foreach (User user in roomById.UserList)
                {
                    userManager.RemoveUser(user);
                }
                data["room"] = roomById;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_REMOVE, data));
            }
        }

        private void FnSetBuddyVariables(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable args = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                string utfString = content.GetUtfString(SetBuddyVariablesRequest.KEY_BUDDY_NAME);
                ISFSArray sFSArray = content.GetSFSArray(SetBuddyVariablesRequest.KEY_BUDDY_VARS);
                Buddy buddyByName = base.sfs.BuddyManager.GetBuddyByName(utfString);
                bool flag = utfString == base.sfs.MySelf.Name;
                List<string> list = new List<string>();
                List<BuddyVariable> variables = new List<BuddyVariable>();
                bool myOnlineState = true;
                for (int i = 0; i < sFSArray.Size(); i++)
                {
                    BuddyVariable item = SFSBuddyVariable.FromSFSArray(sFSArray.GetSFSArray(i));
                    variables.Add(item);
                    list.Add(item.Name);
                }
                if (flag)
                {
                    base.sfs.BuddyManager.MyVariables = variables;
                }
                else if (buddyByName != null)
                {
                    buddyByName.SetVariables(variables);
                    myOnlineState = base.sfs.BuddyManager.MyOnlineState;
                }
                else
                {
                    base.log.Warn(new string[] { "Unexpected. Target of BuddyVariables update not found: " + utfString });
                    return;
                }
                if (myOnlineState)
                {
                    args["isItMe"] = flag;
                    args["changedVars"] = list;
                    args["buddy"] = buddyByName;
                    base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_VARIABLES_UPDATE, args));
                }
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str2 = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                args["errorMessage"] = str2;
                args["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_ERROR, args));
            }
        }

        private void FnSetMMOItemVariables(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            int @int = content.GetInt(SetMMOItemVariables.KEY_ROOM_ID);
            int id = content.GetInt(SetMMOItemVariables.KEY_ITEM_ID);
            ISFSArray sFSArray = content.GetSFSArray(SetMMOItemVariables.KEY_VAR_LIST);
            MMORoom roomById = base.sfs.GetRoomById(@int) as MMORoom;
            List<string> list = new List<string>();
            if (roomById != null)
            {
                IMMOItem mMOItem = roomById.GetMMOItem(id);
                if (mMOItem != null)
                {
                    for (int i = 0; i < sFSArray.Size(); i++)
                    {
                        IMMOItemVariable variable = MMOItemVariable.FromSFSArray(sFSArray.GetSFSArray(i));
                        mMOItem.SetVariable(variable);
                        list.Add(variable.Name);
                    }
                    data["changedVars"] = list;
                    data["mmoItem"] = mMOItem;
                    data["room"] = roomById;
                    base.sfs.DispatchEvent(new SFSEvent(SFSEvent.MMOITEM_VARIABLES_UPDATE, data));
                }
            }
        }

        private void FnSetRoomVariables(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            int @int = content.GetInt(SetRoomVariablesRequest.KEY_VAR_ROOM);
            ISFSArray sFSArray = content.GetSFSArray(SetRoomVariablesRequest.KEY_VAR_LIST);
            Room roomById = base.sfs.RoomManager.GetRoomById(@int);
            ArrayList list = new ArrayList();
            if (roomById != null)
            {
                for (int i = 0; i < sFSArray.Size(); i++)
                {
                    RoomVariable roomVariable = SFSRoomVariable.FromSFSArray(sFSArray.GetSFSArray(i));
                    roomById.SetVariable(roomVariable);
                    list.Add(roomVariable.Name);
                }
                data["changedVars"] = list;
                data["room"] = roomById;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_VARIABLES_UPDATE, data));
            }
            else
            {
                base.log.Warn(new string[] { "RoomVariablesUpdate, unknown Room id = " + @int });
            }
        }

        private void FnSetUserPosition(IMessage msg)
        {
            Hashtable data = new Hashtable();
            ISFSObject content = msg.Content;
            int @int = content.GetInt(SetUserPositionRequest.KEY_ROOM);
            int[] intArray = content.GetIntArray(SetUserPositionRequest.KEY_MINUS_USER_LIST);
            ISFSArray sFSArray = content.GetSFSArray(SetUserPositionRequest.KEY_PLUS_USER_LIST);
            int[] numArray2 = content.GetIntArray(SetUserPositionRequest.KEY_MINUS_ITEM_LIST);
            ISFSArray array2 = content.GetSFSArray(SetUserPositionRequest.KEY_PLUS_ITEM_LIST);
            Room roomById = base.sfs.RoomManager.GetRoomById(@int);
            if (roomById != null)
            {
                int num3;
                List<User> list = new List<User>();
                List<User> list2 = new List<User>();
                List<IMMOItem> list3 = new List<IMMOItem>();
                List<IMMOItem> list4 = new List<IMMOItem>();
                if ((intArray != null) && (intArray.Length > 0))
                {
                    foreach (int num2 in intArray)
                    {
                        User userById = roomById.GetUserById(num2);
                        if (userById != null)
                        {
                            roomById.RemoveUser(userById);
                            list2.Add(userById);
                        }
                    }
                }
                if (sFSArray != null)
                {
                    for (num3 = 0; num3 < sFSArray.Size(); num3++)
                    {
                        ISFSArray userObj = sFSArray.GetSFSArray(num3);
                        User user2 = this.GetOrCreateUser(userObj, true, roomById);
                        list.Add(user2);
                        roomById.AddUser(user2);
                        if (userObj.Size() > 5)
                        {
                            object elementAt = userObj.GetElementAt(5);
                            (user2 as SFSUser).AOIEntryPoint = Vec3D.fromArray(elementAt);
                        }
                    }
                }
                MMORoom room2 = roomById as MMORoom;
                if (numArray2 != null)
                {
                    foreach (int num4 in numArray2)
                    {
                        IMMOItem mMOItem = room2.GetMMOItem(num4);
                        if (mMOItem != null)
                        {
                            room2.RemoveItem(num4);
                            list4.Add(mMOItem);
                        }
                    }
                }
                if (array2 != null)
                {
                    for (num3 = 0; num3 < array2.Size(); num3++)
                    {
                        ISFSArray encodedItem = array2.GetSFSArray(num3);
                        IMMOItem item = MMOItem.FromSFSArray(encodedItem);
                        list3.Add(item);
                        room2.AddMMOItem(item);
                        if (encodedItem.Size() > 2)
                        {
                            object array = encodedItem.GetElementAt(2);
                            (item as MMOItem).AOIEntryPoint = Vec3D.fromArray(array);
                        }
                    }
                }
                data["addedItems"] = list3;
                data["removedItems"] = list4;
                data["removedUsers"] = list2;
                data["addedUsers"] = list;
                data["room"] = roomById as MMORoom;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.PROXIMITY_LIST_UPDATE, data));
            }
        }

        private void FnSetUserVariables(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            int @int = content.GetInt(SetUserVariablesRequest.KEY_USER);
            ISFSArray sFSArray = content.GetSFSArray(SetUserVariablesRequest.KEY_VAR_LIST);
            User userById = base.sfs.UserManager.GetUserById(@int);
            ArrayList list = new ArrayList();
            if (userById != null)
            {
                for (int i = 0; i < sFSArray.Size(); i++)
                {
                    UserVariable userVariable = SFSUserVariable.FromSFSArray(sFSArray.GetSFSArray(i));
                    userById.SetVariable(userVariable);
                    list.Add(userVariable.Name);
                }
                data["changedVars"] = list;
                data["user"] = userById;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.USER_VARIABLES_UPDATE, data));
            }
            else
            {
                base.log.Warn(new string[] { "UserVariablesUpdate: unknown user id = " + @int });
            }
        }

        private void FnSpectatorToPlayer(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                int @int = content.GetInt(SpectatorToPlayerRequest.KEY_ROOM_ID);
                int userId = content.GetInt(SpectatorToPlayerRequest.KEY_USER_ID);
                int @short = content.GetShort(SpectatorToPlayerRequest.KEY_PLAYER_ID);
                User userById = base.sfs.UserManager.GetUserById(userId);
                Room roomById = base.sfs.RoomManager.GetRoomById(@int);
                if (roomById != null)
                {
                    if (userById != null)
                    {
                        if (userById.IsJoinedInRoom(roomById))
                        {
                            userById.SetPlayerId(@short, roomById);
                            data["room"] = roomById;
                            data["user"] = userById;
                            data["playerId"] = @short;
                            base.sfs.DispatchEvent(new SFSEvent(SFSEvent.SPECTATOR_TO_PLAYER, data));
                        }
                        else
                        {
                            base.log.Warn(new string[] { string.Concat(new object[] { "User: ", userById, " not joined in Room: ", roomById, ", SpectatorToPlayer failed." }) });
                        }
                    }
                    else
                    {
                        base.log.Warn(new string[] { "User not found, ID:" + userId + ", SpectatorToPlayer failed." });
                    }
                }
                else
                {
                    base.log.Warn(new string[] { "Room not found, ID:" + @int + ", SpectatorToPlayer failed." });
                }
            }
            else
            {
                short code = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str = SFSErrorCodes.GetErrorMessage(code, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str;
                data["errorCode"] = code;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.SPECTATOR_TO_PLAYER_ERROR, data));
            }
        }

        private void FnSubscribeRoomGroup(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                string utfString = content.GetUtfString(SubscribeRoomGroupRequest.KEY_GROUP_ID);
                ISFSArray sFSArray = content.GetSFSArray(SubscribeRoomGroupRequest.KEY_ROOM_LIST);
                if (base.sfs.RoomManager.ContainsGroup(utfString))
                {
                    base.log.Warn(new string[] { "SubscribeGroup Error. Group:" + utfString + "already subscribed!" });
                }
                this.PopulateRoomList(sFSArray);
                data["groupId"] = utfString;
                data["newRooms"] = base.sfs.RoomManager.GetRoomListFromGroup(utfString);
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_GROUP_SUBSCRIBE, data));
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str2 = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str2;
                data["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_GROUP_SUBSCRIBE_ERROR, data));
            }
        }

        private void FnUnsubscribeRoomGroup(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            if (content.IsNull(BaseRequest.KEY_ERROR_CODE))
            {
                string utfString = content.GetUtfString(UnsubscribeRoomGroupRequest.KEY_GROUP_ID);
                if (!base.sfs.RoomManager.ContainsGroup(utfString))
                {
                    base.log.Warn(new string[] { "UnsubscribeGroup Error. Group:" + utfString + "is not subscribed!" });
                }
                base.sfs.RoomManager.RemoveGroup(utfString);
                data["groupId"] = utfString;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_GROUP_UNSUBSCRIBE, data));
            }
            else
            {
                short @short = content.GetShort(BaseRequest.KEY_ERROR_CODE);
                string str2 = SFSErrorCodes.GetErrorMessage(@short, base.sfs.Log, content.GetUtfStringArray(BaseRequest.KEY_ERROR_PARAMS));
                data["errorMessage"] = str2;
                data["errorCode"] = @short;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.ROOM_GROUP_UNSUBSCRIBE_ERROR, data));
            }
        }

        private void FnUserCountChange(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            Room roomById = base.sfs.RoomManager.GetRoomById(content.GetInt("r"));
            if (roomById != null)
            {
                int @short = content.GetShort("uc");
                int num2 = 0;
                if (content.ContainsKey("sc"))
                {
                    num2 = content.GetShort("sc");
                }
                roomById.UserCount = @short;
                roomById.SpectatorCount = num2;
                data["room"] = roomById;
                data["uCount"] = @short;
                data["sCount"] = num2;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.USER_COUNT_CHANGE, data));
            }
        }

        private void FnUserEnterRoom(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            Room roomById = base.sfs.RoomManager.GetRoomById(content.GetInt("r"));
            if (roomById != null)
            {
                ISFSArray sFSArray = content.GetSFSArray("u");
                User user = this.GetOrCreateUser(sFSArray, true, roomById);
                roomById.AddUser(user);
                data["user"] = user;
                data["room"] = roomById;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.USER_ENTER_ROOM, data));
            }
        }

        private void FnUserExitRoom(IMessage msg)
        {
            ISFSObject content = msg.Content;
            Hashtable data = new Hashtable();
            int @int = content.GetInt("r");
            int userId = content.GetInt("u");
            Room roomById = base.sfs.RoomManager.GetRoomById(@int);
            User userById = base.sfs.UserManager.GetUserById(userId);
            if ((roomById != null) && (userById != null))
            {
                roomById.RemoveUser(userById);
                base.sfs.UserManager.RemoveUser(userById);
                if (userById.IsItMe && roomById.IsJoined)
                {
                    roomById.IsJoined = false;
                    if (base.sfs.JoinedRooms.Count == 0)
                    {
                        base.sfs.LastJoinedRoom = null;
                    }
                    if (!roomById.IsManaged)
                    {
                        base.sfs.RoomManager.RemoveRoom(roomById);
                    }
                }
                data["user"] = userById;
                data["room"] = roomById;
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.USER_EXIT_ROOM, data));
            }
            else
            {
                base.log.Debug(new string[] { string.Concat(new object[] { "Failed to handle UserExit event. Room: ", roomById, ", User: ", userById }) });
            }
        }

        private void FnUserLost(IMessage msg)
        {
            int @int = msg.Content.GetInt("u");
            User userById = base.sfs.UserManager.GetUserById(@int);
            if (userById != null)
            {
                List<Room> userRooms = base.sfs.RoomManager.GetUserRooms(userById);
                base.sfs.RoomManager.RemoveUser(userById);
                (base.sfs.UserManager as SFSGlobalUserManager).RemoveUserReference(userById, true);
                foreach (Room room in userRooms)
                {
                    Hashtable data = new Hashtable();
                    data["user"] = userById;
                    data["room"] = room;
                    base.sfs.DispatchEvent(new SFSEvent(SFSEvent.USER_EXIT_ROOM, data));
                }
            }
        }

        private User GetOrCreateUser(ISFSArray userObj)
        {
            return this.GetOrCreateUser(userObj, false, null);
        }

        private User GetOrCreateUser(ISFSArray userObj, bool addToGlobalManager)
        {
            return this.GetOrCreateUser(userObj, addToGlobalManager, null);
        }

        private User GetOrCreateUser(ISFSArray userObj, bool addToGlobalManager, Room room)
        {
            int @int = userObj.GetInt(0);
            User userById = base.sfs.UserManager.GetUserById(@int);
            if (userById == null)
            {
                userById = SFSUser.FromSFSArray(userObj, room);
                userById.UserManager = base.sfs.UserManager;
            }
            else if (room != null)
            {
                userById.SetPlayerId(userObj.GetShort(3), room);
                ISFSArray sFSArray = userObj.GetSFSArray(4);
                for (int i = 0; i < sFSArray.Size(); i++)
                {
                    userById.SetVariable(SFSUserVariable.FromSFSArray(sFSArray.GetSFSArray(i)));
                }
            }
            if (addToGlobalManager)
            {
                base.sfs.UserManager.AddUser(userById);
            }
            return userById;
        }

        public void HandleAdminMessage(ISFSObject sfso)
        {
            this.HandleModMessage(sfso, SFSEvent.ADMIN_MESSAGE);
        }

        public void HandleBuddyMessage(ISFSObject sfso)
        {
            Hashtable args = new Hashtable();
            int @int = sfso.GetInt(GenericMessageRequest.KEY_USER_ID);
            Buddy buddyById = base.sfs.BuddyManager.GetBuddyById(@int);
            args["isItMe"] = base.sfs.MySelf.Id == @int;
            args["buddy"] = buddyById;
            args["message"] = sfso.GetUtfString(GenericMessageRequest.KEY_MESSAGE);
            args["data"] = sfso.GetSFSObject(GenericMessageRequest.KEY_XTRA_PARAMS);
            base.sfs.DispatchEvent(new SFSBuddyEvent(SFSBuddyEvent.BUDDY_MESSAGE, args));
        }

        public override void HandleMessage(IMessage message)
        {
            if (base.sfs.Debug)
            {
                base.log.Info(new string[] { string.Concat(new object[] { "Message: ", (RequestType) message.Id, " ", message }) });
            }
            if (!this.requestHandlers.ContainsKey(message.Id))
            {
                base.log.Warn(new string[] { "Unknown message id: " + message.Id });
            }
            else
            {
                RequestDelegate delegate2 = this.requestHandlers[message.Id];
                delegate2(message);
            }
        }

        public void HandleModMessage(ISFSObject sfso)
        {
            this.HandleModMessage(sfso, SFSEvent.MODERATOR_MESSAGE);
        }

        private void HandleModMessage(ISFSObject sfso, string evt)
        {
            Hashtable data = new Hashtable();
            data["sender"] = SFSUser.FromSFSArray(sfso.GetSFSArray(GenericMessageRequest.KEY_SENDER_DATA));
            data["message"] = sfso.GetUtfString(GenericMessageRequest.KEY_MESSAGE);
            data["data"] = sfso.GetSFSObject(GenericMessageRequest.KEY_XTRA_PARAMS);
            base.sfs.DispatchEvent(new SFSEvent(evt, data));
        }

        public void HandleObjectMessage(ISFSObject sfso)
        {
            Hashtable data = new Hashtable();
            int @int = sfso.GetInt(GenericMessageRequest.KEY_USER_ID);
            data["sender"] = base.sfs.UserManager.GetUserById(@int);
            data["message"] = sfso.GetSFSObject(GenericMessageRequest.KEY_XTRA_PARAMS);
            base.sfs.DispatchEvent(new SFSEvent(SFSEvent.OBJECT_MESSAGE, data));
        }

        public void HandlePrivateMessage(ISFSObject sfso)
        {
            Hashtable data = new Hashtable();
            int @int = sfso.GetInt(GenericMessageRequest.KEY_USER_ID);
            User userById = base.sfs.UserManager.GetUserById(@int);
            if (userById == null)
            {
                if (!sfso.ContainsKey(GenericMessageRequest.KEY_SENDER_DATA))
                {
                    base.log.Warn(new string[] { "Unexpected. Private message has no Sender details!" });
                    return;
                }
                userById = SFSUser.FromSFSArray(sfso.GetSFSArray(GenericMessageRequest.KEY_SENDER_DATA));
            }
            data["sender"] = userById;
            data["message"] = sfso.GetUtfString(GenericMessageRequest.KEY_MESSAGE);
            data["data"] = sfso.GetSFSObject(GenericMessageRequest.KEY_XTRA_PARAMS);
            base.sfs.DispatchEvent(new SFSEvent(SFSEvent.PRIVATE_MESSAGE, data));
        }

        private void HandlePublicMessage(ISFSObject sfso)
        {
            Hashtable data = new Hashtable();
            int @int = sfso.GetInt(GenericMessageRequest.KEY_ROOM_ID);
            Room roomById = base.sfs.RoomManager.GetRoomById(@int);
            if (roomById != null)
            {
                data["room"] = roomById;
                data["sender"] = base.sfs.UserManager.GetUserById(sfso.GetInt(GenericMessageRequest.KEY_USER_ID));
                data["message"] = sfso.GetUtfString(GenericMessageRequest.KEY_MESSAGE);
                data["data"] = sfso.GetSFSObject(GenericMessageRequest.KEY_XTRA_PARAMS);
                base.sfs.DispatchEvent(new SFSEvent(SFSEvent.PUBLIC_MESSAGE, data));
            }
            else
            {
                base.log.Warn(new string[] { "Unexpected, PublicMessage target room doesn't exist. RoomId: " + @int });
            }
        }

        private void InitRequestHandlers()
        {
            this.requestHandlers[0] = new RequestDelegate(this.FnHandshake);
            this.requestHandlers[1] = new RequestDelegate(this.FnLogin);
            this.requestHandlers[2] = new RequestDelegate(this.FnLogout);
            this.requestHandlers[4] = new RequestDelegate(this.FnJoinRoom);
            this.requestHandlers[6] = new RequestDelegate(this.FnCreateRoom);
            this.requestHandlers[7] = new RequestDelegate(this.FnGenericMessage);
            this.requestHandlers[8] = new RequestDelegate(this.FnChangeRoomName);
            this.requestHandlers[9] = new RequestDelegate(this.FnChangeRoomPassword);
            this.requestHandlers[0x13] = new RequestDelegate(this.FnChangeRoomCapacity);
            this.requestHandlers[11] = new RequestDelegate(this.FnSetRoomVariables);
            this.requestHandlers[12] = new RequestDelegate(this.FnSetUserVariables);
            this.requestHandlers[15] = new RequestDelegate(this.FnSubscribeRoomGroup);
            this.requestHandlers[0x10] = new RequestDelegate(this.FnUnsubscribeRoomGroup);
            this.requestHandlers[0x11] = new RequestDelegate(this.FnSpectatorToPlayer);
            this.requestHandlers[0x12] = new RequestDelegate(this.FnPlayerToSpectator);
            this.requestHandlers[200] = new RequestDelegate(this.FnInitBuddyList);
            this.requestHandlers[0xc9] = new RequestDelegate(this.FnAddBuddy);
            this.requestHandlers[0xcb] = new RequestDelegate(this.FnRemoveBuddy);
            this.requestHandlers[0xca] = new RequestDelegate(this.FnBlockBuddy);
            this.requestHandlers[0xcd] = new RequestDelegate(this.FnGoOnline);
            this.requestHandlers[0xcc] = new RequestDelegate(this.FnSetBuddyVariables);
            this.requestHandlers[0x1b] = new RequestDelegate(this.FnFindRooms);
            this.requestHandlers[0x1c] = new RequestDelegate(this.FnFindUsers);
            this.requestHandlers[300] = new RequestDelegate(this.FnInviteUsers);
            this.requestHandlers[0x12d] = new RequestDelegate(this.FnInvitationReply);
            this.requestHandlers[0x12f] = new RequestDelegate(this.FnQuickJoinGame);
            this.requestHandlers[0x1d] = new RequestDelegate(this.FnPingPong);
            this.requestHandlers[30] = new RequestDelegate(this.FnSetUserPosition);
            this.requestHandlers[0x3e8] = new RequestDelegate(this.FnUserEnterRoom);
            this.requestHandlers[0x3e9] = new RequestDelegate(this.FnUserCountChange);
            this.requestHandlers[0x3ea] = new RequestDelegate(this.FnUserLost);
            this.requestHandlers[0x3eb] = new RequestDelegate(this.FnRoomLost);
            this.requestHandlers[0x3ec] = new RequestDelegate(this.FnUserExitRoom);
            this.requestHandlers[0x3ed] = new RequestDelegate(this.FnClientDisconnection);
            this.requestHandlers[0x3ee] = new RequestDelegate(this.FnReconnectionFailure);
            this.requestHandlers[0x3ef] = new RequestDelegate(this.FnSetMMOItemVariables);
        }

        private void PopulateRoomList(ISFSArray roomList)
        {
            IRoomManager roomManager = base.sfs.RoomManager;
            for (int i = 0; i < roomList.Size(); i++)
            {
                Room room = SFSRoom.FromSFSArray(roomList.GetSFSArray(i));
                roomManager.ReplaceRoom(room);
            }
        }
    }
}

