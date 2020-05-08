using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using JumpCSV;

public class JumpCsvEditor : EditorWindow {
    // Add menu named "My Window" to the Window menu
    static JumpCsvEditor CurrentWindow;
    // [MenuItem ("JumpCSV/Build")]
    // static void BuildCsv () {
    //     //EditorUtility.DisplayProgressBar("正在编译", "", 0.5f);
    //     var sw = System.Diagnostics.Stopwatch.StartNew();
    //     BuildLocalization();
    //     JumpCsvCodeGenerator.CreateAllCsvClassSourceFiles("Build/CSV/Common", "Build/CSV/Common");
    //     Debug.Log("Build Csv Complete: " + sw.Elapsed.TotalMilliseconds.ToString() + "ms");
    // }

    // [MenuItem ("JumpCSV/Build", true)]
    // static bool CheckBuildCsv() {
    //     return !EditorApplication.isCompiling && JumpCsvEditorHelper.ContainsJumpCsvAssetsFiles();
    // }

    //[MenuItem ("JumpCSV/BuildLocalization")]

    [MenuItem ("JumpCSV/Clear")]
    static void ClearCsv() {
        JumpCsvEditorHelper.CleanAllFiles();
        AssetDatabase.Refresh();
    }

    [MenuItem ("JumpCSV/Clear", true)]
    static bool CheckClearCsv() {
        return JumpCsvEditorHelper.ContainsJumpCsvAssetsFiles();
    }

    public enum EBuildStep {
        None,
        CreateSourceFile,
        CreateBinaryFile,
    }

    EBuildStep step;

    private bool CheckIsBuilding() {
        return EditorApplication.isCompiling || step != EBuildStep.None;
    }


    public string    CsvSpreadSheetFileDirectory          ;
    public string    CsvSourceCodeFileDirectory           ;

    static bool IsNeedRebuild() {
        if(JumpCsvEditorHelper.GetAllLoseCsvCode().Length > 0) {
            return true;
        }
        if(JumpCsvEditorHelper.GetAllLoseCsvData().Length > 0) {
            return true;
        }
        if(JumpCsvEditorHelper.GetAllExpiredCsvFile().Length > 0) {
            return true;
        }
        return false;
    }

    void OnEnable() {
        CsvSpreadSheetFileDirectory = JumpCsvConfig.CsvSpreadSheetFileDirectory;
        CsvSourceCodeFileDirectory  = JumpCsvConfig.CsvSourceCodeFileDirectory;
    }

    void OnGUI () {

        bool isBuilding = CheckIsBuilding();

        if(isBuilding) {
            if(step == EBuildStep.CreateSourceFile | step == EBuildStep.CreateBinaryFile) {
                EditorUtility.DisplayProgressBar("Building...", "Do not close windows... ", 0.5f);
                GUILayout.Label("Waiting for building complete...");
            }
            if(step == EBuildStep.None) {
                EditorUtility.DisplayProgressBar("Building...", "Do not close windows... ", 0.9f);            
                GUILayout.Label("Waiting for cleaning complete...");
            }
        }
        else {
            if(GUILayout.Button("Build Csv Class")) {
                JumpCsvCodeGenerator.CreateAllCsvClassSourceFiles("Build/CSV/Common", "Build/CSV/Common");                
            }

            if(!JumpCsvEditorHelper.ContainsJumpCsvAssetsFiles()) {
                GUILayout.Label("Please setup settings before build csv files");
            }
            else if(IsNeedRebuild()) {
                if(GUILayout.Button("Build")) {
                    if(EditorApplication.isCompiling) {
                        return;
                    }
                    if(step != EBuildStep.None) {
                        return;
                    }
                    try {
                        JumpCsvCodeGenerator.CreateAllCsvClassSourceFiles("Build/CSV/Common", "Build/CSV/Common");
                        step = EBuildStep.CreateSourceFile;
                        AssetDatabase.Refresh();
                    } catch(Exception e) {
                        Debug.LogError( e.ToString());               
                        step = EBuildStep.None;
                    }
                }
            }
            else {
                GUILayout.Label("No files need to build");
            }
        }

    }

    void OnDisable() {
        EditorUtility.ClearProgressBar();
    }

    void Update() {
        if(step == EBuildStep.CreateBinaryFile && !EditorApplication.isCompiling) {
            step = EBuildStep.None;
            EditorUtility.ClearProgressBar();
        }
        if(step == EBuildStep.CreateSourceFile && !EditorApplication.isCompiling) {
            try {
                JumpCsvCodeGenerator.CreateAllCsvBinaryFiles();
                step = EBuildStep.CreateBinaryFile;
                AssetDatabase.Refresh();                
            } catch (Exception) {
                Debug.LogError("Generate Binary Faild");
                EditorUtility.ClearProgressBar();
                step = EBuildStep.None;
            }
        }
    }

}
