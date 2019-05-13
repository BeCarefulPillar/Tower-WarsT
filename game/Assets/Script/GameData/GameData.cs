using JumpCSV;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public partial class GameData {
    private static readonly GameData mInstance = new GameData();

    public Dictionary<int, HeroData> heros;

    public GameData() {
        LocalizationMgr.Instance.Init();
        CsvManager.Init(GameConfig.GetCurrentCsvTargetPath());
        
        heros = new Dictionary<int, HeroData>();
    }

    public static GameData Instance {
        get {
            return mInstance;
        }
    }
}


