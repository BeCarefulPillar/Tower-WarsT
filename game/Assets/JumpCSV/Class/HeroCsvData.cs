// ------------------------------------------------------------------------------
//  <autogenerated>
//      This code was generated by a tool.
//      Mono Runtime Version: 2.0.50727.1433
// 
//      Changes to this file may cause incorrect behavior and will be lost if 
//      the code is regenerated.
//  </autogenerated>
// ------------------------------------------------------------------------------

namespace JumpCSV {
    using System;
    using System.IO;
    using System.Collections;
    using System.Collections.Generic;
    using System.Runtime.Serialization.Formatters.Binary;
    using UnityEngine;
    using System.Security.Cryptography;
    using System.Text;
    
    
    [Serializable()]
    public struct HeroRecord {
        
        public String     Name;
        public Int32      _ID;
        public Int32      _VALUE;
        public Int32      NameKey;
        public Int32      DesKey;
        
	}
    
    public class HeroCsvData {
        
        public static readonly Dictionary<int, string> RecordIdValue = new Dictionary<int, string>() {
            {1  , "HERO_SK"                     },
            {2  , "HERO_XW"                     },
        };
        
        public static readonly Dictionary<string, int> IdRecordValue = new Dictionary<string, int>() {
            {"HERO_SK"                     , 1  },
            {"HERO_XW"                     , 2  },
        };
        
        public static Dictionary<int, HeroRecord> Data = new Dictionary<int, HeroRecord>();
        public static HeroRecord GetRecord(int id)
        { 
        if(Data.ContainsKey(id)) {
                return Data[id];
            }
            else {
                throw new Exception("Can not find record by id " + id);
            }
        }
        public static void Serialize(string filename) {
            BinaryFormatter formatter = new BinaryFormatter();
            Stream stream = new FileStream(filename, FileMode.OpenOrCreate, FileAccess.Write, FileShare.None);
            MemoryStream mstream = new MemoryStream();
            formatter.Serialize(mstream, Data);
            byte[] mbyte = mstream.ToArray();
            byte[] tmp = new byte[mbyte.Length];
            CsvHelper.Encode(mbyte, 0, tmp, 0, tmp.Length, ASCIIEncoding.ASCII.GetBytes("ABCDEFG2"));
            stream.Write(tmp, 0, tmp.Length);
            mstream.Close();
            stream.Close();
        }
        public static void Deserialize(string filename, bool isAssetBundle = false) {
            TextAsset textAsset = null;
            if(isAssetBundle && AssetBundleMgr.ContainsFile(filename, "bytes")) {
                textAsset = AssetBundleMgr.Load(filename, "bytes") as TextAsset;
            }
            else {
                textAsset = Resources.Load(filename) as TextAsset;
            }
            BinaryFormatter formatter = new BinaryFormatter();
            MemoryStream mstream = new MemoryStream();
            byte[] tmp = new byte[textAsset.bytes.Length];
            CsvHelper.Encode(textAsset.bytes, 0, tmp, 0, tmp.Length, ASCIIEncoding.ASCII.GetBytes("ABCDEFG2"));
            mstream.Write(tmp, 0, tmp.Length);
            mstream.Position = 0;
            Data = formatter.Deserialize(mstream) as Dictionary<int, HeroRecord>;
            mstream.Close();    
        }
        public static int mHashCode = 480650395;
        public static string Name(int recordId) {
            return GetRecord(recordId).Name;
        }
        
        public static int _ID(int recordId) {
            return GetRecord(recordId)._ID;
        }
        
        public static int _VALUE(int recordId) {
            return GetRecord(recordId)._VALUE;
        }
        
        public static int NameKey(int recordId) {
            return GetRecord(recordId).NameKey;
        }
        
        public static int DesKey(int recordId) {
            return GetRecord(recordId).DesKey;
        }
        
        public static void Read(string fileName) {
            Data.Clear();
            JumpCSV.CsvSpreadSheet sheet = new JumpCSV.CsvSpreadSheet(fileName, true);
            for (int i = 0; (i < sheet.Records.Count); i = (i + 1)) {
                HeroRecord record = new HeroRecord();
                record.Name = CsvValueConverter.ReadValueString(sheet, i, "Name");
                record._ID = CsvValueConverter.ReadValueDicValue(sheet, i, "_VALUE");
                record._VALUE = CsvValueConverter.ReadValueDicValue(sheet, i, "_VALUE");
                record.NameKey = CsvValueConverter.ReadValueCsvLoc(sheet, i, "NameKey");
                record.DesKey = CsvValueConverter.ReadValueCsvLoc(sheet, i, "DesKey");
                int keyValue = sheet.GetRecord(i).KeyValue;
                Data.Add(keyValue, record);;
            }
        }
    }
}
