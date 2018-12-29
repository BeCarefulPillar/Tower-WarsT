using UnityEngine;
using Type = System.Type;

//L.BeginClass(typeof(UnityEngine.GameObject), typeof(UnityEngine.MonoBehaviour));

public static class GameObjectExtend
{
    public static Component AddCmp(this GameObject go, Type componentType)
    {
        return go.AddComponent(componentType);
    }

    public static Component GetCmp(this GameObject go, Type componentType)
    {
        return go.GetComponent(componentType);
    }

    public static GameObject AddChild(this GameObject parent, GameObject prefab, string name = null, bool init = true)
    {
        if (prefab == null)
            return null;
        GameObject go = Object.Instantiate(prefab);
        if (!string.IsNullOrEmpty(name) && go.name != name)
            go.name = name;
        if (go.layer != parent.layer && go.GetComponent<UIPanel>() == null)
            NGUITools.SetLayer(go, parent.layer);
        Transform t = go.transform;
        if (init)
        {
            t.SetParent(parent.transform);
            t.localPosition = Vector3.zero;
            t.localRotation = Quaternion.identity;
            t.localScale = Vector3.one;
        }
        else
        {
            t.SetParent(parent.transform, false);
        }
        return go;
    }

    public static Component Child(this GameObject go, string name, Type componentType = null)
    {
        if (componentType == null)
            return go.transform.FindChild(name);
        return go.transform.FindChild(name).GetComponent(componentType);
    }

    public static Component Child(this GameObject go, int index, Type componentType = null)
    {
        if (componentType == null)
            return go.transform.GetChild(index);
        return go.transform.GetChild(index).GetComponent(componentType);
    }
}