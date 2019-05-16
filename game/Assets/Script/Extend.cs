using UnityEngine;

public static class Extend
{
    #region GameObject
    public static T GetCmp<T>(this GameObject m) where T : Component
    {
        return m.GetComponent<T>();
    }
    public static T[] GetCmps<T>(this GameObject m) where T : Component
    {
        return m.GetComponents<T>();
    }
    public static T AddCmp<T>(this GameObject m) where T : Component
    {
        return m.AddComponent<T>();
    }
    public static GameObject AddChild(this GameObject m, GameObject pb, string nm = null)
    {
        GameObject go = Object.Instantiate(pb, m.transform);
        Transform t = go.transform;
        t.name = nm == null ? pb.name : nm;
        t.localPosition = Vector3.zero;
        t.localRotation = Quaternion.identity;
        t.localScale = Vector3.one;
        return go;
    }
    public static Transform Child(this GameObject m, string nm)
    {
        return m.transform.Find(nm);
    }
    public static Transform Child(this GameObject m, int i)
    {
        return m.transform.GetChild(i);
    }
    public static T Child<T>(this GameObject m, string nm) where T : Component
    {
        return m.transform.Find(nm).GetComponent<T>();
    }
    public static T Child<T>(this GameObject m, int i) where T : Component
    {
        return m.transform.GetChild(i).GetComponent<T>();
    }
    public static void ActChild(this GameObject m, bool b, params string[] cs)
    {
        Transform t = m.transform;
        for (int i = cs.Length - 1; i >= 0; --i)
            t.Find(cs[i]).gameObject.SetActive(b);
    }
    public static void ActChild(this GameObject m, bool b, params int[] cs)
    {
        Transform t = m.transform;
        for (int i = cs.Length - 1; i >= 0; --i)
            t.GetChild(cs[i]).gameObject.SetActive(b);
    }
    public static void DesAllChild(this GameObject m)
    {
        Transform t = m.transform;
        for (int i = t.childCount - 1; i >= 0; --i)
            Object.Destroy(t.GetChild(i).gameObject);
    }
    public static void ActAllChild(this GameObject m, bool b)
    {
        Transform t = m.transform;
        for (int i = t.childCount - 1; i >= 0; --i)
            t.GetChild(i).gameObject.SetActive(b);
    }
    #endregion


    #region Component
    public static T GetCmp<T>(this Component m) where T : Component
    {
        return m.GetComponent<T>();
    }
    public static T[] GetCmps<T>(this Component m) where T : Component
    {
        return m.GetComponents<T>();
    }
    public static T AddCmp<T>(this Component m) where T : Component
    {
        return m.gameObject.AddComponent<T>();
    }
    public static GameObject AddChild(this Component m, GameObject pb, string nm = null)
    {
        GameObject go = Object.Instantiate(pb, m is Transform ? m as Transform : m.transform);
        Transform t = go.transform;
        t.name = nm == null ? pb.name : nm;
        t.localPosition = Vector3.zero;
        t.localRotation = Quaternion.identity;
        t.localScale = Vector3.one;
        return go;
    }
    public static Transform Child(this Component m, string nm)
    {
        return (m is Transform ? m as Transform : m.transform).Find(nm);
    }
    public static Transform Child(this Component m, int i)
    {
        return (m is Transform ? m as Transform : m.transform).GetChild(i);
    }
    public static T Child<T>(this Component m, string nm) where T : Component
    {
        return (m is Transform ? m as Transform : m.transform).Find(nm).GetComponent<T>();
    }
    public static T Child<T>(this Component m, int i) where T : Component
    {
        return (m is Transform ? m as Transform : m.transform).GetChild(i).GetComponent<T>();
    }
    public static void ActChild(this Component m, bool b, params string[] cs)
    {
        Transform t = m is Transform ? m as Transform : m.transform;
        for (int i = cs.Length - 1; i >= 0; --i)
            t.Find(cs[i]).gameObject.SetActive(b);
    }
    public static void ActChild(this Component m, bool b, params int[] cs)
    {
        Transform t = m is Transform ? m as Transform : m.transform;
        for (int i = cs.Length - 1; i >= 0; --i)
            t.GetChild(cs[i]).gameObject.SetActive(b);
    }
    public static void ActAllChild(this Component m, bool b)
    {
        Transform t = m is Transform ? m as Transform : m.transform;
        for (int i = t.childCount - 1; i >= 0; --i)
            t.GetChild(i).gameObject.SetActive(b);
    }
    public static void DesAllChild(this Component m)
    {
        Transform t = m is Transform ? m as Transform : m.transform;
        for (int i = t.childCount - 1; i >= 0; --i)
            Object.Destroy(t.GetChild(i).gameObject);
    }
    public static void SetActive(this Component m, bool b)
    {
        m.gameObject.SetActive(b);
    }
    #endregion


    #region Transform
    public static float GetLocalX(this Transform m)
    {
        return m.localPosition.x;
    }
    public static float GetLocalY(this Transform m)
    {
        return m.localPosition.y;
    }
    public static float GetLocalZ(this Transform m)
    {
        return m.localPosition.z;
    }
    public static float GetX(this Transform m)
    {
        return m.position.x;
    }
    public static float GetY(this Transform m)
    {
        return m.position.y;
    }
    public static float GetZ(this Transform m)
    {
        return m.position.z;
    }
    public static void SetLocalX(this Transform m, float v)
    {
        Vector3 t = m.localPosition;
        t.x = v;
        m.localPosition = t;
    }
    public static void SetLocalY(this Transform m, float v)
    {
        Vector3 t = m.localPosition;
        t.y = v;
        m.localPosition = t;
    }
    public static void SetLocalZ(this Transform m, float v)
    {
        Vector3 t = m.localPosition;
        t.z = v;
        m.localPosition = t;
    }
    public static void SetX(this Transform m, float v)
    {
        Vector3 t = m.position;
        t.x = v;
        m.position = t;
    }
    public static void SetY(this Transform m, float v)
    {
        Vector3 t = m.position;
        t.y = v;
        m.position = t;
    }
    public static void SetZ(this Transform m, float v)
    {
        Vector3 t = m.position;
        t.z = v;
        m.position = t;
    }
    #endregion
}