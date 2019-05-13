using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections.Generic;
using System.Reflection;

namespace JumpCSV {
    public static class JumpCsvEditorHelper  {
        public static string[] ListAllCsvFilesInCsvFolder() {
            string folder = JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvSpreadSheetFileDirectory );
            
            // verify csv folder
            if(!Directory.Exists(folder)) {
                string errorStr = string.Format("CSV file folder path {} is not existed, please check CSV Folder path is vaild", folder);
                Debug.LogError(errorStr);
                throw new Exception(errorStr);
            }

            List<string> csvFiles = new List<string>();
            SearchCsvFiles(folder, ref csvFiles);

            // check duplicate file name
            for(int i = 0; i < csvFiles.Count; i++) {
                for(int j = i+1; j < csvFiles.Count; j++) {
                    if(GetCsvDataClassName( csvFiles[i]  ).ToLower() == GetCsvDataClassName(csvFiles[j]).ToLower()) {
                        string errorStr = string.Format("There are duplicate file names in CSV file folder {0} AND {1}", csvFiles[i], csvFiles[j]);
                        throw new Exception(errorStr);
                    }
                }                
            }
            return csvFiles.ToArray();
        }

        static void SearchCsvFiles(string path, ref List<string> result) {
            // search all files in path
            foreach(string f in Directory.GetFiles(path)) {
                if(CheckCsvFileName(f) == true )result.Add(f);
            }

            // search all subdirectories in path
            foreach (string d in Directory.GetDirectories(path)) {
                SearchCsvFiles(d, ref result);
            }
        }

        static public bool ContainsJumpCsvAssetsFiles() {
            var jumpCsvAsset =  AssetDatabase.LoadAssetAtPath("Assets/" + JumpCsvConfig.JumpCsvConfigAssetFile, typeof(JumpCsvConfig)) as JumpCsvConfig;
            return jumpCsvAsset != null;
        }


        static bool CheckCsvFileName(string fileName) {
            if(!File.Exists(fileName)) {
                return false;
            }

            // check fileName extension name in JumpCsvConfig.CsvExtensionName
            if(!JumpCsvConfig.CsvExtensionNames.Contains(Path.GetExtension(fileName).ToLower())) {
                return false;
            }

            // check fileName is in JumpCsvConfig.ExcludeCsvFile list;
            int find = JumpCsvConfig.ExcludeCsvFiles.FindIndex((x)=>{ return (x.ToLower() == Path.GetFileName(fileName).ToLower());});
            if( find > -1) {
                return false;
            }
            return true;
        }

        public static void CleanAllFiles() {
            // remove all csv data class generated in csv source code folder
            string directory = JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvSourceCodeFileDirectory);
            FileUtil.DeleteFileOrDirectory(directory);

            // remove all binary data generated in csv binary data folder
            directory = JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvBinDataDirectory);
            FileUtil.DeleteFileOrDirectory(directory);

            // reset CsvManager.cs file
            JumpCsvCodeGenerator.CreateEmptyCsvManagerSourceFile();
        }

        public static string  GetCsvDataClassName(string fileName) {
            return JumpCsvConfig.CsvDataClassPrefixName + Path.GetFileName(fileName).Split(new char[]{'.'})[0] + JumpCsvConfig.CsvDataClassPostfixName;
        }

        public static string GetCsvDataStructName(string fileName) {
            return JumpCsvConfig.CsvDataStructPrefixName + Path.GetFileName(fileName).Split(new char[]{'.'})[0] + JumpCsvConfig.CsvDataStructPostfixName;
        }

        public static string GetCsvDataBinaryFileName(string fileName) {
            return GetCsvDataClassName(fileName) + ".bytes";
        }

        public static bool CheckCsvSpreadSheetFileDirectory(string path) {
            if(!Directory.Exists(path)) {
                return false;
            }
            return IsContainParentPath(path, Application.dataPath);
        }

        public static string[] GetAllLoseCsvCode() {
            List<string> csvCodeFiles = new List<string>();
            foreach(string csvFile in ListAllCsvFilesInCsvFolder()) {
                string csvCodeFileName = JumpCsvEditorHelper.PathCombine( JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvSourceCodeFileDirectory), JumpCsvEditorHelper.GetCsvDataClassName(csvFile) + ".cs") ;
                if(!File.Exists(csvCodeFileName)) {
                    csvCodeFiles.Add(csvCodeFileName);
                }
            }
            return csvCodeFiles.ToArray();
        }

        public static string[] GetAllLoseCsvData() {
            List<string> csvDataFiles = new List<string>();
            foreach(string csvFile in ListAllCsvFilesInCsvFolder()) {
                string csvDataFileName = JumpCsvEditorHelper.PathCombine(JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvBinDataDirectory), JumpCsvEditorHelper.GetCsvDataBinaryFileName(csvFile));
                if(!File.Exists(csvDataFileName)) {
                    csvDataFiles.Add(csvDataFileName);
                }
            }
            return csvDataFiles.ToArray();
        }

        public static string[] GetAllExpiredCsvFile() {
            List<string> expiredCsvFiles = new List<string>();
            foreach(string csvFile in ListAllCsvFilesInCsvFolder()) {
                string csvCodeFileName = JumpCsvEditorHelper.PathCombine(JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvSourceCodeFileDirectory) , JumpCsvEditorHelper.GetCsvDataClassName(csvFile) + ".cs");
                //string csvDataFileName = JumpCsvEditorHelper.PathCombine(JumpCsvEditorHelper.PathCombine(Application.dataPath, JumpCsvConfig.CsvBinDataDirectory) , JumpCsvEditorHelper.GetCsvDataBinaryFileName(csvFile));
                if(!File.Exists(csvCodeFileName)) {
                    expiredCsvFiles.Add(csvFile);
                }
                else { // check content is latest
                    string className = JumpCsvEditorHelper.GetCsvDataClassName(csvFile);
                    Type csvCodeType = CsvHelper.GetType("JumpCSV."+className);
                    int hashCode     = (int)(csvCodeType.GetField("mHashCode").GetValue(null));

                    string resourcePath = JumpCsvEditorHelper.PathCombine(Application.dataPath, "Build/CSV/Common");
                    string path = JumpCsvEditorHelper.MakeRelativePath(resourcePath, csvFile); 
                    CsvSpreadSheet spreadSheet = new CsvSpreadSheet(path.Replace(".csv",""), true);                        //string content = reader.ReadToEnd();
                    //csvReader.ReadFromString(content);
                    int CheckSum = spreadSheet.GetHashCode();
                    if(CheckSum != hashCode) {
                        expiredCsvFiles.Add(csvFile);
                    }
                }
            }
            return expiredCsvFiles.ToArray();
        }

        public static bool IsContainParentPath(string path, string parentPath) {
            DirectoryInfo parent = Directory.CreateDirectory(path);
            while(parent !=  null) {
                if( parentPath == parent.FullName.Replace("\\", "/")) {
                    return true;
                }
                parent = Directory.GetParent(parent.FullName);
            }            
            return false;
        }

        public static bool CheckCsvSourceCodeFileDirectory(string path) {
            if(!Directory.Exists(path)) {
                return false;
            }
            return IsContainParentPath(path, Application.dataPath);
        }

        public static bool CheckCsvBinDataDirectory(string path) {
            if(!Directory.Exists(path)) {
                return false;
            }
            return IsContainParentPath(path, JumpCsvEditorHelper.PathCombine(Application.dataPath, "Resources"));
        }

        // replace all backslash to forward slash, backslash is not recognised in Unity
        public static string PathCombine(string path1, string path2) {
            return Path.Combine(path1, path2).Replace("\\", "/");
        }

        /// <summary>
        /// Creates a relative path from one file
        /// or folder to another.
        /// </summary>
        /// <param name="fromDirectory">
        /// Contains the directory that defines the
        /// start of the relative path.
        /// </param>
        /// <param name="toPath">
        /// Contains the path that defines the
        /// endpoint of the relative path.
        /// </param>
        /// <returns>
        /// The relative path from the start
        /// directory to the end path.
        /// </returns>
        /// <exception cref="ArgumentNullException"></exception>
        public static string MakeRelativePath(string fromDirectory, string toPath)
        {
              if (fromDirectory == null)
                throw new ArgumentNullException("fromDirectory");

              if (toPath == null)
                throw new ArgumentNullException("toPath");

              bool isRooted = (Path.IsPathRooted(fromDirectory) && Path.IsPathRooted(toPath));

              if (isRooted)
              {
                bool isDifferentRoot = (string.Compare(Path.GetPathRoot(fromDirectory), Path.GetPathRoot(toPath), true) != 0);

                if (isDifferentRoot)
                  return toPath;
              }

              List<string> relativePath = new List<string>();
              string[] fromDirectories = fromDirectory.Split(new char[]{'/'});

              string[] toDirectories = toPath.Split(new char[]{'/'});

              int length = Math.Min(fromDirectories.Length, toDirectories.Length);

              int lastCommonRoot = -1;

              // find common root
              for (int x = 0; x < length; x++)
              {
                if (string.Compare(fromDirectories[x], toDirectories[x], true) != 0)
                  break;

                lastCommonRoot = x;
              }

              if (lastCommonRoot == -1)
                return toPath;

              // add relative folders in from path
              for (int x = lastCommonRoot + 1; x < fromDirectories.Length; x++)
              {
                if (fromDirectories[x].Length > 0)
                  relativePath.Add("..");
              }

              // add to folders to path
              for (int x = lastCommonRoot + 1; x < toDirectories.Length; x++)
              {
                relativePath.Add(toDirectories[x]);
              }

              // create relative path
              string[] relativeParts = new string[relativePath.Count];
              relativePath.CopyTo(relativeParts, 0);

              string newPath = string.Join("/", relativeParts);

              return newPath;
            }        
    }
}
