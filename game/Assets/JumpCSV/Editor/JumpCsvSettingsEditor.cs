using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections.Generic;

namespace JumpCSV {
    public class JumpCsvSettingsEditor : EditorWindow {
        public string CsvSpreadSheetFileDirectory;
        public string CsvSourceCodeFileDirectory;
        public string CsvBinDataDirectory      ;    // related to /Assets/Resources/
        public string CsvDataClassPostfixName  = "" ;
        public string CsvDataClassPrefixName   = "" ;
        public string CsvDataStructPostfixName = "" ;
        public string CsvDataStructPrefixName  = "" ;
        public string CsvExtensionNames        = "" ;
        public string ExcludeCsvFiles          = "" ;

        private int spaceHeight  = 10;
        private int buttonWidth  = 150;
        private int buttonHeight = 35;

        public Vector2 scrollPos;
        [MenuItem ("JumpCSV/Settings...")]
        static public void OpenWindow() {
            EditorWindow.GetWindow (typeof(JumpCsvSettingsEditor));
        }

        public void OnGUI() {
            scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
            GUILayout.BeginVertical();
                GUILayout.BeginHorizontal();
                    if(GUILayout.Button("Change CSV Folder",  GUILayout.Width(buttonWidth) , GUILayout.Height(buttonHeight))) {
                        OpenFolderPanelAndSetPath("Choose Target Folder", CsvSpreadSheetFileDirectory, ref CsvSpreadSheetFileDirectory);
                    }
                    // hint message 
                    EditorGUILayout.HelpBox("JumpCSV will read all csv files in this folder.", MessageType.Info);
                GUILayout.EndHorizontal();

                if( !JumpCsvEditorHelper.CheckCsvSpreadSheetFileDirectory(CsvSpreadSheetFileDirectory)) {
                    EditorGUILayout.HelpBox(CsvSpreadSheetFileDirectory + " IS INVALID CSV FILE PATH, CSV FILE PATH MUST UNDER Assets/Resources FOLDER", MessageType.Error);
                }
                else {
                    EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.PrefixLabel("CSV Folder: ");
                        GUILayout.Label(CsvSpreadSheetFileDirectory);                
                    EditorGUILayout.EndHorizontal();
                }
                GUILayout.Space(spaceHeight);
            GUILayout.EndVertical();


            // GUILayout.BeginVertical();
            //     GUILayout.BeginHorizontal();
            //         if(GUILayout.Button("Change Code Folder",  GUILayout.Width(buttonWidth), GUILayout.Height(buttonHeight) )) {
            //             OpenFolderPanelAndSetPath("Choose Target Folder", CsvSourceCodeFileDirectory, ref CsvSourceCodeFileDirectory);                
            //         }
            //         EditorGUILayout.HelpBox("All C# source code which read csv file will be created in this folder.", MessageType.Info);
            //     GUILayout.EndHorizontal();

            //     if(!JumpCsvEditorHelper.CheckCsvSourceCodeFileDirectory(CsvSourceCodeFileDirectory)) {
            //         EditorGUILayout.HelpBox(CsvSourceCodeFileDirectory + " IS INVALID SOURCE CODE TARGET PATH, MAKE SURE TARGET PATH IS UNDER ./Assets", MessageType.Error);
            //     }
            //     else {
            //         EditorGUILayout.BeginHorizontal();
            //             EditorGUILayout.PrefixLabel("CSV Code Folder:");
            //             GUILayout.Label(CsvSourceCodeFileDirectory);
            //         EditorGUILayout.EndHorizontal();
            //     }
            //     GUILayout.Space(spaceHeight);
            // GUILayout.EndVertical();


            // GUILayout.BeginVertical();
            //     GUILayout.BeginHorizontal();
            //         if(GUILayout.Button("Change Bin Folder", GUILayout.Width(buttonWidth), GUILayout.Height(buttonHeight))) {
            //             OpenFolderPanelAndSetPath("Choose Target Folder", CsvBinDataDirectory, ref CsvBinDataDirectory);
            //         }
            //         EditorGUILayout.HelpBox("All csv binary files will be created in this folder. JumpCSV will load these at runtime, so the folder need under folder Resources", MessageType.Info);
            //     GUILayout.EndHorizontal();

            //     if(!JumpCsvEditorHelper.CheckCsvBinDataDirectory(CsvBinDataDirectory)) {
            //         EditorGUILayout.HelpBox(CsvBinDataDirectory + " IS INVALID BINARY DATA TARGET PATH, MAKE SURE TARGET PATH IS UNDER ./Assets/Resources", MessageType.Error);
            //     }
            //     else {
            //         EditorGUILayout.BeginHorizontal();
            //             EditorGUILayout.PrefixLabel("CSV Binary Folder:");
            //             GUILayout.Label(CsvBinDataDirectory);
            //         EditorGUILayout.EndHorizontal();
            //     }
            //     GUILayout.Space(spaceHeight);
            // GUILayout.EndVertical();


            // GUILayout.BeginHorizontal();
            //     GUILayout.BeginVertical(GUILayout.Width(buttonWidth));
            //         GUILayout.Label("Class Prefix Name", GUILayout.Width(buttonWidth));
            //         if(!string.IsNullOrEmpty(CsvDataClassPrefixName) && !CsvHelper.IsValidVariableName(CsvDataClassPrefixName)) {
            //             EditorGUILayout.HelpBox(CsvDataClassPrefixName + "IS NOT A VAILD NAME, MAKE SURE YOU NAME ONLY CONTAINS LETTER [a-zA-Z0-9_], AND NUMBER IS NOT THE FIRST LETTER", MessageType.Error);
            //         }
            //         CsvDataClassPrefixName = GUILayout.TextField(CsvDataClassPrefixName);
            //         GUILayout.Space(spaceHeight);
            //     GUILayout.EndVertical();

            //     GUILayout.BeginVertical( GUILayout.Width(buttonWidth));
            //         GUILayout.Label("Class Postfix Name", GUILayout.Width(buttonWidth));
            //         if(!string.IsNullOrEmpty(CsvDataClassPostfixName) && !CsvHelper.IsValidVariableName(CsvDataClassPostfixName)) {
            //             EditorGUILayout.HelpBox(CsvDataClassPostfixName + "IS NOT A VAILD NAME, MAKE SURE YOU NAME ONLY CONTAINS LETTER [a-zA-Z0-9_], AND NUMBER IS NOT THE FIRST LETTER", MessageType.Error);
            //         }
            //         CsvDataClassPostfixName = GUILayout.TextField(CsvDataClassPostfixName);
            //         GUILayout.Space(spaceHeight);
            //     GUILayout.EndVertical();
            //     EditorGUILayout.HelpBox("CSV read class name will be named by join prefix name, csv file name and postfix name.", MessageType.Info);

            // GUILayout.EndHorizontal();

            // GUILayout.BeginHorizontal();
            //     GUILayout.BeginVertical(GUILayout.Width(buttonWidth));
            //         GUILayout.Label("Record Prefix Name",GUILayout.Width(buttonWidth));  
            //         if(!string.IsNullOrEmpty(CsvDataStructPrefixName) && !CsvHelper.IsValidVariableName(CsvDataStructPrefixName)) {
            //             EditorGUILayout.HelpBox(CsvDataStructPrefixName + "IS NOT A VAILD NAME, MAKE SURE YOU NAME ONLY CONTAINS LETTER [a-zA-Z0-9_], AND NUMBER IS NOT THE FIRST LETTER", MessageType.Error);
            //         }
            //         CsvDataStructPrefixName = GUILayout.TextField(CsvDataStructPrefixName);
            //         GUILayout.Space(spaceHeight);
            //     GUILayout.EndHorizontal();

            //     GUILayout.BeginVertical(GUILayout.Width(buttonWidth));
            //         GUILayout.Label("Record Postfix Name",GUILayout.Width(buttonWidth));  
            //         if(!string.IsNullOrEmpty(CsvDataStructPostfixName) && !CsvHelper.IsValidVariableName(CsvDataStructPostfixName)) {
            //             EditorGUILayout.HelpBox(CsvDataStructPostfixName + "IS NOT A VAILD NAME, MAKE SURE YOU NAME ONLY CONTAINS LETTER [a-zA-Z0-9_], AND NUMBER IS NOT THE FIRST LETTER", MessageType.Error);
            //         }
            //         CsvDataStructPostfixName = GUILayout.TextField(CsvDataStructPostfixName);
            //         GUILayout.Space(spaceHeight);
            //     GUILayout.EndHorizontal();
            //     EditorGUILayout.HelpBox("CSV read class will be named by join prefix name, csv file name and postfix name.", MessageType.Info);                
            // GUILayout.EndHorizontal();

            // GUILayout.BeginHorizontal();
            // GUILayout.Label("CSV File Extentions",GUILayout.Width(buttonWidth));  
            // CsvExtensionNames = GUILayout.TextField(CsvExtensionNames);
            // GUILayout.EndHorizontal();

            // GUILayout.BeginHorizontal();
            // GUILayout.Label("Exclude CSV Files", GUILayout.Width(buttonWidth));  
            // ExcludeCsvFiles = GUILayout.TextField(ExcludeCsvFiles);
            // GUILayout.EndHorizontal();

            EditorGUILayout.EndScrollView();

            if(GUILayout.Button("Save", GUILayout.Height(buttonHeight))) {
                SaveSettingsValues();
            }

            // if(GUILayout.Button("Test List")) {
            //     CsvManager.Init();
            //     foreach(var t in CharactersData.mItemIdValue.Values) {
            //         Debug.Log(CharactersData.mData[CsvItemId.SILT]._VALUE); 
            //     }
            // }

            // if(GUILayout.Button("Test Miss Csv Code")) {
            //     foreach( var f in JumpCsvEditorHelper.GetAllLoseCsvCode()) {
            //         Debug.Log("Miss: " + f);
            //     }
            // }

            // if(GUILayout.Button("Test Miss Binary Data")) {
            //     foreach(var f in JumpCsvEditorHelper.GetAllLoseCsvData()) {
            //         Debug.Log("Miss: " + f);
            //     }
            // }

            // if(GUILayout.Button("Test Expreid Csv Files")) {
            //     foreach(var f in JumpCsvEditorHelper.GetAllExpiredCsvFile()) {
            //         Debug.Log("Expreid: " + f);
            //     }
            // }

            // if(GUILayout.Button("Test Relative Path")) {
            //     Debug.Log("From Path: " + Application.dataPath);
            //     Debug.Log("To Path:" + CsvSpreadSheetFileDirectory);
            //     Debug.Log("Relative: " + JumpCsvEditorHelper.MakeRelativePath(Application.dataPath, CsvSpreadSheetFileDirectory ));
            // }
        }

        private void OpenFolderPanelAndSetPath(string titleName, string defaultOpenPath, ref string result) {
            string temp = EditorUtility.OpenFolderPanel(titleName,  defaultOpenPath, "");
            if(!string.IsNullOrEmpty(temp)) { // cancel
                result = temp;
            }
        }

        private void OnEnable() {
            InitSettingsValues();
        }

        public void InitSettingsValues() {
            CsvSpreadSheetFileDirectory  =  JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvSpreadSheetFileDirectory);
            CsvSourceCodeFileDirectory   =  JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvSourceCodeFileDirectory);
            CsvBinDataDirectory          =  JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvBinDataDirectory);    
            CsvDataClassPrefixName       =  JumpCsvConfig.CsvDataClassPrefixName;
            CsvDataClassPostfixName      =  JumpCsvConfig.CsvDataClassPostfixName;
            CsvDataStructPostfixName     =  JumpCsvConfig.CsvDataStructPostfixName;
            CsvExtensionNames            =  string.Join(";",JumpCsvConfig.CsvExtensionNames.ToArray());
            ExcludeCsvFiles              =  string.Join(";",JumpCsvConfig.ExcludeCsvFiles.ToArray());
        }

        private void SaveSettingsValues() {
            if(!CheckAllSettingsValues()) {
                return;
            }
            JumpCsvConfig jCsvConfig = null;
            if(!JumpCsvEditorHelper.ContainsJumpCsvAssetsFiles()) { // if not found settings asset, create assets
                jCsvConfig = JumpCsvConfig.CreateAsset();
            }   
            else { // update value
                jCsvConfig = JumpCsvConfig.GetAsset();
            }
            jCsvConfig.mCsvSpreadSheetFileDirectory = JumpCsvEditorHelper.MakeRelativePath(Application.dataPath, CsvSpreadSheetFileDirectory);
            jCsvConfig.mCsvSourceCodeFileDirectory  = JumpCsvEditorHelper.MakeRelativePath(Application.dataPath, CsvSourceCodeFileDirectory);
            jCsvConfig.mCsvBinDataDirectory         = JumpCsvEditorHelper.MakeRelativePath(Application.dataPath, CsvBinDataDirectory);
            jCsvConfig.mCsvDataClassPostfixName     = CsvDataClassPostfixName;
            jCsvConfig.mCsvDataClassPrefixName      = CsvDataClassPrefixName;
            jCsvConfig.mCsvDataStructPostfixName    = CsvDataStructPostfixName;
            jCsvConfig.mCsvDataStructPrefixName     = CsvDataStructPrefixName;
            jCsvConfig.mExcludeCsvFiles             = new List<string>(ExcludeCsvFiles.Split(new char[]{';'}   , StringSplitOptions.RemoveEmptyEntries));
            jCsvConfig.mCsvExtensionNames           = new List<string>(CsvExtensionNames.Split(new char[]{';'} , StringSplitOptions.RemoveEmptyEntries));
            EditorUtility.SetDirty(jCsvConfig);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            AssetDatabase.ImportAsset("Assets/" + JumpCsvConfig.JumpCsvConfigAssetFile, ImportAssetOptions.ForceSynchronousImport);
            JumpCsvConfig.UpdateValue();
        }

        private bool CheckAllSettingsValues() {
            return true;
        }

    }    
}
