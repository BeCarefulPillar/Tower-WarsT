using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using System.IO;

public class Asset
{
    public string name;
    public AssetBundle ab;
    public HashSet<GameObject> refs = new HashSet<GameObject>();

    public const string dir = "c:/test/";
    public const string ext = ".unity3d";

    public Asset(string _name)
    {
        name = _name;
    }

    public void Load()
    {
        string path = dir + name + ext;
        if (File.Exists(path))
            ab = AssetBundle.LoadFromFile(path);
    }

    public void Dispose()
    {
        if (refs.Count != 0)
        {
            string str = string.Empty;
            int i = 1;
            foreach (GameObject go in refs)
            {
                if (go)
                {
                    str += i++ == refs.Count ? go.name : go.name + ",";
                }
            }
            refs.Clear();
            Debug.LogWarningFormat("资源{0}正在被[{1}]使用",name, str);
        }
        if (ab)
        {
            ab.Unload(true);
            ab= null;
        }
    }

    public void AddRef(GameObject go)
    {
        if (go != null && !refs.Contains(go))
            refs.Add(go);
    }

    public void RemoveRef(GameObject go)
    {
        if (go != null && refs.Contains(go))
            refs.Remove(go);
    }

    public T GetAsset<T>(string name) where T : Object
    {
        if (!ab)
            return null;
        return ab.LoadAsset<T>(name);
    }

    public GameObject pb { get { return GetAsset<GameObject>(name); } }

    public Texture tex { get { return GetAsset<Texture>(name); } }

    public Material mat { get { return GetAsset<Material>(name); } }

    public AudioClip audio { get { return GetAsset<AudioClip>(name); } }

    public TextAsset text { get { return GetAsset<TextAsset>(name); } }
}