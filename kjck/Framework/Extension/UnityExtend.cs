using UnityEngine;
using Type = System.Type;
using System.Collections.Generic;

public static class UnityExtend
{
    #region Object
    /// <summary>
    /// 销毁自身，即使自身为空不会报错
    /// </summary>
    public static void Destruct(this Object obj) { if (obj) Object.Destroy(obj); }
    /// <summary>
    /// 延迟销毁自身，即使自身为空不会报错
    /// </summary>
    public static void Destruct(this Object obj, float delay) { if (obj) Object.Destroy(obj, delay); }
    #endregion

    #region GameObject
    /// <summary>
    /// 获取所有子级的所有T类型组件 (if(self)包括自身,非激活状态可用)
    /// </summary>
    /// <typeparam name="T">组件类型</typeparam>
    /// <param name="gameObject">父级组件</param>
    /// <returns>组件数组</returns>
    public static T[] GetComponentsInAllChild<T>(this GameObject gameObject, bool self = true) where T : class
    {
        List<T> cmps = new List<T>(4);
        if (self)
        {
            SearchComponents(gameObject.transform, cmps);
        }
        else
        {
            Transform trans = gameObject.transform;
            if (trans.childCount > 0)
            {
                for (int i = 0; i < trans.childCount; i++)
                {
                    SearchComponents(trans.GetChild(i), cmps);
                }
            }
        }
        return cmps.ToArray();
    }
    /// <summary>
    /// 获取所有子级的第一个T类型组件 (if(self)包括自身,非激活状态可用)
    /// </summary>
    /// <typeparam name="T">组件类型</typeparam>
    /// <param name="gameObject">父级组件</param>
    /// <returns>组件</returns>
    public static T GetComponentInAllChild<T>(this GameObject gameObject, bool self = true) where T : class
    {
        if (self)
        {
            return SearchComponent<T>(gameObject.transform);
        }
        T cmp;
        Transform trans = gameObject.transform;
        for (int i = 0; i < trans.childCount; i++)
        {
            cmp = SearchComponent<T>(trans.GetChild(i));
            if (cmp != null && !cmp.Equals(null)) return cmp;
        }
        return null;
    }
    /// <summary>
    /// 获取所有子级的所有T类型组件 (if(self)包括自身,非激活状态可用)
    /// </summary>
    /// <typeparam name="type">组件类型</typeparam>
    /// <param name="gameObject">父级组件</param>
    /// <returns>组件数组</returns>
    public static Component[] GetComponentsInAllChild(this GameObject gameObject, Type type, bool self = true)
    {
        List<Component> cmps = new List<Component>(4);
        if (self)
        {
            SearchComponents(gameObject.transform, cmps, type);
        }
        else
        {
            Transform trans = gameObject.transform;
            if (trans.childCount > 0)
            {
                for (int i = 0; i < trans.childCount; i++)
                {
                    SearchComponents(trans.GetChild(i), cmps, type);
                }
            }
        }
        return cmps.ToArray();
    }
    /// <summary>
    /// 获取所有子级的第一个T类型组件 (if(self)包括自身,非激活状态可用)
    /// </summary>
    /// <typeparam name="type">组件类型</typeparam>
    /// <param name="gameObject">父级组件</param>
    /// <returns>组件</returns>
    public static Component GetComponentInAllChild(this GameObject gameObject, Type type, bool self = true)
    {
        if (self)
        {
            return SearchComponent(gameObject.transform, type);
        }
        Component cmp;
        Transform trans = gameObject.transform;
        for (int i = 0; i < trans.childCount; i++)
        {
            cmp = SearchComponent(trans.GetChild(i), type);
            if (cmp) return cmp;
        }
        return null;
    }

    /// <summary>
    /// 创建一个预制件到子级
    /// </summary>
    /// <param name="prefab">预制件</param>
    /// <param name="name">设定的名称</param>
    /// <returns></returns>
    public static GameObject AddChild(this GameObject parent, GameObject prefab, string name = "", bool initTrans = true)
    {
        if (!parent || !prefab) return null;
        GameObject go = GameObject.Instantiate(prefab) as GameObject;
        go.name = string.IsNullOrEmpty(name) ? prefab.name : name;
        if (go.GetComponent<UIPanel>() == null && go.layer != parent.layer) NGUITools.SetLayer(go, parent.layer);
        Transform t = go.transform;
        if (initTrans)
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
    /// <summary>
    /// 创建子级gameobject
    /// </summary>
    /// <param name="name">设定的名称</param>
    /// <returns></returns>
    public static GameObject AddChild(this GameObject parent, string name = "", bool initTrans = true)
    {
        if (!parent) return null;
        GameObject go = new GameObject(string.IsNullOrEmpty(name) ? "New GameObject" : name);
        go.layer = parent.layer;
        Transform t = go.transform;
        t.parent = parent.transform;
        if (initTrans)
        {
            t.localPosition = Vector3.zero;
            t.localRotation = Quaternion.identity;
            t.localScale = Vector3.one;
        }
        return go;
    }
    /// <summary>
    /// 创建子级UIWidget
    /// </summary>
    /// <typeparam name="T">组件泛型</typeparam>
    /// <param name="name">名称</param>
    /// <returns></returns>
    public static T AddWidget<T>(this GameObject parent, string name) where T : UIWidget
    {
        if (!parent) return null;
        int depth = NGUITools.CalculateNextDepth(parent);
        T widget = parent.AddChild(string.IsNullOrEmpty(name) ? NGUITools.GetTypeName<T>() : name).AddComponent<T>();
        widget.width = 100;
        widget.height = 100;
        widget.depth = depth;
        widget.gameObject.layer = parent.layer;
        return widget;
    }
    /// <summary>
    /// 创建子级UIWidget
    /// </summary>
    /// <typeparam name="type">组件，必须是UIWidget及其子级</typeparam>
    /// <param name="name">名称</param>
    public static Component AddWidget(this GameObject parent, Type type, string name = "")
    {
        if (parent == null || type == null) return null;
        int depth = NGUITools.CalculateNextDepth(parent);
        if (string.IsNullOrEmpty(name))
        {
            name = type.ToString();
            if (name.StartsWith("UI")) name = name.Substring(2);
            else if (name.StartsWith("UnityEngine.")) name = name.Substring(12);
        }
        Component cmp = parent.AddChild(name).AddComponent(type);
        if (cmp is UIWidget)
        {
            UIWidget widget = cmp as UIWidget;
            widget.width = 100;
            widget.height = 100;
            widget.depth = depth;
            widget.gameObject.layer = parent.layer;
        }
        return cmp;
    }
    /// <summary>
    /// 销毁所有子级
    /// </summary>
    /// <param name="go"></param>
    public static void DestroyChilds(this GameObject go, Transform root = null)
    {
        if (go) go.transform.DestroyAllChild(root);
    }
    #endregion

    #region Component
    /// <summary>
    /// 删除组件，若游戏对象仅有该组件，则删除游戏对象
    /// </summary>
    public static void DestructIfOnly(this Component cmp)
    {
        if (cmp)
        {
            if (cmp.GetComponents<Component>().GetLength() > 2) Object.Destroy(cmp);
            else Object.Destroy(cmp.gameObject);
        }
    }
    /// <summary>
    /// 销毁组件的游戏对象
    /// </summary>
    /// <param name="cmp"></param>
    public static void DestructGameObject(this Component cmp) { if (cmp) Object.Destroy(cmp.gameObject); }
    /// <summary>
    /// 延迟销毁组件的游戏对象
    /// </summary>
    public static void DestructGameObject(this Component cmp, float delay) { if (cmp) Object.Destroy(cmp.gameObject, delay); }
    /// <summary>
    /// 获取所有子级的所有T类型组件(if(self)包括自身,非激活状态可用)
    /// </summary>
    /// <typeparam name="T">组件类型</typeparam>
    /// <param name="component">父级组件</param>
    /// <param name="self">是否包含自身</param>
    /// <returns>组件数组</returns>
    public static T[] GetComponentsInAllChild<T>(this Component component, bool self = true) where T : class
    {
        List<T> cmps = new List<T>(4);
        if (self)
        {
            SearchComponents<T>(component.transform, cmps);
        }
        else
        {
            Transform trans = component.transform;
            if(trans.childCount > 0)
            {
                for (int i = 0; i < trans.childCount; i++)
                {
                    SearchComponents<T>(trans.GetChild(i), cmps);
                }
            }
        }
        return cmps.ToArray();
    }
    
    /// <summary>
    /// 获取所有子级的第一个T类型组件 (if(self)包括自身,非激活状态可用)
    /// </summary>
    /// <typeparam name="T">组件类型</typeparam>
    /// <param name="component">父级组件</param>
    /// <returns>组件</returns>
    public static T GetComponentInAllChild<T>(this Component component, bool self = true) where T : class
    {
        if (self)
        {
            return SearchComponent<T>(component.transform);
        }
        T cmp;
        Transform trans = component.transform;
        for (int i = 0; i < trans.childCount; i++)
        {
            cmp = SearchComponent<T>(trans.GetChild(i));
            if (cmp != null && !cmp.Equals(null)) return cmp;
        }
        return null;
    }
    /// <summary>
    /// 获取所有子级的所有T类型组件(if(self)包括自身,非激活状态可用)
    /// </summary>
    /// <typeparam name="type">组件类型</typeparam>
    /// <param name="component">父级组件</param>
    /// <param name="self">是否包含自身</param>
    /// <returns>组件数组</returns>
    public static Component[] GetComponentsInAllChild(this Component component, Type type, bool self = true)
    {
        List<Component> cmps = new List<Component>(4);
        if (self)
        {
            SearchComponents(component.transform, cmps, type);
        }
        else
        {
            Transform trans = component.transform;
            if (trans.childCount > 0)
            {
                for (int i = 0; i < trans.childCount; i++)
                {
                    SearchComponents(trans.GetChild(i), cmps, type);
                }
            }
        }
        return cmps.ToArray();
    }
    /// <summary>
    /// 获取所有子级的第一个T类型组件 (if(self)包括自身,非激活状态可用)
    /// </summary>
    /// <typeparam name="type">组件类型</typeparam>
    /// <param name="component">父级组件</param>
    /// <returns>组件</returns>
    public static Component GetComponentInAllChild(this Component component, Type type, bool self = true)
    {
        if (self)
        {
            return SearchComponent(component.transform, type);
        }
        Component cmp;
        Transform trans = component.transform;
        for (int i = 0; i < trans.childCount; i++)
        {
            cmp = SearchComponent(trans.GetChild(i), type);
            if (cmp) return cmp;
        }
        return null;
    }
    /// <summary>
    /// 销毁所有子级
    /// </summary>
    public static void DestroyChilds(this Component cmp, Transform root = null)
    {
        if (cmp) cmp.transform.DestroyAllChild(root);
    }
    #endregion

    #region Transform
    /// <summary>
    /// 设置Transform的本地Z值
    /// </summary>
    public static void SetLocalX(this Transform trans, float x)
    {
        if (trans)
        {
            Vector3 pos = trans.localPosition;
            pos.x = x;
            trans.localPosition = pos;
        }
    }
    public static void SetLocalY(this Transform trans, float y)
    {
        if (trans)
        {
            Vector3 pos = trans.localPosition;
            pos.y = y;
            trans.localPosition = pos;
        }
    }
    /// <summary>
    /// 设置Transform的本地Z值
    /// </summary>
    public static void SetLocalZ(this Transform trans, float z)
    {
        if (trans)
        {
            Vector3 pos = trans.localPosition;
            pos.z = z;
            trans.localPosition = pos;
        }
    }
    /// <summary>
    /// 销毁所有子级
    /// </summary>
    public static void DestroyAllChild(this Transform trans, Transform root = null)
    {
        if (trans)
        {
            for (int i = trans.childCount - 1; i >= 0; i--)
            {
                Transform tran = trans.GetChild(i);
                if (tran)
                {
                    tran.gameObject.SetActive(false);
                    tran.parent = root;
                    Object.Destroy(tran.gameObject);
                }
            }
        }
    }
    /// <summary>
    /// 获取当前鼠标位置
    /// </summary>
    public static Vector3 GetMousePosition(this Transform trans, Camera cam = null)
    {
        cam = cam ?? UICamera.currentCamera;
        if (cam && trans)
        {
            return trans.worldToLocalMatrix.MultiplyPoint3x4(cam.ScreenToWorldPoint(Input.mousePosition));
        }
        return Vector3.zero;
    }
    /// <summary>
    /// 获取当前屏幕矩形
    /// </summary>
    public static Rect GetScreenRect(this Transform trans, Camera cam = null)
    {
        cam = cam ?? UICamera.currentCamera;
        if (cam && trans)
        {
            Matrix4x4 m = trans.worldToLocalMatrix;
            Vector3 min = m.MultiplyPoint3x4(cam.ViewportToWorldPoint(Vector3.zero));
            Vector3 max = m.MultiplyPoint3x4(cam.ViewportToWorldPoint(Vector3.one));
            return new Rect(min, max - min);
        }
        return Rect.zero;
    }
    /// <summary>
    /// 搜索所有指定类型的组件
    /// </summary>
    /// <typeparam name="T">组件类型</typeparam>
    /// <param name="trans">根transform</param>
    /// <param name="list">列表缓存</param>
    private static void SearchComponents<T>(this Transform trans, List<T> list) where T : class
    {
        list.AddRange(trans.GetComponents<T>());
        if (trans.childCount > 0)
        {
            for (int i = 0; i < trans.childCount; i++)
            {
                SearchComponents(trans.GetChild(i), list);
            }
        }
    }
    /// <summary>
    /// 搜索所有指定类型的组件
    /// </summary>
    /// <param name="trans">根transform</param>
    /// <param name="list">列表缓存</param>
    /// <param name="type">组件类型</param>
    private static void SearchComponents(this Transform trans, List<Component> list, Type type)
    {
        list.AddRange(trans.GetComponents(type));
        if (trans.childCount > 0)
        {
            for (int i = 0; i < trans.childCount; i++)
            {
                SearchComponents(trans.GetChild(i), list, type);
            }
        }
    }
    /// <summary>
    /// 搜索所有指定类型的组件
    /// </summary>
    /// <typeparam name="T">组件类型</typeparam>
    /// <param name="trans">根transform</param>
    private static T SearchComponent<T>(this Transform trans) where T : class
    {
        T cmp = trans.GetComponent<T>();
        if (cmp != null && !cmp.Equals(null)) return cmp;
        for (int i = 0; i < trans.childCount; i++)
        {
            cmp = SearchComponent<T>(trans.GetChild(i));
            if (cmp != null && !cmp.Equals(null)) return cmp;
        }
        return null;
    }
    /// <summary>
    /// 搜索所有指定类型的组件
    /// </summary>
    /// <param name="trans">根transform</param>
    /// <param name="type">组件类型</param>
    private static Component SearchComponent(this Transform trans, Type type)
    {
        Component cmp = trans.GetComponent(type);
        if (cmp) return cmp;
        for (int i = 0; i < trans.childCount; i++)
        {
            cmp = SearchComponent(trans.GetChild(i), type);
            if (cmp) return cmp;
        }
        return null;
    }
    /// <summary>
    /// 寻找标签对象
    /// </summary>
    /// <param name="tag">标签</param>
    /// <param name="self">是否包含自身</param>
    /// <returns></returns>
    public static Transform FindInParentByTag(this Transform trans, string tag, bool self = true)
    {
        if (trans)
        {
            if (self && trans.CompareTag(tag))
            {
                return trans;
            }

            while (trans = trans.parent)
            {
                if (!trans) break;
                else if (trans.CompareTag(tag))
                {
                    return trans;
                }
            }
        }
        return null;
    }
    /// <summary>
    /// 寻找父级组件包含未激活对象
    /// </summary>
    /// <typeparam name="T">组件泛型</typeparam>
    public static T FindCmpInParent<T>(this Transform trans) where T : Component
    {
        if (trans)
        {
            T cmp = null;
            trans = trans.parent;
            while (trans)
            {
                cmp = trans.GetComponent<T>();
                if (cmp) return cmp;
                trans = trans.parent;
            }
        }
        return null;
    }
    #endregion

    #region Bounds
    /// <summary>
    /// Bounds是否有体积(size的x y z 必须都大于0)
    /// </summary>
    public static bool HasVolume(this Bounds b) { return b.size.x > 0 && b.size.y > 0 && b.size.z > 0; }
    #endregion

    #region Font
    /// <summary>
    /// 获取TTF的字符串宽度,根据UILabel
    /// </summary>
    /// <param name="content">字符串内容</param>
    /// <param name="size">给定的字符尺寸</param>
    /// <param name="maxLineWidth">最大行宽限制，0为不限制</param>
    /// <param name="encoding">是否有颜色编码</param>
    public static float GetStrWidth(this Font font, string content, int size, float maxLineWidth, bool encoding)
    {
        if (font == null || string.IsNullOrEmpty(content) || size <= 0) return 0f;

        float maxVal = 0;
        float curVal = 0;
        if (encoding) content = NGUIText.StripSymbols(content);
        int len = content.Length;
        for (int i = 0; i < len; i++)
        {
            char ch = content[i];
            if (ch == '\n')
            {
                maxVal = Mathf.Max(curVal, maxVal);
                curVal = 0;
                continue;
            }

            if (ch < ' ') continue;

            CharacterInfo ci;
            if (font.GetCharacterInfo(ch, out ci, size)) curVal += ci.advance;
            else
            {
                font.RequestCharactersInTexture(content.Replace("\0", ""), size);
                if (font.GetCharacterInfo(ch, out ci, size)) curVal += ci.advance;
            }
        }
        maxVal = Mathf.Max(curVal, maxVal);
        return maxLineWidth > 0 ? Mathf.Min(maxLineWidth, maxVal) : maxVal;
    }
    #endregion

    #region Material
    public static bool IsMergeShader(this Material mat)
    {
        return mat && mat.shader && (mat.shader.name.StartsWith("Unlit/Merge") || mat.shader.name.StartsWith("Hidden/Unlit/Merge"));
    }
    public static void SetMergeTexture(this Material mat, int index, Texture tex)
    {
        if (index >= 0 && index <= 8 && mat.IsMergeShader())
        {
            if (index == 0)
            {
                mat.mainTexture = tex;
            }
            else
            {
                mat.SetTexture("_tex" + index, tex);
            }
        }
    }
    public static Texture GetMergeTexture(this Material mat, int index)
    {
        if (mat.IsMergeShader())
        {
            if (index == 0) return mat.mainTexture;
            if (index > 0 && index <= 8) return mat.GetTexture("_tex" + index);
            return null;
        }
        return mat ? mat.mainTexture : null;
    }
    #endregion

    #region WWW
    /// <summary>
    /// 是否有资源下载错误，修正了404错误
    /// </summary>
    public static bool HasGetResError(this WWW www)
    {
        if (string.IsNullOrEmpty(www.error))
        {
            string status;
            www.responseHeaders.TryGetValue("STATUS", out status);
            if (string.IsNullOrEmpty(status)) return false;
            if (status.Contains(" 20")) return false;
            if (string.IsNullOrEmpty(www.text) || !www.text.StartsWith("<!DOCTYPE HTML")) return false;
        }
        return true;
    }
    /// <summary>
    /// 是否是未找到错误
    /// </summary>
    public static bool Is404NotFound(this WWW www)
    {
        if (string.IsNullOrEmpty(www.error))
        {
            string status;
            www.responseHeaders.TryGetValue("STATUS", out status);
            if (string.IsNullOrEmpty(status)) return false;
            if (status.Contains("404 Not Found")) return true;
        }
        return www.error == "404 Not Found";
    }
    /// <summary>
    /// 是否是文件长度错误
    /// </summary>
    public static bool IsBadFileLength(this WWW www)
    {
        return string.IsNullOrEmpty(www.error) ? false : www.error.StartsWith("Bad file length");
    }
    #endregion

    #region Vector3
    /// <summary>
    /// 一个向量围绕一个轴向量旋转一个角度得到的新向量
    /// </summary>
    /// <param name="vector">旋转向量</param>
    /// <param name="axis">轴向量</param>
    /// <param name="angle">旋转角度</param>
    /// <returns>旋转后的向量</returns>
    public static Vector3 RotateAxis(this Vector3 vector, Vector3 axis, float angle)
    {
        float x1 = vector.x;
        float y1 = vector.y;
        float z1 = vector.z;

        float x2 = axis.x;
        float y2 = axis.y;
        float z2 = axis.z;

        float D1 = x1 * x1 + y1 * y1 + z1 * z1;
        float D2 = x2 * x2 + y2 * y2 + z2 * z2;
        float E = x1 * x2 + y1 * y2 + z1 * z2;
        float cos2 = (E * E) / (D1 * D2);
        if (D1 == 0f || D2 == 0f || cos2 == 1f)
        {
            //Debug.LogWarning("旋转点/轴点在坐标原点上，或者旋转点在旋转轴上");
            return vector;
        }

        float A = E / D2;
        float xd = A * x2;
        float yd = A * y2;
        float zd = A * z2;

        float cosa = Mathf.Cos(angle);
        float sina = Mathf.Sin(angle);

        float xr = x1 - xd;
        float yr = y1 - yd;
        float zr = z1 - zd;

        //Vector3 result = new Vector3();
        float x = 0f;
        float y = 0f;
        float z = 0f;
        x = xr * cosa + ((yr * z2 - zr * y2) / Mathf.Sqrt(D2)) * sina + xd;
        y = yr * cosa + ((zr * x2 - xr * z2) / Mathf.Sqrt(D2)) * sina + yd;
        z = zr * cosa + ((xr * y2 - yr * x2) / Mathf.Sqrt(D2)) * sina + zd;
        x = Mathf.Abs(x) < 1e-10 ? 0f : x;
        y = Mathf.Abs(y) < 1e-10 ? 0f : y;
        z = Mathf.Abs(z) < 1e-10 ? 0f : z;
        return new Vector3(x, y, z);
    }
    /// <summary>
    /// 一个向量围绕X轴旋转一个角度
    /// </summary>
    /// <param name="vector">旋转向量</param>
    /// <param name="angleX">旋转角度</param>
    /// <returns>旋转后的向量</returns>
    public static Vector3 RotateX(this Vector3 vector, float angleX)
    {
        float y = vector.y;
        float z = vector.z;
        float y1 = y * Mathf.Cos(angleX) - z * Mathf.Sin(angleX);
        float z1 = z * Mathf.Cos(angleX) + y * Mathf.Sin(angleX);
        y = Mathf.Abs(y1) < 1e-10 ? 0f : y1;
        z = Mathf.Abs(z1) < 1e-10 ? 0f : z1;
        return new Vector3(vector.x, y, z);
    }
    /// <summary>
    /// 一个向量围绕Y轴旋转一个角度
    /// </summary>
    /// <param name="vector">旋转向量</param>
    /// <param name="angleY">旋转角度</param>
    /// <returns>旋转后的向量</returns>
    public static Vector3 RotateY(this Vector3 vector, float angleY)
    {
        float x = vector.x;
        float z = vector.z;
        float x1 = x * Mathf.Cos(angleY) - z * Mathf.Sin(angleY);
        float z1 = z * Mathf.Cos(angleY) + x * Mathf.Sin(angleY);
        x = Mathf.Abs(x1) < 1e-10 ? 0f : x1;
        z = Mathf.Abs(z1) < 1e-10 ? 0f : z1;
        return new Vector3(x, vector.y, z);
    }
    /// <summary>
    /// 一个向量围绕Z轴旋转一个角度
    /// </summary>
    /// <param name="vector">旋转向量</param>
    /// <param name="angleZ">旋转角度</param>
    /// <returns>旋转后的向量</returns>
    public static Vector3 RotateZ(this Vector3 vector, float angleZ)
    {
        float x = vector.x;
        float y = vector.y;

        float x1 = x * Mathf.Cos(angleZ) - y * Mathf.Sin(angleZ);
        float y1 = y * Mathf.Cos(angleZ) + x * Mathf.Sin(angleZ);
        x = Mathf.Abs(x1) < 1e-10 ? 0f : x1;
        y = Mathf.Abs(y1) < 1e-10 ? 0f : y1;
        return new Vector3(x, y, vector.z);
    }
    #endregion
}
