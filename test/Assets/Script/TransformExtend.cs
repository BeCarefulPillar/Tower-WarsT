using UnityEngine;

public static class TransformExtend
{
    public static float GetLocalPx(this Transform t)
    {
        return t.localPosition.x;
    }

    public static float GetLocalPy(this Transform t)
    {
        return t.localPosition.y;
    }

    public static float GetLocalPz(this Transform t)
    {
        return t.localPosition.z;
    }

    public static Transform SetLocalPx(this Transform t, float v)
    {
        t.localPosition = new Vector3(v, t.localPosition.y, t.localPosition.z);
        return t;
    }

    public static Transform SetLocalPy(this Transform t, float v)
    {
        t.localPosition = new Vector3(t.localPosition.x, v, t.localPosition.z);
        return t;
    }

    public static Transform SetLocalPz(this Transform t, float v)
    {
        t.localPosition = new Vector3(t.localPosition.x, t.localPosition.y, v);
        return t;
    }
}