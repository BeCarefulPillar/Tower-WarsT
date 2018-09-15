namespace Sfs2X.Requests
{
    using System;

    public enum RequestType
    {
        AddBuddy = 0xc9,
        AdminMessage = 0x17,
        AutoJoin = 5,
        BanUser = 0x19,
        BlockBuddy = 0xca,
        CallExtension = 13,
        ChangeRoomCapacity = 0x13,
        ChangeRoomName = 8,
        ChangeRoomPassword = 9,
        CreateRoom = 6,
        CreateSFSGame = 0x12e,
        FindRooms = 0x1b,
        FindUsers = 0x1c,
        GenericMessage = 7,
        GetRoomList = 3,
        GoOnline = 0xcd,
        Handshake = 0,
        InitBuddyList = 200,
        InvitationReply = 0x12d,
        InviteUser = 300,
        JoinRoom = 4,
        KickUser = 0x18,
        LeaveRoom = 14,
        Login = 1,
        Logout = 2,
        ManualDisconnection = 0x1a,
        ModeratorMessage = 0x16,
        ObjectMessage = 10,
        PingPong = 0x1d,
        PlayerToSpectator = 0x12,
        PrivateMessage = 0x15,
        PublicMessage = 20,
        QuickJoinGame = 0x12f,
        RemoveBuddy = 0xcb,
        SetBuddyVariables = 0xcc,
        SetRoomVariables = 11,
        SetUserPosition = 30,
        SetUserVariables = 12,
        SpectatorToPlayer = 0x11,
        SubscribeRoomGroup = 15,
        UnsubscribeRoomGroup = 0x10
    }
}

