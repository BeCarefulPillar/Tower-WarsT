// Copyright (C) 2016 Joywinds Inc.
//#if FAN_PLATFORM | A_PLATFROM | B_PLATFROM |... 
#if FAN_PLATFORM || CIS_PLATFORM
#define USE_PUBLISHER_SDK
#endif
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

public static class GameConfig {
    public enum EChannel {
        TEST = 0,
        ALPHA = 1,
        BETA = 2,
        MEIZU = 612,
        G4399 = 611,   // 4399
        VIVO = 609,
        YYB = 608,
        OPPO = 607,
        XIAOMI = 606,
        HAWE = 605,    // huawei platfome
        UC = 604,    // uc platform
        YOUK = 603,    // youku platform
        HELE = 602,    // hele platform
        GRAVITY_APPLE = 700,
        GRAVITY_GOOGLE = 701,
        GRAVITY_GOOGLE_SA = 702, // southeast asia
        SUPERNOVE_APPLE = 800,
        SUPERNOVE_GOOGLE = 801,
        FAN_APPLE = 10001,  // apple store
        FAN_GOOGLE = 10003,  // googleplay for taiwan
        FAN_MYCARD = 10004, // mycard purchase for taiwan
        FAN_WEB = 10005, // mycard web purchase
        CHIXIAO_APPLE = 10100, // 58play app store
        CHIXIAO_GOOGLE = 10101, // 58play google 
        CHIXIAO_WEB = 10102, // 58play web
        GOOGLEPLAY = 20000,
        APPLE = 30000,
    }

    public enum EPublisherSDK {
        NONE,
        FAN,
        CIS,
    }

    public enum EAuth {
        NONE,
        SDK,
        THIRD,
    }

    public enum EGameConfig {
        TEST = 1,
        COCO = 2,
        GRAVITY = 3,
    }

    public enum ERegion {
        China = 1,
        Taiwan = 2,
        Korea = 3,
        USA = 4,
    }

    public enum EServerGroup {
        TEST = 0,
        BETA = 1,
        COCO = 10,
        APPLE = 110,
        APPLE_BREAK = 120,
        ANDROID = 119,
    }

    public enum EGateWay {
        ALI,
        HMT,
        HMT2,
        LOCAL,
        COCO,
    }

    public enum EShipChannel {
        TEST = 1,
        CHINESE_ANDROID = 2,
        CHINESE_IOS = 3,
        CHINESE_OFFICAL = 4,
        GRAVITY = 5,
    }

    public static Dictionary<EShipChannel, string> CsvTargetPath = new Dictionary<EShipChannel, string>() {
        {EShipChannel.TEST,            "Assets/Build/CSV/Common/"         },
        {EShipChannel.CHINESE_ANDROID, "Assets/Build/CSV/CoconutsIsland/" },
        {EShipChannel.CHINESE_IOS,     "Assets/Build/CSV/CoconutsIsland/" },
        {EShipChannel.CHINESE_OFFICAL, "Assets/Build/CSV/SuperNova/"      },
        {EShipChannel.GRAVITY,         "Assets/Build/CSV/Gravity/"        },
    };

    public static Dictionary<EShipChannel, string> UiTargetPath = new Dictionary<EShipChannel, string>() {
        {EShipChannel.TEST,            "Assets/Prefab/Ship_Difference/Common" },
        {EShipChannel.CHINESE_ANDROID, "Assets/Prefab/Ship_Difference/Chinese_Channel" },
        {EShipChannel.CHINESE_IOS,     "Assets/Prefab/Ship_Difference/Chinese_iOS" },
        {EShipChannel.CHINESE_OFFICAL, "Assets/Prefab/Ship_Difference/Chinese_Offical" },
        {EShipChannel.GRAVITY,         "Assets/Prefab/Ship_Difference/Global_Gravity" },
    };


    public static EShipChannel SHIP_CHANNEL = EShipChannel.TEST;
    public static int GAME_CHANNEL_NUM = 0;
    public static int SERVER_GROUP_NUM = 0;
    public static ERegion REGION = ERegion.China;
    public static string GATEWAY_URL = "";
    public static string PAY_URL = "";
    public static string VIDEO_URL = "";
    public static bool ADTRACKING = false;
    public static string TALKING_DATA_ID = "";
    public static EAuth AUTH;
    public static double TIME_OFFSET = 0;

#if FAN_PLATFORM
    public static EPublisherSDK PUBLISHER_SDK = GameConfig.EPublisherSDK.FAN;
#elif CIS_PLATFORM
    public static EPublisherSDK PUBLISHER_SDK = GameConfig.EPublisherSDK.CIS;
#elif GRAVITY_PLATFORM
    public static EPublisherSDK PUBLISHER_SDK = GameConfig.EPublisherSDK.NONE;
#else
    public static EPublisherSDK PUBLISHER_SDK = GameConfig.EPublisherSDK.NONE;
#endif


    public static EChannel GAME_CHANNEL {
        get {
            return (EChannel)GAME_CHANNEL_NUM;
        }
    }

    public static EServerGroup SERVER_GROUP {
        get {
            return (EServerGroup)SERVER_GROUP_NUM;
        }
    }
    // 
    //         public static void LoadConfig(JSONObject config) {
    //             SHIP_CHANNEL      = (EShipChannel)Enum.Parse(typeof(EShipChannel), config["Ship"].str);
    //             GAME_CHANNEL_NUM  = config["Channel"].i;
    //             SERVER_GROUP_NUM  = config["Group"].i;
    //             REGION            = (ERegion)Enum.Parse(typeof(ERegion), config["Region"].str);
    //             GATEWAY_URL       = config["Gateway"].str;
    //             PAY_URL           = config["Pay"].str;
    //             TALKING_DATA_ID   = config["TalkingData"].str;
    //             AUTH              = (EAuth)Enum.Parse(typeof(EAuth), config["Auth"].str);
    //             VIDEO_URL         = config["Video"].str;
    //             ADTRACKING        = config["AdTracking"].b;
    //             //TIME_OFFSET       = config["TimeOffset"].n;
    //         }

    public static string GetCsvTargetPath(EShipChannel shipChannel) {
        return CsvTargetPath[shipChannel];
    }

    public static string GetCurrentCsvTargetPath() {
        return CsvTargetPath[SHIP_CHANNEL];
    }

    public static string GetUiTargetPath(EShipChannel shipChannel) {
        return UiTargetPath[shipChannel];
    }

    public static string GetCurrentUiTargetPath() {
        return UiTargetPath[SHIP_CHANNEL];
    }

}
