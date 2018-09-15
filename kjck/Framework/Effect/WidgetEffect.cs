using UnityEngine;
using System.Collections.Generic;

public class WidgetEffect : MonoBehaviour
{
    public enum Method
    {
        Detonate,       //引爆碎片
        Elimination,    //方块消除
    }

    private struct InPoint
    {
        public int index;
        public Vector2 point;
        public InPoint(int index, Vector2 point)
        {
            this.index = index;
            this.point = point;
        }
    }

    public struct Triangle
    {
        public List<Vector3> verts;
        public List<Vector2> uvs;
        public List<Color> cols;
        public List<int> counts;

        public Triangle(Vector2[] triangle, List<Vector3> widgetVerts, List<Vector2> widgetUvs, List<Color> widgetCols)
        {
            verts = null; uvs = null; cols = null; counts = null;
            if (triangle.Length != 3)
            {
                Debug.LogWarning("Creat Triangle need 3 points");
                return;
            }

            verts = new List<Vector3>();
            uvs = new List<Vector2>();
            cols = new List<Color>();
            counts = new List<int>();
            List<Vector2> V = new List<Vector2>();
            List<Vector2> U = new List<Vector2>();
            List<Color> C = new List<Color>();

            //int index1 = 0, index2 = 0, cnt2 = 0, status = 0;
            Vector2[] vs = new Vector2[3];
            Vector2[] us = new Vector2[3];
            Color32[] cs = new Color32[3];
            //InPoint ip;
            InPoint[] ips;
            Vector2 minA = new Vector2(Mathf.Min(triangle[0].x, triangle[1].x, triangle[2].x), Mathf.Min(triangle[0].y, triangle[1].y, triangle[2].y));
            Vector2 maxA = new Vector2(Mathf.Max(triangle[0].x, triangle[1].x, triangle[2].x), Mathf.Max(triangle[0].y, triangle[1].y, triangle[2].y));

            #region LOGIC
            for (int i = 0; i < widgetVerts.Count; i += 4)
            {
                for (int j = 0; j < 2; j++)
                {
                    //int debugIdx = i / 2 + j;
                    if (j == 0)
                    {
                        vs[0] = widgetVerts[i]; vs[1] = widgetVerts[i + 1]; vs[2] = widgetVerts[i + 2];
                        us[0] = widgetUvs[i]; us[1] = widgetUvs[i + 1]; us[2] = widgetUvs[i + 2];
                        cs[0] = widgetCols[i]; cs[1] = widgetCols[i + 1]; cs[2] = widgetCols[i + 2];
                    }
                    else
                    {
                        vs[0] = widgetVerts[i + 2]; vs[1] = widgetVerts[i + 3]; vs[2] = widgetVerts[i];
                        us[0] = widgetUvs[i + 2]; us[1] = widgetUvs[i + 3]; us[2] = widgetUvs[i];
                        cs[0] = widgetCols[i + 2]; cs[1] = widgetCols[i + 3]; cs[2] = widgetCols[i];
                    }
                    //Debug.Log(vs[0] + "," + vs[1] + "," + vs[2]);

                    //index1 = 0; index2 = 0; status = 0; cnt2 = 0;
                    V.Clear(); U.Clear(); C.Clear();

                    if (TriangleOverlap(minA, maxA, vs[0], vs[1], vs[2]))
                    {
                        int lastIndex = 0;
                        if (PointInTriangleAndLine(vs[0], triangle))//第一个点是否在范围内
                        {
                            V.Add(vs[0]);
                            U.Add(us[0]);
                            C.Add(cs[0]);
                        }
                        ips = CalculateIntersection(vs[0], vs[1], triangle[0], triangle[1], triangle[2]);//第一条线是否有交点
                        if (ips != null)
                        {
                            //if (debugIdx == 5) Debug.LogWarning(vs[0] + "," + vs[1]);
                            //if (debugIdx == 5) Debug.LogWarning(triangle[0] + "," + triangle[1] + "," + triangle[2]);
                            foreach (InPoint p in ips)
                            {
                                if (HasPoint(p.point, V)) continue;
                                lastIndex = p.index;
                                AddData(V, U, C, p.point, vs, us, cs);
                            }
                        }
                        if (PointInTriangleAndLine(vs[1], triangle))//第二个点是否在范围内
                        {
                            if (!HasPoint(vs[1], V))
                            {
                                V.Add(vs[1]);
                                U.Add(us[1]);
                                C.Add(cs[1]);
                            }
                        }
                        ips = CalculateIntersection(vs[1], vs[2], triangle[0], triangle[1], triangle[2]);//第二条线是否有交点
                        if (ips != null)
                        {
                            foreach (InPoint p in ips)
                            {
                                //if (debugIdx == 5) Debug.LogWarning(p.point);
                                if (HasPoint(p.point, V)) continue;
                                lastIndex = p.index;
                                AddData(V, U, C, p.point, vs, us, cs);
                            }
                        }
                        if (PointInTriangleAndLine(vs[2], triangle))//第三个点是否在范围内
                        {
                            if (!HasPoint(vs[2], V))
                            {
                                V.Add(vs[2]);
                                U.Add(us[2]);
                                C.Add(cs[2]);
                            }
                        }
                        ips = CalculateIntersection(vs[2], vs[0], triangle[0], triangle[1], triangle[2]);//第三条线是否有交点
                        if (ips != null)
                        {
                            foreach (InPoint p in ips)
                            {
                                //if (debugIdx == 5) Debug.LogWarning(p.point);
                                if (HasPoint(p.point, V)) continue;
                                lastIndex = p.index;
                                AddData(V, U, C, p.point, vs, us, cs);
                            }
                        }

                        for (int k = 0; k < 3; k++)//范围三角形是否有点在区域内
                        {
                            int idx = (lastIndex + k) % 3;
                            if (PointInTriangleAndLine(triangle[idx], vs))
                            {
                                if (HasPoint(triangle[idx], V)) continue;
                                AddData(V, U, C, triangle[idx], vs, us, cs);
                            }
                        }
                    }

                    if (V.Count > 2)
                    {
                        for (int l = 0; l < V.Count; l++)
                        {
                            verts.Add(V[l]);
                            uvs.Add(U[l]);
                            cols.Add(C[l]);
                        }
                        counts.Add(V.Count);
                    }
                }
            }
            #endregion

            if (verts.Count < 3)
            {
                verts = null;
                uvs = null;
                cols = null;
            }
        }
        /// <summary>
        /// 点集合是否包含给定点
        /// </summary>
        private bool HasPoint(Vector2 point, List<Vector2> points)
        {
            foreach (Vector2 p in points)
                if (ApproximatelyVector2(p, point)) 
                    return true;
            return false;
        }
        /// <summary>
        /// 添加点信息，返回ture表示改点与第一点重叠，结束搜寻
        /// </summary>
        private bool AddData(List<Vector2> V, List<Vector2> U, List<Color> C, Vector2 point, Vector2[] vs, Vector2[] us, Color32[] cs)
        {
            Vector2 map = TriangleMap(point, vs);
            Vector2 u = GetMapVector(map, us);
            Color c = GetMapColor(map, cs[0], cs[1], cs[2]);
            if (V.Count > 0)
            {
                Vector2 v = V[0];
                if (V.Count > 1 && ApproximatelyVector2(v, point)) return true;
                v = V[V.Count - 1];
                if (ApproximatelyVector2(v, point)) return false;
            }
            V.Add(point); U.Add(u); C.Add(c);
            return false;
        }

        /// <summary>
        /// 根据映射得出点
        /// </summary>
        private Vector2 GetMapVector(Vector2 map, Vector2[] triangle)
        {
            Vector2 O = triangle[0];
            Vector2 n1 = (triangle[1] - O);
            Vector2 n2 = (triangle[2] - O);
            return n1 * map.x + n2 * map.y + O;
        }
        /// <summary>
        /// 根据映射得出颜色
        /// </summary>
        private Color32 GetMapColor32(Vector2 map, Color32 c1, Color32 c2, Color32 c3)
        {
            Vector4 n1 = (new Vector4((float)c2.r - (float)c1.r, (float)c2.g - (float)c1.g, (float)c2.b - (float)c1.b, (float)c2.a - (float)c1.a));
            Vector4 n2 = (new Vector4((float)c3.r - (float)c1.r, (float)c3.g - (float)c1.g, (float)c3.b - (float)c1.b, (float)c3.a - (float)c1.a));
            Vector4 c = n1 * map.x + n2 * map.y;
            return new Color32((byte)(c.x + c1.r), (byte)(c.y + c1.g), (byte)(c.z + c1.b), (byte)(c.w + c1.a));
        }
        /// <summary>
        /// 根据映射得出颜色
        /// </summary>
        private Color32 GetMapColor(Vector2 map, Color c1, Color c2, Color c3)
        {
            Vector4 n1 = (new Vector4(c2.r - c1.r, c2.g - c1.g, c2.b - c1.b, c2.a - c1.a));
            Vector4 n2 = (new Vector4(c3.r - c1.r, c3.g - c1.g, c3.b - c1.b, c3.a - c1.a));
            Vector4 c = n1 * map.x + n2 * map.y;
            return new Color(c.x + c1.r, c.y + c1.g, c.z + c1.b, c.w + c1.a);
        }
        /// <summary>
        /// 点对于三角形1点的映射分量值
        /// </summary>
        private Vector2 TriangleMap(Vector2 point, Vector2[] triangle)
        {
            Vector2 O = triangle[0];
            Vector2 n1 = (triangle[1] - O).normalized;
            Vector2 n2 = (triangle[2] - O).normalized;
            Vector2 c = point - O;
            float v = n1.x * n2.y - n1.y * n2.x;
            return new Vector2((n2.y * c.x - n2.x * c.y) / (v * (triangle[1] - O).magnitude), (n1.x * c.y - n1.y * c.x) / (v * (triangle[2] - O).magnitude));
        }
        /// <summary>
        /// 点是否在三角形内
        /// </summary>
        private bool PointInTriangle(Vector2 point, Vector2[] triangle)
        {
            for (int i = 0; i < 3; i++)
            {
                Vector2 p1 = triangle[i];
                Vector2 p2 = triangle[i < 2 ? i + 1 : 0];
                Vector2 v = new Vector2(p1.y - p2.y, p2.x - p1.x);
                if (Vector2.Dot(point - p1, v) >= 0) return false;
            }
            return true;
        }
        /// <summary>
        /// 点在三角形内或者三角形边上
        /// </summary>
        /// <param name="point"></param>
        /// <param name="triangle"></param>
        /// <returns></returns>
        private bool PointInTriangleAndLine(Vector2 point, Vector2[] triangle)
        {
            for (int i = 0; i < 3; i++)
            {
                Vector2 p1 = triangle[i];
                Vector2 p2 = triangle[i < 2 ? i + 1 : 0];
                Vector2 v = new Vector2(p1.y - p2.y, p2.x - p1.x);
                if (Vector2.Dot(point - p1, v) > 0) return false;
            }
            return true;
        }
        /// <summary>
        /// 三角形1是否在三角形2内
        /// </summary>
        private bool TriangleInTriangle(Vector2[] triangle1, Vector2[] triangle2)
        {
            int num = 0;
            for (int i = 0; i < 3; i++)
            {
                Vector2 p1 = triangle2[i];
                Vector2 p2 = triangle2[i < 2 ? i + 1 : 0];
                Vector2 v = new Vector2(p1.y - p2.y, p2.x - p1.x);
                int temp = 0;
                foreach (Vector2 p in triangle1)
                {
                    if (Vector2.Dot(p - p1, v) <= 0) temp++;
                    else break;
                }
                if (temp > 2) num++;
            }
            return num > 2;
        }
        private bool PointLeftVector(Vector2 point, Vector2 O, Vector2 A)
        {
            Vector2 v = new Vector2(O.y - A.y, A.x - O.x);
            return Vector2.Dot(point - O, v) > 0;
        }
        private bool PointRightVector(Vector2 point, Vector2 O, Vector2 A)
        {
            Vector2 v = new Vector2(O.y - A.y, A.x - O.x);
            return Vector2.Dot(point - O, v) < 0;
        }
        /// <summary>
        /// 计算向量与三角形的交点集 按最近到最远排序
        /// </summary>
        private InPoint[] CalculateIntersection(Vector2 LA1, Vector2 LA2, Vector2 p1, Vector2 p2, Vector2 p3)
        {
            Vector2 point;
            InPoint ip = new InPoint(-1, Vector2.zero);
            //float d1, d2;
            //Debug.LogWarning(LA1 + "," + LA2 + "," + p1 + "," + p2 + "," + p3);
            if (CalculateIntersection(LA1, LA2, p1, p2, out point))
            {
                ip = new InPoint(0, point);
            }
            if (CalculateIntersection(LA1, LA2, p2, p3, out point))
            {
                
                if (ip.index < 0)
                {
                    ip = new InPoint(1, point);
                }
                else
                {
                    //d1 = (ip.point - LA1).sqrMagnitude;
                    //d2 = (point - LA1).sqrMagnitude;
                    //if (Mathf.Approximately(d1, d2))
                    //{
                    //    if (PointRightVector(LA2, p1, p2) && PointRightVector(LA2, p2, p3)) return new InPoint[1] { ip };
                    //    else return null;
                    //}
                    if (ApproximatelyVector2(ip.point, point))
                    {
                        if (((p1 + p2) * 0.5f - LA1).sqrMagnitude > ((p2 + p3) * 0.5f - LA1).sqrMagnitude) ip = new InPoint(1, point);
                    }
                    else if ((point - LA1).sqrMagnitude < (ip.point - LA1).sqrMagnitude) return new InPoint[2] { new InPoint(1, point), ip };
                    else return new InPoint[2] { ip, new InPoint(1, point) };
                }
            }
            if (CalculateIntersection(LA1, LA2, p3, p1, out point))
            {
                if (ip.index < 0)
                {
                    ip = new InPoint(2, point);
                }
                else
                {
                    //d1 = (ip.point - LA1).sqrMagnitude;
                    //d2 = (point - LA1).sqrMagnitude;
                    //if (Mathf.Approximately(d1, d2))
                    //{
                    //    if (PointRightVector(LA2, p2, p3) && PointRightVector(LA2, p3, p1)) return new InPoint[1] { ip };
                    //    else return null;
                    //}
                    if (ApproximatelyVector2(ip.point, point))
                    {
                        if (ip.index == 0)
                        {
                            if (((p1 + p2) * 0.5f - LA1).sqrMagnitude > ((p3 + p1) * 0.5f - LA1).sqrMagnitude) ip = new InPoint(2, point);
                        }
                        else
                        {
                            if (((p2 + p3) * 0.5f - LA1).sqrMagnitude > ((p3 + p1) * 0.5f - LA1).sqrMagnitude) ip = new InPoint(2, point);
                        }
                    }
                    else if ((point - LA1).sqrMagnitude < (ip.point - LA1).sqrMagnitude) return new InPoint[2] { new InPoint(2, point), ip };
                    else return new InPoint[2] { ip, new InPoint(2, point) };
                }
            }
            return ip.index < 0 ? null : new InPoint[1] { ip };
        }
        /// <summary>
        /// 计算2线段的交点
        /// </summary>
        private bool CalculateIntersection(Vector2 LA1, Vector2 LA2, Vector2 LB1, Vector2 LB2, out Vector2 point)
        {
            point = Vector2.zero;

            if (LA1.x == LA2.x)
            {
                if (LB1.x == LB2.x) return false;
                float k = (LB2.y - LB1.y) / (LB2.x - LB1.x);
                float y = k * LA1.x + LB1.y - k * LB1.x;
                point = new Vector2(LA1.x, y);
                //return BetweenTowValue(y, LA1.y, LA2.y);
            }
            else if (LB1.x == LB2.x)
            {
                float k = (LA2.y - LA1.y) / (LA2.x - LA1.x);
                float y = k * LB1.x + LA1.y - k * LA1.x;
                point = new Vector2(LB1.x, y);
                //return BetweenTowValue(y, LB1.y, LB2.y);
            }
            else
            {
                float ka = (LA2.y - LA1.y) / (LA2.x - LA1.x);
                float kb = (LB2.y - LB1.y) / (LB2.x - LB1.x);
                if (ka == kb) return false;
                float ca = LA1.y - ka * LA1.x;
                float cb = LB1.y - kb * LB1.x;
                float x = (cb - ca) / (ka - kb);
                float y = ka * x + ca;
                point = new Vector2(x, y);
                //return BetweenTowValue(x, LA1.x, LA2.x) && BetweenTowValue(x, LB1.x, LB2.x) && BetweenTowValue(y, LA1.y, LA2.y) && BetweenTowValue(y, LB1.y, LB2.y);
            }
            return BetweenTowValue(point.x, LA1.x, LA2.x) && BetweenTowValue(point.x, LB1.x, LB2.x) && BetweenTowValue(point.y, LA1.y, LA2.y) && BetweenTowValue(point.y, LB1.y, LB2.y);
        }
        private bool BetweenTowValue(float v, float v1, float v2)
        {
            //return v1 > v2 ? (v > v2 && v < v1) : (v > v1 && v < v2);
            return v1 > v2 ? (v >= v2 && v <= v1) : (v >= v1 && v <= v2);
        }
        /// <summary>
        /// 2三角形是否在矩形区域相交叠
        /// </summary>
        private bool TriangleOverlap(Vector2 minA, Vector2 maxA, Vector2 b1, Vector2 b2, Vector2 b3)
        {
            Vector2 minB = new Vector2(Mathf.Min(b1.x, b2.x, b3.x), Mathf.Min(b1.y, b2.y, b3.y));
            Vector2 maxB = new Vector2(Mathf.Max(b1.x, b2.x, b3.x), Mathf.Max(b1.y, b2.y, b3.y));

            return maxB.x > minA.x && minB.x < maxA.x && maxB.y > minA.y && minB.y < maxA.y;
        }
        /// <summary>
        /// 两点或向量相似
        /// </summary>
        private bool ApproximatelyVector2(Vector2 v1, Vector2 v2)
        {
            return Mathf.Approximately(v1.x, v2.x) && Mathf.Approximately(v1.y, v2.y);
        }
    }

    private struct Fragment
    {
        public Vector3 velocity;
        public Vector3 position;
        public Vector3 axisOfRotation;
        public float rotation;
        public float lifetime;
        public Triangle[] triangle;
    }

    public Method method;
    public UIWidget widget;
    public int elimination = 0;
    public float eliminationTime = 1f;
    public int sepX = 2;
    public int sepY = 2;
    public float lost = 0f;
    public float minMomentum = 10;
    public float maxMomentum = 30;
    public bool playOnAwake = false;
    public bool destroyWidget = false;
    public System.Action<WidgetEffect> onFinished;

    List<GameObject> fragments;

    void Start()
    {
        if (playOnAwake)
        {
            if (method == Method.Detonate) Detonate();
            else if (method == Method.Elimination) Elimination();
        }
    }

    void Dispose()
    {
        if (fragments != null)
        {
            foreach (GameObject go in fragments) if (go) Destroy(go);
            fragments = null;
        }
    }

    /**********************************引爆动画**********************************/
    public void Detonate()
    {
        if (widget == null || widget.mainTexture == null) return;
        Dispose();
        fragments = new List<GameObject>();
        if (sepX < 2) sepX = 2;
        if (sepY < 2) sepY = 2;

        List<Vector3> verts = new List<Vector3>();
        List<Vector2> uvs = new List<Vector2>();
        List<Color> cols = new List<Color>();
        widget.OnFill(verts, uvs, cols);

        Vector4 dd = widget.drawingDimensions;

        float w = dd.z - dd.x, h = dd.w - dd.y, wd = w / sepX, hd = h / sepY;
        int py = sepY + 1, px = sepX + 1;
        Vector2[,] sepPoints = new Vector2[py, px];
        float x = 0, y = 0, rwd = wd * 0.4f, rhd = hd * 0.4f;
        //int sepY = sepY - 1, sepX = sepX - 1;
        for (int i = 0; i < py; i++)
        {
            if (i == 0) y = dd.y;
            else if (i == sepY) y = dd.w;
            else y = hd * i + dd.y;
            for (int j = 0; j < px; j++)
            {
                if (j == 0) x = dd.x;
                else if (j == sepX) x = dd.z;
                else x = wd * j + Random.Range(-rwd, rwd) + dd.x;
                sepPoints[i, j] = new Vector2(x, y + ((i > 0 && i < sepY) ? Random.Range(-rhd, rhd) : 0));
                //sepPoints[i * sepX + j] = new Vector2(x, y);
            }
        }

        for (int i = 0; i < sepY; i++)
        {
            for (int j = 0; j < sepX; j++)
            {
                if (lost > Random.Range(0f, 1f)) continue;
                Triangle triangle1 = new Triangle(new Vector2[3] { sepPoints[i, j], sepPoints[i + 1, j], sepPoints[i + 1, j + 1] }, verts, uvs, cols);
                Triangle triangle2 = new Triangle(new Vector2[3] { sepPoints[i + 1, j + 1], sepPoints[i, j + 1], sepPoints[i, j] }, verts, uvs, cols);
                if (Random.Range(0, 100) < 50)
                {
                    GenerateDetonateFragment(widget, triangle1);
                    GenerateDetonateFragment(widget, triangle2);
                }
                else
                {
                    GenerateDetonateFragment(widget, triangle1, triangle2);
                }
            }
        }

        if (destroyWidget) widget.enabled = false;
    }

    void GenerateDetonateFragment(UIWidget widget, params Triangle[] triangles)
    {
        UIFragment uf = UIFragment.Generate(widget, triangles);

        Vector3 drect, pos = uf.cachedTransform.localPosition;
        pos.z = 0;
        if (pos != Vector3.zero)
        {
            drect = new Vector3(pos.x, pos.y, Mathf.Min(0, pos.magnitude - Mathf.Min(widget.width, widget.height) * 0.5f));
            drect = drect.normalized;
            float a = Random.Range(-0.09f, 0.09f);
            float cosa = Mathf.Cos(a);
            float sina = Mathf.Sin(a);
            drect = new Vector3(drect.x * cosa - drect.y * sina, drect.y * cosa + drect.x * sina, 0);
        }
        else
        {
            float a = Random.Range(0, Mathf.PI * 2f);
            drect = new Vector3(Mathf.Cos(a), Mathf.Sin(a), Mathf.Min(0, Mathf.Min(widget.width, widget.height) * 0.5f));
            //drect = new Vector3(Mathf.Cos(a), Mathf.Sin(a), 0);
        }
        Vector3 axis = new Vector3(-drect.y, drect.x, 0);
        MomentumMove mm = uf.cachedGameObject.AddComponent<MomentumMove>();
        mm.ApplyData(Random.Range(minMomentum, maxMomentum), drect, axis, OnFragmentFinished);
        fragments.Add(uf.cachedGameObject);
    }
     
    void OnFragmentFinished(GameObject go)
    {
        fragments.Remove(go);
        Destroy(go);
        if (fragments.Count <= 0)
        {
            if (destroyWidget && widget) Destroy(widget.cachedGameObject);
            if (onFinished != null) onFinished(this);
        }
    }

    /**********************************消除动画**********************************/

    public void Elimination()
    {
        if (widget == null || widget.mainTexture == null) return;
        Dispose();
        fragments = new List<GameObject>();
        if (sepX < 2) sepX = 2;
        if (sepY < 2) sepY = 2;

        List<Vector3> verts = new List<Vector3>();
        List<Vector2> uvs = new List<Vector2>();
        List<Color> cols = new List<Color>();
        widget.OnFill(verts, uvs, cols);

        Vector4 dd = widget.drawingDimensions;

        float w = dd.z - dd.x, h = dd.w - dd.y, wd = w / sepX, hd = h / sepY;
        int px = sepX + 1, py = sepY + 1;
        Vector2[,] sepPoints = new Vector2[py, px];
        float x = 0, y = 0;
        for (int i = 0; i < py; i++)
        {
            y = hd * i + dd.y;
            for (int j = 0; j < px; j++)
            {
                x = wd * j + dd.x;
                sepPoints[i, j] = new Vector2(x, y);
            }
        }

        float[,] delays = new float[sepY, sepX];
        float dtime = 0;

        switch (elimination)
        {
            default:
            case 0://从左到右
                dtime = eliminationTime / sepX;
                for (int i = 0; i < sepX; i++)
                {
                    float dl = i * dtime;
                    for (int j = 0; j < sepY; j++) delays[j, i] = dl;
                }
                break;
            case 1://从左下到右上
                dtime = eliminationTime / (sepX + sepY - 1);
                for (int i = 0; i < sepY; i++)
                    for (int j = 0; j < sepX; j++)
                        delays[i, j] = (i + j) * dtime;
                break;
            case 2://从下到上
                dtime = eliminationTime / sepY;
                for (int i = 0; i < sepY; i++)
                {
                    float dl = i * dtime;
                    for (int j = 0; j < sepX; j++) delays[i, j] = dl;
                }
                break;
            case 3://从右下到左上
                dtime = eliminationTime / (sepX + sepY - 1);
                for (int i = 0; i < sepY; i++)
                    for (int j = 0; j < sepX; j++)
                        delays[i, j] = (i + sepX - j - 1) * dtime;
                break;
            case 4://从右到左
                dtime = eliminationTime / sepX;
                for (int i = 0; i < sepX; i++)
                {
                    float dl = (sepX - i - 1) * dtime;
                    for (int j = 0; j < sepY; j++) delays[j, i] = dl;
                }
                break;
            case 5://从右上到左下
                dtime = eliminationTime / (sepX + sepY - 1);
                for (int i = 0; i < sepY; i++)
                    for (int j = 0; j < sepX; j++)
                        delays[i, j] = (sepY - i + sepX - j - 2) * dtime;
                break;
            case 6://从上到下
                dtime = eliminationTime / sepY;
                for (int i = 0; i < sepY; i++)
                {
                    float dl = (sepY - i - 1) * dtime;
                    for (int j = 0; j < sepX; j++) delays[i, j] = dl;
                }
                break;
            case 7://从左上到右下
                dtime = eliminationTime / (sepX + sepY - 1);
                for (int i = 0; i < sepY; i++)
                    for (int j = 0; j < sepX; j++)
                        delays[i, j] = (sepY - i - 1 + j) * dtime;
                break;
            case 8://从中心到四周 方形
                {
                    float xtime = 2f * eliminationTime / sepX;
                    float ytime = 2f * eliminationTime / sepY;
                    dtime = Mathf.Min(xtime, ytime);
                    float cx = sepX * 0.5f - 0.5f;
                    float cy = sepY * 0.5f - 0.5f;
                    for (int i = 0; i < sepY; i++)
                    {
                        for (int j = 0; j < sepX; j++)
                        {
                            delays[i, j] = Mathf.Max(Mathf.Abs(i - cy) * ytime, Mathf.Abs(j - cx) * xtime);
                        }
                    }
                }
                break;
            case 9://从四周到中心 方形
                {
                    float xtime = 2f * eliminationTime / sepX;
                    float ytime = 2f * eliminationTime / sepY;
                    dtime = Mathf.Min(xtime, ytime);
                    float cx = sepX / 2f - 0.5f;
                    float cy = sepY / 2f - 0.5f;
                    for (int i = 0; i < sepY; i++)
                    {
                        for (int j = 0; j < sepX; j++)
                        {
                            delays[i, j] = Mathf.Min((i > cy ? sepY - i : i) * ytime, (j > cx ? sepX - j : j) * xtime);
                        }
                    }
                }
                break;
            case 10://从中心到四周 正圆形
                {
                    int sx = sepX - 1;
                    int sy = sepY - 1;
                    float rr = 2f / Mathf.Sqrt(sx * sx + sy * sy);
                    dtime = eliminationTime * rr;
                    Vector2 center = new Vector2(sy * 0.5f, sx * 0.5f);
                    for (int i = 0; i < sepY; i++)
                    {
                        for (int j = 0; j < sepX; j++)
                        {
                            delays[i, j] = (new Vector2(i, j) - center).magnitude * dtime;
                        }
                    }
                }
                break;
            case 11://从四周到中心 正圆形
                {
                    int sx = sepX - 1;
                    int sy = sepY - 1;
                    float r = Mathf.Sqrt(sx * sx + sy * sy) * 0.5f;
                    float rr = 1f / r;
                    dtime = eliminationTime * rr;
                    Vector2 center = new Vector2(sy * 0.5f, sx * 0.5f);
                    for (int i = 0; i < sepY; i++)
                    {
                        for (int j = 0; j < sepX; j++)
                        {
                            delays[i, j] = (r - (new Vector2(i, j) - center).magnitude) * dtime;
                        }
                    }
                }
                break;
            case 12://从中心到四周 椭圆
                {
                    float xtime = 2f * eliminationTime / sepX;
                    float ytime = 2f * eliminationTime / sepY;
                    dtime = Mathf.Min(xtime, ytime);
                    float cx = sepX * 0.5f - 0.5f;
                    float cy = sepY * 0.5f - 0.5f;
                    for (int i = 0; i < sepY; i++)
                    {
                        for (int j = 0; j < sepX; j++)
                        {
                            delays[i, j] = new Vector2((i - cy) * ytime, (j - cx) * xtime).magnitude;
                        }
                    }
                }
                break;
        }

        if (dtime <= 0) dtime = 0.1f;
        GameObject go = gameObject;
        for (int i = 0; i < sepY; i++)
        {
            for (int j = 0; j < sepX; j++)
            {
                if (lost > Random.Range(0f, 1f)) continue;
                Triangle triangle1 = new Triangle(new Vector2[3] { sepPoints[i, j], sepPoints[i + 1, j], sepPoints[i + 1, j + 1] }, verts, uvs, cols);
                Triangle triangle2 = new Triangle(new Vector2[3] { sepPoints[i + 1, j + 1], sepPoints[i, j + 1], sepPoints[i, j] }, verts, uvs, cols);

                UIFragment uf = UIFragment.Generate(widget, triangle1, triangle2);

                fragments.Add(uf.cachedGameObject);

                TweenScale.Begin(uf.cachedGameObject, dtime * 5f, Vector3.zero).delay = delays[i, j];
                TweenAlpha ta = TweenAlpha.Begin(uf.cachedGameObject, dtime * 5f, 0);
                ta.delay = delays[i, j];
                ta.eventReceiver = go;
                ta.callWhenFinished = "OnEliminationFinished";
            }
        }

        if (destroyWidget) widget.enabled = false;
    }

    void OnEliminationFinished(UITweener ut)
    {
        fragments.Remove(ut.gameObject);
        Destroy(ut.gameObject);
        if (fragments.Count <= 0)
        {
            if (destroyWidget) Destroy(widget.gameObject);
            if (onFinished != null) onFinished(this);
        }
    }

    public static WidgetEffect Detonate(UIWidget widget, int sepX, int sepY, float delay = 0, bool destroyWidget = true, float minMomentum = 10f, float maxMomentum = 30f, float lost = 0f)
    {
        WidgetEffect dw = widget.GetComponent<WidgetEffect>();
        if (!dw) dw = widget.gameObject.AddComponent<WidgetEffect>();
        dw.widget = widget;
        dw.sepX = sepX;
        dw.sepY = sepY;
        dw.destroyWidget = destroyWidget;
        dw.playOnAwake = false;
        dw.minMomentum = minMomentum;
        dw.maxMomentum = maxMomentum;
        dw.lost = Mathf.Clamp01(lost);
        if (delay > 0) dw.Invoke("Detonate", delay);
        else dw.Detonate();
        return dw;
    }

    /// <summary>
    /// 消除效果
    /// </summary>
    /// <param name="widget">部件</param>
    /// <param name="sepX">X分量</param>
    /// <param name="sepY">Y分量</param>
    /// <param name="delay">延迟多少秒执行</param>
    /// <param name="destroyWidget">是否在完成时删除部件</param>
    /// <param name="time">消除总时间</param>
    /// <param name="method">方式 0=L-R,1=LB-RT,2=B-T,3=RB-LT,4=R-L,5=RT-LB,6=T-B,7=LT-RB,8=方C-A,9=方A-C,10=圆C-A,11=圆A-C,12=椭圆C-A,其它=随机</param>
    /// <param name="lost">块丢失几率 (0-1) 0=不丢失 1=100%丢失</param>
    /// <returns></returns>
    public static WidgetEffect Elimination(UIWidget widget, int sepX, int sepY, float delay = 0, bool destroyWidget = true, float time = 1f, int method = 0, float lost = 0f)
    {
        WidgetEffect dw = widget.GetComponent<WidgetEffect>();
        if (!dw) dw = widget.gameObject.AddComponent<WidgetEffect>();
        dw.widget = widget;
        dw.sepX = sepX;
        dw.sepY = sepY;
        dw.destroyWidget = destroyWidget;
        dw.playOnAwake = false;
        dw.eliminationTime = time;
        if (method < 0 || method > 12) method = Random.Range(0, 13);
        dw.elimination = method;
        dw.lost = Mathf.Clamp01(lost);
        if (delay > 0) dw.Invoke("Elimination", delay);
        else dw.Elimination();
        return dw;
    }
}
