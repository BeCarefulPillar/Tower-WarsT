using JumpCSV;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.Serialization.Json;
using System.IO;
using System.Text;

public partial class GameData {
    private static readonly GameData mInstance = new GameData();
    private int mId;
    private string mAccountId;

    public string name;
    public int sex;
    public int level;
    public string recordInfo;
    public RecordInfo recordDataInfo;

    public bool IsLogin { get; private set; }

    public class RecordInfo {
        public Dictionary<int, HeroData> heros;
        public RecordInfo() {
            heros = new Dictionary<int, HeroData>();
        }
    }
    
    public GameData() {
        LocalizationMgr.Instance.Init();
        CsvManager.Init(GameConfig.GetCurrentCsvTargetPath()); 
        recordDataInfo = new RecordInfo();
        IsLogin = false;
    }

    public void InitDataInfo(int id, string accountId, string name, int sex, int level, string recordInfo) {
        mId = id;
        mAccountId = accountId;
        this.name = name;
        this.sex = sex;
        this.level = level;
        this.recordInfo = recordInfo;
        
        Deserialization();
        IsLogin = true;
        //CreateHero(1);
    }
    
    private void Serialization() {
        var serializer = new DataContractJsonSerializer(typeof(RecordInfo));
        var stream = new MemoryStream();
        serializer.WriteObject(stream, recordDataInfo);

        byte[]dataBytes = new byte[stream.Length];
        stream.Position = 0;
        stream.Read(dataBytes, 0, (int)stream.Length);

        string dataString = Encoding.UTF8.GetString(dataBytes);
        recordInfo = dataString;
    }

    private void Deserialization() {
        var serializer = new DataContractJsonSerializer(typeof(RecordInfo));
        var mStream = new MemoryStream(Encoding.Default.GetBytes(recordInfo));
        recordDataInfo = (RecordInfo)serializer.ReadObject(mStream);
    }

    public static GameData Instance {
        get {
            return mInstance;
        }
    }

    public void SavePlayer() {
        Serialization();
        MysqlMethod mysql = new MysqlMethod();
        mysql.SaveAccountPlayer(mAccountId);
    }
}


