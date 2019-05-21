using JumpCSV;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public partial class GameData {
    private int mId;
    private string mAccountId;
    public string mName;
    private int mSex;
    private int mLevel;
    private string mRecordInfo;

    private static readonly GameData mInstance = new GameData();

    public Dictionary<int, HeroData> heros;

    public GameData() {
        LocalizationMgr.Instance.Init();
        CsvManager.Init(GameConfig.GetCurrentCsvTargetPath());

        
    }

    public void InitDataInfo(int id, string accountId, string name, int sex, int level, string recordInfo) {
        mId = id;
        mAccountId = accountId;
        mName = name;
        mSex = sex;
        mLevel = level;
        mRecordInfo = recordInfo;
        
        heros = new Dictionary<int, HeroData>();
    }

    public string GetRecordInfo() {
        return mRecordInfo;
    }

    public static GameData Instance {
        get {
            return mInstance;
        }
    }
}


