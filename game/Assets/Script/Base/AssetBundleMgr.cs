//// Copyright (C) 2016 Joywinds Inc.

//using UnityEngine;
//using System;
//using System.IO;
//using System.Collections;
//using Logger;

//public class AssetBundleMgr {
//    public static readonly string FILENAME = "PATCH";
//    public static readonly string VERSION_FILE = "Version";

//    public static bool mInited = false;
//    public static AssetBundle mBundle = null;

//    public static UnityEngine.Object Load(string path, string fileExtension) {
//        Log.Assert(mInited, "AssetBundleMgr was not inited");
//        if (mBundle != null) {
//            return mBundle.LoadAsset(GetFullPath(path, fileExtension));
//        }
//        return null;
//    }

//    public static T Load<T>(string path, string fileExtension) where T : UnityEngine.Object {
//        Log.Assert(mInited, "AssetBundleMgr was not inited");
//        if (mBundle != null) {
//            return mBundle.LoadAsset<T>(GetFullPath(path, fileExtension));
//        }
//        return default(T);
//    }

//    public static bool ContainsFile(string path, string fileExtension) {
//        Log.Assert(mInited, "AssetBundleMgr was not inited");
//        if (mBundle != null) {
//            return mBundle.Contains(GetFullPath(path, fileExtension));
//        }
//        return false;
//    }

//    public static void Init() {
//        mInited = true;
//        Log.Info("Load assetbundle from {0}", GetFileName());
//        try {
//            if (mBundle != null) {
//                mBundle.Unload(true);
//            }
//            var bytes = File.ReadAllBytes(GetFileName());
//            mBundle = AssetBundle.LoadFromMemory(bytes);
//            if (mBundle == null) {
//                Log.Error("Invalid assetbundle: {0}", GetFileName());
//            }
//        } catch (FileNotFoundException) {
//            // Ingore
//        } catch (Exception e) {
//            Log.Error("Cannot load assetbundle {0}: ", e.Message);
//        }
//    }

//    public static bool CheckExpire(string serverVersion) {
//        if (mBundle == null) {
//            return false;
//        }
//        try {
//            var localVersion = GetLocalVersion();
//            var cachedVersion = GetCachedVersion();
//            if (serverVersion != cachedVersion || cachedVersion.CompareTo(localVersion) <= 0) {
//                Log.Info("Delete expired assetbundle");
//                mBundle.Unload(true);
//                mBundle = null;
//                DeleteCache();
//                return true;
//            }
//        } catch (Exception e) {
//            Log.Error("Delete expired assetbundle failed: {0}", e.Message);
//        }
//        return false;
//    }

//    public enum SaveError {
//        NONE,
//        CRC_FAIL,
//        SAVE_FAIL
//    }

//    public static SaveError Save(byte[] bytes, uint crc) {
//        if (mBundle != null) {
//            mBundle.Unload(true);
//        }
//        mBundle = AssetBundle.LoadFromMemory(bytes, crc);
//        if (mBundle == null) {
//            return SaveError.CRC_FAIL;
//        }
//        try {
//            File.WriteAllBytes(GetFileName(), bytes);
//            Log.Info("Save assetbundle at {0}", GetFileName());
//        } catch (Exception) {
//            return SaveError.SAVE_FAIL;
//        }
//        return SaveError.NONE;
//    }

//    public static string GetCachedVersion() {
//        if (mBundle != null) {
//            var version = mBundle.LoadAsset<TextAsset>(VERSION_FILE);
//            if (version == null) {
//                Log.Error("assetbundle no version file: {0}", VERSION_FILE);
//            } else {
//                return version.text;
//            }
//        }
//        return string.Empty;
//    }

//    public static string GetLocalVersion() {
//        var version = Resources.Load(VERSION_FILE, typeof(TextAsset)) as TextAsset;
//        if (version == null) {
//            Log.Error("Cannot load {0}", VERSION_FILE);
//            return string.Empty;
//        }
//        return version.text;
//    }

//    public static void DeleteCache() {
//        File.Delete(GetFileName());
//    }

//    private static string GetFileName() {
//        return Path.Combine(Application.persistentDataPath, FILENAME);
//    }

//    private static string GetFullPath(string path, string typeName) {
//        return string.Format("Assets/Resources/{0}.{1}", path, typeName);
//    }
//    /*
//        class Dir {
//            private Dictionary<string,Dir> mSubDirs;
//            private HashSet<string> mFiles;

//            public string Name { get; private set; }

//            public Dir Parent { get; private set; }

//            public void AddDir(Dir d) {

//            }

//            public void AddFile()

//            public Dir GetSubDir(string name) {
//                if (mSubDirs.ContainsKey(name)) {
//                    return mSubDirs[name];
//                }
//                return null;
//            }

//            public string FullPath(string name, bool prefix) {
//                string fullname = string.Empty;
//                if (prefix) {
//                    foreach (var file in mFiles) {
//                        if (file.IndexOf(name) == 0) {
//                            fullname = file;
//                            break;
//                        }
//                    }
//                } else {
//                    if (mFiles.Contains(name)) {
//                        fullname = name;
//                    }
//                }
//                if (string.IsNullOrEmpty(fullname)) {
//                    var fullpath = new List<string>();
//                    fullpath.Add(fullname);
//                    var p = Parent;
//                    while (p != null) {
//                        fullpath.Add(p.Name);
//                        p = p.Parent;
//                    }
//                    fullpath.Reverse();
//                    return string.Concat(fullpath, "/");
//                }
//                return string.Empty;
//            }
//        }
//    */
//}
