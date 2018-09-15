#if TOLUA
using UnityEngine;
using System;
using LuaInterface;

public class LuaButton : MonoBehaviour
{
    [SerializeField] private LuaContainer mLuaContainer;
    [SerializeField] private UIButtonColor mNguiButton;
    [SerializeField] private UILabel mLbl;
    [SerializeField] public bool mTransferSelf = false;
    [SerializeField] private UnityEngine.Object mTransfer;
    [SerializeField] private string mOnClick;
    [SerializeField] private string mOnDoubleClick;
    [SerializeField] private string mOnPress;
    [SerializeField] private string mOnDrag;
    [SerializeField] private string mOnSelect;
    [SerializeField] private string mOnScroll;
    [SerializeField] private string mOnTooltip;

    [NonSerialized] private LuaFunction mOnClickLua;
    [NonSerialized] private LuaFunction mOnDoubleClickLua;
    [NonSerialized] private LuaFunction mOnDragLua;
    [NonSerialized] private LuaFunction mOnPressLua;
    [NonSerialized] private LuaFunction mOnSelectLua;
    [NonSerialized] private LuaFunction onScrollLua;
    [NonSerialized] private LuaFunction onTooltipLua;

    [NonSerialized] private object mParam;

    private void Awake()
    {
        if (mNguiButton == null) mNguiButton = GetComponent<UIButtonColor>();
        if (mLbl == null) mLbl = GetComponent<UILabel>() ?? GetComponentInChildren<UILabel>(true);
    }

    private void Start()
    {
        //if (mLuaContainer == null) mLuaContainer = GetComponentInParent<LuaContainer>();
        if (mLuaContainer)
        {
            mLuaContainer.onBindToLua += OnBindToLua;
            mLuaContainer.onBindFunctionReplaced += OnBindFunctionReplaced;
            OnBindToLua();
        }
    }

    private void OnDestroy()
    {
        param = null;
        SetContainer(null);
    }

    private bool NoFunction(ref LuaFunction func)
    {
        if (func == null) return true;
        if (func.IsAlive) return false;
        if (mLuaContainer == null) return true;
        func = mLuaContainer.GetBindFunction(func.bindName);
        return func == null;
    }

    /****************************容器事件****************************/
    private void OnBindToLua()
    {
        if (mLuaContainer == null) return;
        if (!string.IsNullOrEmpty(mOnClick)) mOnClickLua = mLuaContainer.GetBindFunction(mOnClick);
        if (!string.IsNullOrEmpty(mOnDoubleClick)) mOnDoubleClickLua = mLuaContainer.GetBindFunction(mOnDoubleClick);
        if (!string.IsNullOrEmpty(mOnPress)) mOnPressLua = mLuaContainer.GetBindFunction(mOnPress);
        if (!string.IsNullOrEmpty(mOnDrag)) mOnDragLua = mLuaContainer.GetBindFunction(mOnDrag);
        if (!string.IsNullOrEmpty(mOnSelect)) mOnSelectLua = mLuaContainer.GetBindFunction(mOnSelect);
        if (!string.IsNullOrEmpty(mOnScroll)) onScrollLua = mLuaContainer.GetBindFunction(mOnScroll);
        if (!string.IsNullOrEmpty(mOnTooltip)) onTooltipLua = mLuaContainer.GetBindFunction(mOnTooltip);
    }
    private void OnBindFunctionReplaced(string func)
    {
        if (mOnClick == func) SetClick(func);
        else if (mOnDoubleClick == func) SetDoubleClick(func);
        else if (mOnPress == func) SetPress(func);
        else if (mOnDrag == func) SetDrag(func);
        else if (mOnSelect == func) SetSelect(func);
        else if (mOnScroll == func) SetScroll(func);
        else if (mOnTooltip == func) SetTooltip(func);
    }
    /****************************事件****************************/
    void OnClick()
    {
        if (NoFunction(ref mOnClickLua)) return;
        mOnClickLua.BeginPCall();
        if (mLuaContainer && mLuaContainer.isInstance) mOnClickLua.Push(mLuaContainer.luaTable);
        if (mTransfer) mOnClickLua.Push(mTransfer);
        if (mParam != null) mOnClickLua.Push(mParam);
        mOnClickLua.PCall();
        mOnClickLua.EndPCall();
    }

    void OnDoubleClick()
    {
        if (NoFunction(ref mOnDoubleClickLua)) return;
        mOnDoubleClickLua.BeginPCall();
        if (mLuaContainer && mLuaContainer.isInstance) mOnDoubleClickLua.Push(mLuaContainer.luaTable);
        if (mTransfer) mOnDoubleClickLua.Push(mTransfer);
        if (mParam != null) mOnDoubleClickLua.Push(mParam);
        mOnDoubleClickLua.PCall();
        mOnDoubleClickLua.EndPCall();
    }

    void OnPress(bool pressed)
    {
        if (NoFunction(ref mOnPressLua)) return;
        mOnPressLua.BeginPCall();
        if (mLuaContainer.isInstance) mOnPressLua.Push(mLuaContainer.luaTable);
        mOnPressLua.Push(pressed);
        if (mTransfer) mOnPressLua.Push(mTransfer);
        if (mParam != null) mOnPressLua.Push(mParam);
        mOnPressLua.PCall();
        mOnPressLua.EndPCall();
    }

    void OnSelect(bool selected)
    {
        if (enabled)
        {
            if (NoFunction(ref mOnSelectLua)) return;
            mOnSelectLua.BeginPCall();
            if (mLuaContainer && mLuaContainer.isInstance) mOnSelectLua.Push(mLuaContainer.luaTable);
            mOnSelectLua.Push(selected);
            if (mTransfer) mOnSelectLua.Push(mTransfer);
            if (mParam != null) mOnSelectLua.Push(mParam);
            mOnSelectLua.PCall();
            mOnSelectLua.EndPCall();
        }
    }

    void OnDrag(Vector2 delta)
    {
        if (enabled)
        {
            if (NoFunction(ref mOnDragLua)) return;
            mOnDragLua.BeginPCall();
            if (mLuaContainer && mLuaContainer.isInstance) mOnDragLua.Push(mLuaContainer.luaTable);
            mOnDragLua.Push(delta);
            if (mTransfer) mOnDragLua.Push(mTransfer);
            if (mParam != null) mOnDragLua.Push(mParam);
            mOnDragLua.PCall();
            mOnDragLua.EndPCall();
        }
    }

    void OnScroll(float delta)
    {
        if (enabled)
        {
            if (NoFunction(ref onScrollLua)) return;
            onScrollLua.BeginPCall();
            if (mLuaContainer && mLuaContainer.isInstance) mOnClickLua.Push(mLuaContainer.luaTable);
            onScrollLua.Push(delta);
            if (mTransfer) onScrollLua.Push(mTransfer);
            if (mParam != null) onScrollLua.Push(mParam);
            onScrollLua.PCall();
            onScrollLua.EndPCall();
        }
    }

    void OnTooltip(bool show)
    {
        if (enabled)
        {
            if (NoFunction(ref onTooltipLua)) return;
            onTooltipLua.BeginPCall();
            if (mLuaContainer && mLuaContainer.isInstance) mOnClickLua.Push(mLuaContainer.luaTable);
            onTooltipLua.Push(show);
            if (mTransfer) onTooltipLua.Push(mTransfer);
            if (mParam != null) onTooltipLua.Push(mParam);
            onTooltipLua.PCall();
            onTooltipLua.EndPCall();
        }
    }

    /****************************CS设置****************************/
    private void DisposeFunc(LuaFunction func)
    {
        if (func != null && string.IsNullOrEmpty(func.bindName)) func.Dispose();
    }
    public void ClearEvent()
    {
        param = null;
        if (mOnClickLua != null && string.IsNullOrEmpty(mOnClickLua.bindName)) mOnClickLua.Dispose();
        if (mOnDoubleClickLua != null && string.IsNullOrEmpty(mOnDoubleClickLua.bindName)) mOnDoubleClickLua.Dispose();
        if (mOnDragLua != null && string.IsNullOrEmpty(mOnDragLua.bindName)) mOnDragLua.Dispose();
        if (mOnPressLua != null && string.IsNullOrEmpty(mOnPressLua.bindName)) mOnPressLua.Dispose();
        if (mOnSelectLua != null && string.IsNullOrEmpty(mOnSelectLua.bindName)) mOnSelectLua.Dispose();
        if (onScrollLua != null && string.IsNullOrEmpty(onScrollLua.bindName)) onScrollLua.Dispose();
        if (onTooltipLua != null && string.IsNullOrEmpty(onTooltipLua.bindName)) onTooltipLua.Dispose();
        mOnClick = null;
        mOnClickLua = null;
        mOnDoubleClick = null;
        mOnDoubleClickLua = null;
        mOnDrag = null;
        mOnDragLua = null;
        mOnPress = null;
        mOnPressLua = null;
        mOnSelect = null;
        mOnSelectLua = null;
        mOnScroll = null;
        onScrollLua = null;
        mOnTooltip = null;
        onTooltipLua = null;
    }

    public void SetContainer(LuaContainer lc)
    {
        if (lc == mLuaContainer) return;
        if (mLuaContainer)
        {
            mLuaContainer.onBindToLua -= OnBindToLua;
            mLuaContainer.onBindFunctionReplaced -= OnBindFunctionReplaced;
        }
        if (mOnClickLua != null && string.IsNullOrEmpty(mOnClickLua.bindName)) mOnClickLua.Dispose();
        if (mOnDoubleClickLua != null && string.IsNullOrEmpty(mOnDoubleClickLua.bindName)) mOnDoubleClickLua.Dispose();
        if (mOnDragLua != null && string.IsNullOrEmpty(mOnDragLua.bindName)) mOnDragLua.Dispose();
        if (mOnPressLua != null && string.IsNullOrEmpty(mOnPressLua.bindName)) mOnPressLua.Dispose();
        if (mOnSelectLua != null && string.IsNullOrEmpty(mOnSelectLua.bindName)) mOnSelectLua.Dispose();
        if (onScrollLua != null && string.IsNullOrEmpty(onScrollLua.bindName)) onScrollLua.Dispose();
        if (onTooltipLua != null && string.IsNullOrEmpty(onTooltipLua.bindName)) onTooltipLua.Dispose();
        mLuaContainer = lc;
        if (mLuaContainer)
        {
            mLuaContainer.onBindToLua += OnBindToLua;
            mLuaContainer.onBindFunctionReplaced += OnBindFunctionReplaced;
            OnBindToLua();
        }
    }

    public void SetClick(string func)
    {
        mOnClick = func;
        if (mOnClickLua != null && string.IsNullOrEmpty(mOnClickLua.bindName)) mOnClickLua.Dispose();
        mOnClickLua = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }
    public void SetClick(LuaFunction func)
    {
        mOnClick = func == null ? null : func.bindName;
        if (mOnClickLua != null && string.IsNullOrEmpty(mOnClickLua.bindName)) mOnClickLua.Dispose();
        mOnClickLua = func;
    }
   
    public void SetDoubleClick(string func)
    {
        if (mOnDoubleClickLua != null && string.IsNullOrEmpty(mOnDoubleClickLua.bindName)) mOnDoubleClickLua.Dispose();
        mOnDoubleClickLua = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }
    public void SetDoubleClick(LuaFunction func)
    {
        mOnDoubleClick = func == null ? null : func.bindName;
        if (mOnDoubleClickLua != null && string.IsNullOrEmpty(mOnDoubleClickLua.bindName)) mOnDoubleClickLua.Dispose();
        mOnDoubleClickLua = func;
    }
    public void SetPress(string func)
    {
        mOnPress = func;
        if (mOnPressLua != null && string.IsNullOrEmpty(mOnPressLua.bindName)) mOnPressLua.Dispose();
        mOnPressLua = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }
    public void SetPress(LuaFunction func)
    {
        mOnPress = func == null ? null : func.bindName;
        if (mOnPressLua != null && string.IsNullOrEmpty(mOnPressLua.bindName)) mOnPressLua.Dispose();
        mOnPressLua = func;
    }
    public void SetDrag(string func)
    {
        mOnDrag = func;
        if (mOnDragLua != null && string.IsNullOrEmpty(mOnDragLua.bindName)) mOnDragLua.Dispose();
        mOnDragLua = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }
    public void SetDrag(LuaFunction func)
    {
        mOnDrag = func == null ? null : func.bindName;
        if (mOnDragLua != null && string.IsNullOrEmpty(mOnDragLua.bindName)) mOnDragLua.Dispose();
        mOnDragLua = func;
    }
    public void SetSelect(string func)
    {
        mOnSelect = func;
        if (mOnSelectLua != null && string.IsNullOrEmpty(mOnSelectLua.bindName)) mOnSelectLua.Dispose();
        mOnSelectLua = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }
    public void SetSelect(LuaFunction func)
    {
        mOnSelect = func == null ? null : func.bindName;
        if (mOnSelectLua != null && string.IsNullOrEmpty(mOnSelectLua.bindName)) mOnSelectLua.Dispose();
        mOnSelectLua = func;
    }
    public void SetTooltip(string func)
    {
        mOnTooltip = func;
        if (onTooltipLua != null && string.IsNullOrEmpty(onTooltipLua.bindName)) onTooltipLua.Dispose();
        onTooltipLua = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }
    public void SetTooltip(LuaFunction func)
    {
        mOnTooltip = func == null ? null : func.bindName;
        if (onTooltipLua != null && string.IsNullOrEmpty(onTooltipLua.bindName)) onTooltipLua.Dispose();
        onTooltipLua = func;
    }
    public void SetScroll(string func)
    {
        mOnScroll = func;
        if (onScrollLua != null && string.IsNullOrEmpty(onScrollLua.bindName)) onScrollLua.Dispose();
        onScrollLua = mLuaContainer ? mLuaContainer.GetBindFunction(func) : null;
    }
    public void SetScroll(LuaFunction func)
    {
        mOnScroll = func == null ? null : func.bindName;
        if (onScrollLua != null && string.IsNullOrEmpty(onScrollLua.bindName)) onScrollLua.Dispose();
        onScrollLua = func;
    }
    /****************************附加参数****************************/
    public UnityEngine.Object transfer { get { return mTransfer; } set { mTransfer = value; } }

    public object param
    {
        get { return mParam; }
        private set
        {
            if (mParam is LuaBaseRef)
            {
                (mParam as LuaBaseRef).Dispose();
            }
            mParam = value;
        }
    }

    #region Lua注册
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(LuaButton), typeof(MonoBehaviour));
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegFunction("ClearEvent", ClearEvent);
        L.RegFunction("SetClick", SetClick);
        L.RegFunction("SetDoubleClick", SetDoubleClick);
        L.RegFunction("SetPress", SetPress);
        L.RegFunction("SetSelect", SetSelect);
        L.RegFunction("SetTooltip", SetTooltip);
        L.RegFunction("SetDrag", SetDrag);
        L.RegFunction("SetScroll", SetScroll);
        L.RegVar("luaContainer", tet_luaContainer, set_luaContainer);
        L.RegVar("transferSelf", get_transferSelf, set_transferSelf);
        L.RegVar("transfer", get_transfer, set_transfer);
        L.RegVar("param", get_param, set_param);
        L.RegVar("isEnabled", get_isEnabled, set_isEnabled);
        L.RegVar("label", get_label, set_label);
        L.RegVar("text", get_text, set_text);
        L.RegVar("labelColor", get_labelColor, set_labelColor);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ClearEvent(System.IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            
            if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(LuaButton)))
            {
                ((LuaButton)ToLua.ToObject(L, 1)).ClearEvent();
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: Button.ClearEvent");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetClick(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);
            if (count >= 2)
            {
                LuaButton btn = ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton;
                if (LuaTypes.LUA_TFUNCTION == LuaDLL.lua_type(lua, 2))
                {
                    btn.SetClick(ToLua.ToLuaFunction(lua, 2));
                }
                else
                {
                    btn.SetClick(ToLua.CheckString(lua, 2));
                }
                if (count >= 3)
                {
                    btn.param = ToLua.ToVarObject(lua, 3);
                }
                return 0;
            }
            
           
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaButton.SetClick");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetDoubleClick(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);
            if (count >= 2)
            {
                LuaButton btn = ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton;
                if (LuaTypes.LUA_TFUNCTION == LuaDLL.lua_type(lua, 2))
                {
                    btn.SetDoubleClick(ToLua.ToLuaFunction(lua, 2));
                }
                else
                {
                    btn.SetDoubleClick(ToLua.CheckString(lua, 2));
                }
                if (count >= 3)
                {
                    btn.param = ToLua.ToVarObject(lua, 3);
                }
                return 0;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaButton.SetDoubleClick");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetPress(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);
            if (count >= 2)
            {
                LuaButton btn = ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton;
                if (LuaTypes.LUA_TFUNCTION == LuaDLL.lua_type(lua, 2))
                {
                    btn.SetPress(ToLua.ToLuaFunction(lua, 2));
                }
                else
                {
                    btn.SetPress(ToLua.CheckString(lua, 2));
                }
                if (count >= 3)
                {
                    btn.param = ToLua.ToVarObject(lua, 3);
                }
                return 0;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaButton.SetPress");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetSelect(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);
            if (count >= 2)
            {
                LuaButton btn = ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton;
                if (LuaTypes.LUA_TFUNCTION == LuaDLL.lua_type(lua, 2))
                {
                    btn.SetSelect(ToLua.ToLuaFunction(lua, 2));
                }
                else
                {
                    btn.SetSelect(ToLua.CheckString(lua, 2));
                }
                if (count >= 3)
                {
                    btn.param = ToLua.ToVarObject(lua, 3);
                }
                return 0;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaButton.SetSelect");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetTooltip(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);
            if (count >= 2)
            {
                LuaButton btn = ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton;
                if (LuaTypes.LUA_TFUNCTION == LuaDLL.lua_type(lua, 2))
                {
                    btn.SetTooltip(ToLua.ToLuaFunction(lua, 2));
                }
                else
                {
                    btn.SetTooltip(ToLua.CheckString(lua, 2));
                }
                if (count >= 3)
                {
                    btn.param = ToLua.ToVarObject(lua, 3);
                }
                return 0;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaButton.SetTooltip");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetDrag(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);
            if (count >= 2)
            {
                LuaButton btn = ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton;
                if (LuaTypes.LUA_TFUNCTION == LuaDLL.lua_type(lua, 2))
                {
                    btn.SetDrag(ToLua.ToLuaFunction(lua, 2));
                }
                else
                {
                    btn.SetDrag(ToLua.CheckString(lua, 2));
                }
                if (count >= 3)
                {
                    btn.param = ToLua.ToVarObject(lua, 3);
                }
                return 0;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaButton.SetDrag");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetScroll(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);
            if (count >= 2)
            {
                LuaButton btn = ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton;
                if (LuaTypes.LUA_TFUNCTION == LuaDLL.lua_type(lua, 2))
                {
                    btn.SetScroll(ToLua.ToLuaFunction(lua, 2));
                }
                else
                {
                    btn.SetScroll(ToLua.CheckString(lua, 2));
                }
                if (count >= 3)
                {
                    btn.param = ToLua.ToVarObject(lua, 3);
                }
                return 0;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: LuaButton.SetScroll");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_transferSelf(System.IntPtr lua)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(lua))
            {
                LuaDLL.lua_pushboolean(lua, (ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton).mTransfer);
                return 1;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.get_transferSelf");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_transferSelf(System.IntPtr lua)
    {
        try
        {
            if (2 == LuaDLL.lua_gettop(lua))
            {
                LuaButton btn = ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton;
                btn.mTransfer = LuaDLL.luaL_checkboolean(lua, 2) ? btn : null;
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.set_transferSelf");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_transfer(System.IntPtr lua)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(lua))
            {
                ToLua.Push(lua, (ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton).mTransfer);
                return 1;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.get_transfer");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_transfer(System.IntPtr lua)
    {
        try
        {
            if (2 == LuaDLL.lua_gettop(lua))
            {
                LuaButton btn = ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton;
                LuaTypes luaType = LuaDLL.lua_type(lua, 2);
                if (luaType == LuaTypes.LUA_TBOOLEAN)
                {
                    btn.mTransfer = LuaDLL.tolua_toboolean(lua, 2) ? btn.mTransfer ?? btn : null;
                    return 0;

                }
                else if (luaType == LuaTypes.LUA_TUSERDATA)
                {
                    btn.mTransfer = ToLua.CheckObject<UnityEngine.Object>(lua, 2) as UnityEngine.Object;
                    return 0;
                }
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.set_transfer");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int tet_luaContainer(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(LuaButton), 1))
            {
                ToLua.Push(lua, ((LuaButton)ToLua.ToObject(lua, 1)).mLuaContainer);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.GetLuaContainer");
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

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(LuaButton), typeof(LuaContainer)))
            {
                ((LuaButton)ToLua.ToObject(lua, 1)).SetContainer((LuaContainer)ToLua.ToObject(lua, 2));
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.SetLuaContainer");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_param(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(LuaButton), 1))
            {
                ToLua.Push(lua, ((LuaButton)ToLua.ToVarObject(lua, 1)).mParam);
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.GetParam");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_param(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(LuaButton)))
            {
                ((LuaButton)ToLua.ToObject(lua, 1)).param = ToLua.ToVarObject(lua, 2);
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.SetParam");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isEnabled(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 1 && TypeChecker.CheckType(lua, typeof(LuaButton), 1))
            {
                LuaButton btn = ToLua.ToVarObject(lua, 1) as LuaButton;
                if (btn.mNguiButton)
                {
                    ToLua.Push(lua, btn.mNguiButton.isEnabled);
                }
                else if (btn.GetComponent<Collider>())
                {
                    ToLua.Push(lua, btn.GetComponent<Collider>().enabled);
                }
                else
                {
                    ToLua.Push(lua, false);
                }
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.GetIsEnabled");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_isEnabled(System.IntPtr lua)
    {
        try
        {
            int count = LuaDLL.lua_gettop(lua);

            if (count == 2 && TypeChecker.CheckTypes(lua, 1, typeof(LuaButton), typeof(bool)))
            {
                LuaButton btn = ToLua.ToVarObject(lua, 1) as LuaButton;
                if (btn.mNguiButton)
                {
                    btn.mNguiButton.isEnabled = LuaDLL.lua_toboolean(lua, 2);
                }
                else if (btn.GetComponent<Collider>())
                {
                    btn.GetComponent<Collider>().enabled = LuaDLL.lua_toboolean(lua, 2);
                }
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.isEnabled");
            }
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_label(System.IntPtr lua)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(lua))
            {
                ToLua.Push(lua, (ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton).mLbl); return 1;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.get_label");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_label(System.IntPtr lua)
    {
        try
        {
            if (2 == LuaDLL.lua_gettop(lua))
            {
                (ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton).mLbl = ToLua.CheckObject<UILabel>(lua, 2) as UILabel;
                return 0;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.set_label");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_text(System.IntPtr lua)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(lua))
            {
                UILabel lbl = (ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton).mLbl;
                ToLua.Push(lua, lbl ? lbl.text : null); return 1;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.get_text");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_text(System.IntPtr lua)
    {
        try
        {
            if (2 == LuaDLL.lua_gettop(lua))
            {
                UILabel lbl = (ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton).mLbl;
                if (lbl) lbl.text = ToLua.CheckString(lua, 2);
                return 0;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.set_text");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_labelColor(System.IntPtr lua)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(lua))
            {
                UILabel lbl = (ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton).mLbl;
                if (lbl)
                {
                    ToLua.Push(lua, lbl.color);
                }
                else
                {
                    LuaDLL.lua_pushnil(lua);
                }
                return 1;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.get_labelColor");
        }
        catch (System.Exception e)
        {
            return LuaDLL.toluaL_exception(lua, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_labelColor(System.IntPtr lua)
    {
        try
        {
            if (2 == LuaDLL.lua_gettop(lua))
            {
                UILabel lbl = (ToLua.CheckObject<LuaButton>(lua, 1) as LuaButton).mLbl;
                if (lbl) lbl.color = ToLua.CheckColor(lua, 2);
                return 0;
            }
            return LuaDLL.luaL_throw(lua, "invalid arguments to method: Button.set_labelColor");
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
            UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
            UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
            bool o = arg0 == arg1;
            LuaDLL.lua_pushboolean(L, o);
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