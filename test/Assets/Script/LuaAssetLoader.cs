using UnityEngine;

public class LuaAssetLoader : UMonoBehaviour
{
    public GameObject LoadPrefab(string resName)
    {
        if (string.IsNullOrEmpty(resName))
            return null;
#if !TEST
        return Resources.Load<GameObject>(resName);
#else
        AssetBundle ab = AssetBundle.LoadFromFile(Game.dataPath+resName+".unity3d");
        if (ab == null)
            return null;
        return ab.LoadAsset<GameObject>(resName);
#endif
    }

#if !TEST
    public ResourceRequest LoadPrefabAsync(string resName)
    {
        if (string.IsNullOrEmpty(resName))
            return null;
        return Resources.LoadAsync(resName);
    }
#else
    public AssetBundleCreateRequest LoadPrefabAsync(string resName)
    {
        if (string.IsNullOrEmpty(resName))
            return null;
        return AssetBundle.LoadFromFileAsync(Game.dataPath+resName+".unity3d");
    }
#endif
}