using UnityEngine;
using System;

public static class MathEx
{
    /// <summary>
    /// 求和
    /// </summary>
    public static int Sum(params int[] values)
    {
        int res = 0;
        if (values != null) foreach (int v in values) res += v;
        return res;
    }
    /// <summary>
    /// 求和
    /// </summary>
    public static float Sum(params float[] values)
    {
        float res = 0;
        if (values != null) foreach (float v in values) res += v;
        return res;
    }

    /// <summary>
    /// 取浮点数的小数部分
    /// </summary>
    public static float FlotPart(float f) { return f - (int)f; }

    /// <summary>
    /// 向量1是在向量2的左边还是右边，或者是在向量2上
    /// </summary>
    /// <param name="ver1">向量1</param>
    /// <param name="ver2">向量2</param>
    /// <returns>-1=左边 1=右边 0=向量上</returns>
    public static int InVectorDre(Vector2 ver1, Vector2 ver2)
    {
        ver2 = new Vector2(ver2.y, -ver2.x);
        float v = ver2.x * ver1.x + ver2.y * ver1.y;
        return v > 0 ? 1 : (v < 0 ? -1 : 0);
    }

    /// <summary>
    /// 点是否在三角形内
    /// </summary>
    /// <param name="point">给定的</param>
    /// <param name="t1">三角形1点,顺时针</param>
    /// <param name="t2">三角形2点,顺时针</param>
    /// <param name="t3">三角形3点,顺时针</param>
    /// <param name="containLine">是否包含线上的点</param>
    public static bool PointInTrangle(Vector2 point, Vector2 t1, Vector2 t2, Vector2 t3, bool containLine = true)
    {
        return containLine ? InVectorDre(point - t1, t2 - t1) >= 0 && InVectorDre(point - t2, t3 - t2) >= 0 && InVectorDre(point - t3, t1 - t3) >= 0 : InVectorDre(point - t1, t2 - t1) > 0 && InVectorDre(point - t2, t3 - t2) > 0 && InVectorDre(point - t3, t1 - t3) > 0;
    }

    public static Vector2[] PathControlPointGenerator(Vector2[] path)
    {
        Vector2[] suppliedPath;
        Vector2[] Vector2s;

        //create and store path points:
        suppliedPath = path;

        //populate calculate path;
        int offset = 2;
        Vector2s = new Vector2[suppliedPath.Length + offset];
        Array.Copy(suppliedPath, 0, Vector2s, 1, suppliedPath.Length);

        //populate start and end control points:
        //Vector2s[0] = Vector2s[1] - Vector2s[2];
        Vector2s[0] = Vector2s[1] + (Vector2s[1] - Vector2s[2]);
        Vector2s[Vector2s.Length - 1] = Vector2s[Vector2s.Length - 2] + (Vector2s[Vector2s.Length - 2] - Vector2s[Vector2s.Length - 3]);

        //is this a closed, continuous loop? yes? well then so let's make a continuous Catmull-Rom spline!
        if (Vector2s[1] == Vector2s[Vector2s.Length - 2])
        {
            Vector2[] tmpLoopSpline = new Vector2[Vector2s.Length];
            Array.Copy(Vector2s, tmpLoopSpline, Vector2s.Length);
            tmpLoopSpline[0] = tmpLoopSpline[tmpLoopSpline.Length - 3];
            tmpLoopSpline[tmpLoopSpline.Length - 1] = tmpLoopSpline[2];
            Vector2s = new Vector2[tmpLoopSpline.Length];
            Array.Copy(tmpLoopSpline, Vector2s, tmpLoopSpline.Length);
        }

        return Vector2s;
    }

    //andeeee from the Unity forum's steller Catmull-Rom class ( http://forum.unity3d.com/viewtopic.php?p=218400#218400 ):
    public static Vector2 Interp(Vector2[] pts, float t)
    {
        int numSections = pts.Length - 3;
        int currPt = Mathf.Min(Mathf.FloorToInt(t * (float)numSections), numSections - 1);
        float u = t * (float)numSections - (float)currPt;

        Vector2 a = pts[currPt];
        Vector2 b = pts[currPt + 1];
        Vector2 c = pts[currPt + 2];
        Vector2 d = pts[currPt + 3];

        return .5f * (
            (-a + 3f * b - 3f * c + d) * (u * u * u)
            + (2f * a - 5f * b + 4f * c - d) * (u * u)
            + (-a + c) * u
            + 2f * b
        );
    }
}
