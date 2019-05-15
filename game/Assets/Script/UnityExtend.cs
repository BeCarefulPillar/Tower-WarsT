using UnityEngine;

public static class UnityExtend
{
    public static GameObject AddChild(this Transform m, GameObject pb, string nm = null)
    {
        GameObject go = Object.Instantiate(pb);
        go.name = string.IsNullOrEmpty(nm) ? pb.name : nm;
        Transform t = go.transform;
        t.SetParent(m);
        t.localPosition = Vector3.zero;
        t.localRotation = Quaternion.identity;
        t.localScale = Vector3.one;
        return go;
    }
}