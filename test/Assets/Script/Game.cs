using UnityEngine.SceneManagement;
using System.Collections.Generic;
using UnityEngine;
using System.Collections;
using System.IO;
using System;
using System.Security.Cryptography;
using System.Text;

public class Game : UMonoBehaviour
{
    public Dictionary<string, UMonoBehaviour> mIns = new Dictionary<string, UMonoBehaviour>();
    private static Game mInstance;

    public static string dataPath; //数据目录
    public static string appContentPath; //游戏包资源目录
    public static string webUrl; //服务器资源地址

    private void Awake()
    {
        if(mInstance && mInstance!=this)
        {
            Debug.LogError("error");
            return;
        }

        mInstance = this;

        DontDestroyOnLoad(cachedTransform.root);

        mIns.Add("AssetManager", cachedGameObject.GetComponent<AssetManager>() ?? cachedGameObject.AddComponent<AssetManager>());
        mIns.Add("LuaManager", cachedGameObject.GetComponent<LuaManager>() ?? cachedGameObject.AddComponent<LuaManager>());
        mIns.Add("USceneManager", cachedGameObject.GetComponent<USceneManager>() ?? cachedGameObject.AddComponent<USceneManager>());

        string t = string.Empty;
        foreach(KeyValuePair<string,UMonoBehaviour> e in mIns)
        {
            t += e.Key + "\n";
        }
        Debug.Log(t);


        //win
        dataPath = "c:/test/";
        appContentPath = Application.dataPath+ "/StreamingAssets/";
        webUrl = "http://192.168.1.91:8080/root/";


        CheckExtractResource();


        //SceneManager.LoadScene("test");
    }

    private void CheckExtractResource()
    {
        bool isExists = Directory.Exists(dataPath) &&
            Directory.Exists(dataPath + "lua/") &&
            File.Exists(dataPath + "files.txt");


        //string localPath = appContentPath + "files.txt";
        //bool localFlag = true;
        //if(File.Exists(localPath))
        //{
        //    string[] files = File.ReadAllLines(localPath);
        //    string[] ps;
        //    foreach(string file in files)
        //    {
        //        if(!string.IsNullOrEmpty(file))
        //        {
        //            ps = file.Split('|');
        //        }
        //    }
        //}
        //else
        //{
        //    localFlag = false;
        //}
        //if(!localFlag)
        //{
        //    Debug.LogError("error");
        //    return;
        //}

        if (isExists)
        {
            if (AppConst.UpdateMode)
                StartCoroutine(OnUpdateResource());
            else
            {
                LuaManager.Ins.InitStart();
                SceneManager.LoadScene("test");
            }
        }
        else
            StartCoroutine(OnExtractResource());
    }

    private IEnumerator OnUpdateResource()
    {
        string random = DateTime.Now.ToString("yyyymmddhhmmss");
        string listUrl = string.Format("{0}{1}?v={2}", webUrl, "files.txt", random);

        Debug.Log("LoadUpdate---->>>" + listUrl);

        WWW www = new WWW(listUrl);
        yield return www;
        if(www.error!=null)
        {
            Debug.Log("更新失败!>" + listUrl);
            yield break;
        }

        if (!Directory.Exists(dataPath))
            Directory.CreateDirectory(dataPath);

        File.WriteAllBytes(dataPath + "files.txt", www.bytes);
        www.Dispose();

        string[] files = File.ReadAllLines(dataPath + "files.txt");
        string[] fs;
        string fileUrl;
        string remoteMd5;
        string localMd5;
        string localfile;
        string path;
        foreach (string file in files)
        {
            if (string.IsNullOrEmpty(file))
                continue;
            fs = file.Split('|');
            localfile = dataPath + fs[0];
            path = Path.GetDirectoryName(localfile);
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);
            fileUrl = string.Format("{0}{1}?v={2}", webUrl, fs[0], random);
            if(File.Exists(localfile))
            {
                remoteMd5 = fs[1];
                localMd5 = md5file(localfile);
                if(remoteMd5==localMd5)
                    continue;
                else
                    File.Delete(localfile);
            }
            Debug.Log("downloading>>" + fileUrl);
            www = new WWW(fileUrl);
            yield return www;
            if(www.error!=null)
            {
                Debug.Log("更新失败!>" + fileUrl);
                yield break;
            }
            File.WriteAllBytes(localfile, www.bytes);
            www.Dispose();
        }

        yield return new WaitForEndOfFrame();

        Debug.Log("更新完成");


        LuaManager.Ins.InitStart();



        //SceneManager.LoadScene("test");
        USceneManager.Ins.LoadScene("test");
    }

    public static string md5file(string file)
    {
        string s = string.Empty;
        using (FileStream fs = new FileStream(file, FileMode.Open))
        {
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] bs = md5.ComputeHash(fs);
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < bs.Length; ++i)
                sb.Append(bs[i].ToString("x2"));
            s = sb.ToString();
        }
        return s;
    }

    private IEnumerator OnExtractResource()
    {
        if (Directory.Exists(dataPath))
            Directory.Delete(dataPath, true);
        Directory.CreateDirectory(dataPath);

        string infile = appContentPath + "files.txt";
        string outfile = dataPath + "files.txt";

        if (File.Exists(outfile))
            File.Delete(outfile);

        Debug.Log("正在解包文件:>files.txt");

        if(Application.platform==RuntimePlatform.Android)
        {
        }
        else
        {
            File.Copy(infile, outfile, true);
        }

        yield return new WaitForEndOfFrame();

        string[] files = File.ReadAllLines(outfile);
        string[] fs;
        string dir;
        foreach (string file in files)
        {
            fs = file.Split('|');
            infile = appContentPath + fs[0];
            outfile = dataPath + fs[0];
            Debug.Log("正在解包文件:>" + infile);
            dir = Path.GetDirectoryName(outfile);
            if (!Directory.Exists(dir))
                Directory.CreateDirectory(dir);

            if(Application.platform==RuntimePlatform.Android)
            {
            }
            else
            {
                File.Copy(infile, outfile, true);
            }
            yield return new WaitForEndOfFrame();
        }
        Debug.Log("解包完成!!!");

        yield return new WaitForSeconds(0.1f);

        StartCoroutine(OnUpdateResource());
    }

    private void OnDestroy()
    {
        if(LuaManager.Ins)
        {
            LuaManager.Ins.Close();
        }
    }

    public static Game Ins
    {
        get
        {
            return mInstance;
        }
    }
}