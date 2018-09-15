namespace Sfs2X.Util
{
    using Sfs2X.Logging;
    using System;
    using System.Collections.Generic;

    public static class SFSErrorCodes
    {
        private static Dictionary<int, string> errorsByCode;

        static SFSErrorCodes()
        {
            Dictionary<int, string> dictionary = new Dictionary<int, string>();
            dictionary.Add(0, "Client API version is obsolete: {0}; required version: {1}");
            dictionary.Add(1, "Requested Zone {0} does not exist");
            dictionary.Add(2, "User name {0} is not recognized");
            dictionary.Add(3, "Wrong password for user {0}");
            dictionary.Add(4, "User {0} is banned");
            dictionary.Add(5, "Zone {0} is full");
            dictionary.Add(6, "User {0} is already logged in Zone {1}");
            dictionary.Add(7, "The server is full");
            dictionary.Add(8, "Zone {0} is currently inactive");
            dictionary.Add(9, "User name {0} contains bad words; filtered: {1}");
            dictionary.Add(10, "Guest users not allowed in Zone {0}");
            dictionary.Add(11, "IP address {0} is banned");
            dictionary.Add(12, "A Room with the same name already exists: {0}");
            dictionary.Add(13, "Requested Group is not available - Room: {0}; Group: {1}");
            dictionary.Add(14, "Bad Room name length -  Min: {0}; max: {1}; passed name length: {2}");
            dictionary.Add(15, "Room name contains bad words: {0}");
            dictionary.Add(0x10, "Zone is full; can't add Rooms anymore");
            dictionary.Add(0x11, "You have exceeded the number of Rooms that you can create per session: {0}");
            dictionary.Add(0x12, "Room creation failed, wrong parameter: {0}");
            dictionary.Add(0x13, "User {0} already joined in Room");
            dictionary.Add(20, "Room {0} is full");
            dictionary.Add(0x15, "Wrong password for Room {0}");
            dictionary.Add(0x16, "Requested Room does not exist");
            dictionary.Add(0x17, "Room {0} is locked");
            dictionary.Add(0x18, "Group {0} is already subscribed");
            dictionary.Add(0x19, "Group {0} does not exist");
            dictionary.Add(0x1a, "Group {0} is not subscribed");
            dictionary.Add(0x1b, "Group {0} does not exist");
            dictionary.Add(0x1c, "{0}");
            dictionary.Add(0x1d, "Room permission error; Room {0} cannot be renamed");
            dictionary.Add(30, "Room permission error; Room {0} cannot change password statee");
            dictionary.Add(0x1f, "Room permission error; Room {0} cannot change capacity");
            dictionary.Add(0x20, "Switch user error; no player slots available in Room {0}");
            dictionary.Add(0x21, "Switch user error; no spectator slots available in Room {0}");
            dictionary.Add(0x22, "Switch user error; Room {0} is not a Game Room");
            dictionary.Add(0x23, "Switch user error; you are not joined in Room {0}");
            dictionary.Add(0x24, "Buddy Manager initialization error, could not load buddy list: {0}");
            dictionary.Add(0x25, "Buddy Manager error, your buddy list is full; size is {0}");
            dictionary.Add(0x26, "Buddy Manager error, was not able to block buddy {0} because offline");
            dictionary.Add(0x27, "Buddy Manager error, you are attempting to set too many Buddy Variables; limit is {0}");
            dictionary.Add(40, "Game {0} access denied, user does not match access criteria");
            dictionary.Add(0x29, "QuickJoinGame action failed: no matching Rooms were found");
            dictionary.Add(0x2a, "Your previous invitation reply was invalid or arrived too late");
            errorsByCode = dictionary;
        }

        public static string GetErrorMessage(int code, Logger log, params object[] args)
        {
            try
            {
                return string.Format(errorsByCode[code], args);
            }
            catch (Exception exception)
            {
                log.Error(new string[] { "Formatting error string failed with exception: " + exception.Message });
                return errorsByCode[code];
            }
        }

        public static void SetErrorMessage(int code, string message)
        {
            errorsByCode[code] = message;
        }
    }
}

