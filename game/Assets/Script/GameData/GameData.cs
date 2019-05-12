using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public partial class GameData {
    private static readonly GameData mInstance = new GameData();

    public Dictionary<int, HeroData> heros;

    public GameData() {
        heros = new Dictionary<int, HeroData>();
    }

    public GameData Instance {
        get {
            return mInstance;
        }
    }
}


