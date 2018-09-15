#if TOLUA
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

public class UILuaWidget : UIWidget
{
    [SerializeField] private Texture mTexture;
    [SerializeField] private Shader mShader;
    [SerializeField] private LuaContainer mLua;
    [SerializeField] private string mOnFill;
    [System.NonSerialized] private LuaFunction mOnFillFunc;
    [System.NonSerialized] private List<Vector3> mVerts = new List<Vector3>(4);
    [System.NonSerialized] private List<Vector2> mUVs = new List<Vector2>(4);
    [System.NonSerialized] private List<Color> mColors = new List<Color>(4);

    public LuaContainer luaContainer
    {
        get
        {
            return mLua;
        }
        set
        {
            if (mLua == value) return;
            if (mLua)
            {
                mLua.onBindToLua -= OnBindToLua;
                mLua.onBindFunctionReplaced -= OnBindFunctionReplaced;
            }
            if (mOnFillFunc != null && string.IsNullOrEmpty(mOnFillFunc.bindName)) mOnFillFunc.Dispose();
            mLua = value;
            if (mLua)
            {
                mLua.onBindToLua += OnBindToLua;
                mLua.onBindFunctionReplaced += OnBindFunctionReplaced;
                OnBindToLua();
            }
        }
    }

    private bool NoFunction(ref LuaFunction func)
    {
        if (func == null) return true;
        if (func.IsAlive) return false;
        if (mLua == null) return true;
        func = mLua.GetBindFunction(func.bindName);
        return func == null;
    }

    private void OnBindToLua()
    {
        if (mLua == null) return;
        if (!string.IsNullOrEmpty(mOnFill)) mOnFillFunc = mLua.GetBindFunction(mOnFill);
    }
    private void OnBindFunctionReplaced(string func)
    {
        if (mOnFill == func) SetOnFill(func);
    }

    public void SetOnFill(string func)
    {
        mOnFill = func;
        if (mOnFillFunc != null && string.IsNullOrEmpty(mOnFillFunc.bindName)) mOnFillFunc.Dispose();
        mOnFillFunc = mLua ? mLua.GetBindFunction(func) : null;
    }

    public void SetOnFill(LuaFunction func)
    {
        mOnFill = func == null ? null : func.bindName;
        if (mOnFillFunc != null && string.IsNullOrEmpty(mOnFillFunc.bindName)) mOnFillFunc.Dispose();
        mOnFillFunc = func;
    }

    protected override void OnStart()
    {
        base.OnStart();

        if (mLua)
        {
            mLua.onBindToLua += OnBindToLua;
            mLua.onBindFunctionReplaced += OnBindFunctionReplaced;
            OnBindToLua();
        }
    }

    private void OnDestroy()
    {
        luaContainer = null;
        RemoveFromPanel();
    }

    public override Texture mainTexture
    {
        get
        {
            if (mTexture != null) return mTexture;
            if (mMat != null) return mMat.mainTexture;
            return null;
        }
        set
        {
            if (mTexture != value)
            {
                if (drawCall != null && drawCall.widgetCount == 1 && mMat == null)
                {
                    mTexture = value;
                    drawCall.mainTexture = value;
                }
                else
                {
                    RemoveFromPanel();
                    mTexture = value;
                    MarkAsChanged();
                }
            }
        }
    }

    public override Material material
    {
        get
        {
            return mMat;
        }
        set
        {
            if (mMat != value)
            {
                RemoveFromPanel();
                mShader = null;
                mMat = value;
                MarkAsChanged();
            }
        }
    }

    public override Shader shader
    {
        get
        {
            if (mMat != null) return mMat.shader;
            if (mShader == null) mShader = Shader.Find("Unlit/Transparent Colored");
            return mShader;
        }
        set
        {
            if (mShader != value)
            {
                if (drawCall != null && drawCall.widgetCount == 1 && mMat == null)
                {
                    mShader = value;
                    drawCall.shader = value;
                }
                else
                {
                    RemoveFromPanel();
                    mShader = value;
                    mMat = null;
                    MarkAsChanged();
                }
            }
        }
    }

    public List<Vector3> verts { get { return mVerts; } }
    public List<Vector2> uvs { get { return mUVs; } }
    public List<Color> cols { get { return mColors; } }

    public override void OnFill(List<Vector3> verts, List<Vector2> uvs, List<Color> cols)
    {
        if (mainTexture == null)
        {
            return;
        }

        int offset = 0;

        if (NoFunction(ref mOnFillFunc))
        {
            if (mVerts.Count >= 4 && mUVs.Count >= 4 && mColors.Count > 4)
            {
                verts.AddRange(mVerts);
                uvs.AddRange(mUVs);
                cols.AddRange(mColors);
            }
        }
        else
        {
            mOnFillFunc.BeginPCall();
            if (mLua && mLua.isInstance) mOnFillFunc.Push(mLua.luaTable);
            mOnFillFunc.Push(verts);
            mOnFillFunc.Push(uvs);
            mOnFillFunc.Push(cols);
            mOnFillFunc.PCall();
            mOnFillFunc.EndPCall();
        }

        if (onPostFill != null) onPostFill(this, offset, verts, uvs, cols);
    }

    #region LUA注册
    [NoToLua]
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(UILuaWidget), typeof(UIWidget));
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("SetOnFill", SetOnFill);
        L.RegVar("luaContainer", get_luaContainer, set_luaContainer);
        L.RegVar("verts", get_verts, null);
        L.RegVar("uvs", get_uvs, null);
        L.RegVar("cols", get_cols, null);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetOnFill(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);
            if (count >= 2)
            {
                UILuaWidget w = ToLua.CheckObject<UILuaWidget>(lua, 1) as UILuaWidget;
                if (LuaTypes.LUA_TFUNCTION == LuaDLL.lua_type(lua, 2))
                {
                    w.SetOnFill(ToLua.ToLuaFunction(lua, 2));
                }
                else
                {
                    w.SetOnFill(ToLua.CheckString(lua, 2));
                }
                return 0;
            }

            return LuaDLL.luaL_throw(lua, "invalid arguments to method: UILuaWidget.SetOnFill");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_luaContainer(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(UILuaWidget), 1))
            {
                ToLua.Push(lua, ((UILuaWidget)ToLua.ToObject(lua, 1)).mLua);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: UILuaWidget.GetLuaContainer");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_luaContainer(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(UILuaWidget), typeof(LuaContainer)))
            {
                ((UILuaWidget)ToLua.ToObject(lua, 1)).luaContainer = (LuaContainer)ToLua.ToObject(lua, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: UILuaWidget.SetLuaContainer");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_verts(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(UILuaWidget), 1))
            {
                ToLua.Push(lua, ((UILuaWidget)ToLua.ToObject(lua, 1)).mVerts);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: UILuaWidget.get_verts");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_uvs(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(UILuaWidget), 1))
            {
                ToLua.Push(lua, ((UILuaWidget)ToLua.ToObject(lua, 1)).mUVs);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: UILuaWidget.get_uvs");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_cols(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(UILuaWidget), 1))
            {
                ToLua.Push(lua, ((UILuaWidget)ToLua.ToObject(lua, 1)).mColors);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: UILuaWidget.get_cols");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int op_Equality(System.IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            LuaDLL.lua_pushboolean(L, (ToLua.ToObject(L, 1) as Object) == (ToLua.ToObject(L, 2) as Object));
            return 1;
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion
}
#endif