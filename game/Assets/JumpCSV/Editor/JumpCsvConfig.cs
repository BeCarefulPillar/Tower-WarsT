using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections.Generic;

namespace JumpCSV {
    [System.Serializable]
    public class JumpCsvConfig : ScriptableObject {

        [Serializable]
        public class CsvSpreadSheetId {
            [SerializeField]
            public string fileName;
            public int    fileId;
        } 

        [SerializeField]public string    mCsvSpreadSheetFileDirectory         = @"";            // related to  <path to project folder>/Assets
        [SerializeField]public string    mCsvSourceCodeFileDirectory          = @"JumpCSV/Class";  // related to  <path to project folder>/Assets
        [SerializeField]public string    mCsvBinDataDirectory                 = @"Resources/CsvBin";           // related to  <path to project folder>/Assets
        
        [SerializeField]public string    mCsvDataClassPostfixName             = @"CsvData";
        [SerializeField]public string    mCsvDataClassPrefixName              = @"";
        
        [SerializeField]public string    mCsvDataStructPostfixName            = @"Record";
        [SerializeField]public string    mCsvDataStructPrefixName             = @"";

        [SerializeField]
        public List<string> mExcludeCsvFiles = new List<string>()
        {
        };

        [SerializeField]
        public List<string> mCsvExtensionNames = new List<string>()
        {
            ".csv"
        };

        [SerializeField]
        public List<CsvSpreadSheetId> mSpreadSheetIDs = new List<CsvSpreadSheetId>();

        static public string CsvSpreadSheetFileDirectory;   // related to <path to project folder>/Assets 
        static public string CsvSourceCodeFileDirectory;    // related to <path to project folder>/Assets 
        static public string CsvBinDataDirectory      ;     // realted to <path to project folder>/Assets
        static public string CsvDataClassPostfixName  ;
        static public string CsvDataClassPrefixName   ;
        static public string CsvDataStructPostfixName ;
        static public string CsvDataStructPrefixName  ;
        static public string CsvManagerFileName       = @"JumpCSV/Code/CsvManager.cs";           // <path to project folder>/Assets
        static public string JumpCsvConfigAssetFile   = @"JumpCSV/Editor/JumpCsvConfig.asset";         // <path to project folder>/Assets
        static public string Version                  = "0.0.1";

        static public List<string> ExcludeCsvFiles          = new List<string>();
        static public List<string> CsvExtensionNames        = new List<string>();
        static public List<CsvSpreadSheetId> SpreadSheetIDs = new List<CsvSpreadSheetId>();


        static public JumpCsvConfig CreateAsset() {
            JumpCsvConfig config = ScriptableObject.CreateInstance(typeof(JumpCsvConfig)) as JumpCsvConfig;
            AssetDatabase.CreateAsset(config, "Assets/" + JumpCsvConfig.JumpCsvConfigAssetFile);
            return config;
        }

        static public JumpCsvConfig GetAsset() {
            JumpCsvConfig config = AssetDatabase.LoadAssetAtPath("Assets/" + JumpCsvConfigAssetFile, typeof(JumpCsvConfig)) as JumpCsvConfig;
            return config;            
        }

        void OnEnable() {
            UpdateValue();
        }

        static public void UpdateValue() {
            JumpCsvConfig config = AssetDatabase.LoadAssetAtPath("Assets/" + JumpCsvConfigAssetFile, typeof(JumpCsvConfig)) as JumpCsvConfig;
            if(config != null) {
                CsvSpreadSheetFileDirectory  = config.mCsvSpreadSheetFileDirectory;
                CsvSourceCodeFileDirectory   = config.mCsvSourceCodeFileDirectory;
                CsvBinDataDirectory          = config.mCsvBinDataDirectory;
                CsvDataClassPostfixName      = config.mCsvDataClassPostfixName;
                CsvDataClassPrefixName       = config.mCsvDataClassPrefixName;
                CsvDataStructPostfixName     = config.mCsvDataStructPostfixName;  
                CsvDataStructPrefixName      = config.mCsvDataStructPrefixName; 
                ExcludeCsvFiles              = config.mExcludeCsvFiles;
                CsvExtensionNames            = config.mCsvExtensionNames;    
                SpreadSheetIDs               = config.mSpreadSheetIDs;                           
            }
            else {  // if not find jump csv assets, set as default value
                CsvSpreadSheetFileDirectory  = @"";
                CsvSourceCodeFileDirectory   = @"JumpCSV/Class";
                CsvBinDataDirectory          = @"Resources/CsvBin";
                CsvDataClassPostfixName      = @"CsvData";
                CsvDataClassPrefixName       = @"";
                CsvDataStructPostfixName     = @"Record";
                CsvDataStructPrefixName      = @"";
                ExcludeCsvFiles              = new List<string>();
                CsvExtensionNames            = new List<string>(){".csv"};      
                //                          
            }
        }
    }
}
