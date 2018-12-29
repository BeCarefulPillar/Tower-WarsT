using UnityEngine;
using System;

//L.BeginClass(typeof(UnityEngine.Component), typeof(UnityEngine.MonoBehaviour));

public static class ComponentExtend
{
    public static Component AddCmp(this Component c, Type componentType)
    {
        return c.gameObject.AddCmp(componentType);
    }

    public static Component GetCmp(this Component c, Type componentType)
    {
        return c.gameObject.GetCmp(componentType);
    }

    public static GameObject AddChild(this Component parent, GameObject prefab, string name = null, bool init = true)
    {
        return parent.gameObject.AddChild(prefab, name, init);
    }

    public static Component Child(this Component c, string name, Type componentType = null)
    {
        return c.gameObject.Child(name, componentType);
    }

    public static Component Child(this Component c, int index, Type componentType = null)
    {
        return c.gameObject.Child(index, componentType);
    }
}