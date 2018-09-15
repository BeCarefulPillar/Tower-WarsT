#if TOLUA
using System;
using System.Collections;
using UnityEngine;
using LuaInterface;

public partial class Win : LuaContainer
{
    private const int LS_Init = 0;
    private const int LS_Entering = 1;
    private const int LS_Entered = 2;
    private const int LS_Exting = 3;
    private const int LS_Exted = 4;

    private const string Func_OnInit = "OnInit";
    private const string Func_OnEnter = "OnEnter";
    private const string Func_OnExit = "OnExit";
    private const string Func_OnStopEnter = "OnStopEnter";
    private const string Func_OnStopExit = "OnStopExit";
    private const string Func_OnFocus = "OnFocus";
    private const string Func_Refresh = "Refresh";
    private const string Func_Return = "Return";
    private const string Func_Help = "Help";
    //private const string Func_GetBounds = "GetBounds";
    private const string Func_OnEnable = "OnEnable";
    private const string Func_OnDisable = "OnDisable";
    private const string Func_OnDispose = "OnDispose";

    [NonSerialized] private LuaFunction luaOnInit = null;
    [NonSerialized] private LuaFunction luaOnEnter = null;
    [NonSerialized] private LuaFunction luaOnExit = null;
    [NonSerialized] private LuaFunction luaOnStopEnter = null;
    [NonSerialized] private LuaFunction luaOnStopExit = null;
    [NonSerialized] private LuaFunction luaOnEnable = null;
    [NonSerialized] private LuaFunction luaOnFocus = null;
    [NonSerialized] private LuaFunction luaRefresh = null;
    [NonSerialized] private LuaFunction luaReturn = null;
    [NonSerialized] private LuaFunction luaHelp = null;
    //[NonSerialized] private LuaFunction luaGetBounds = null;
    [NonSerialized] private LuaFunction luaOnDisable = null;
    [NonSerialized] private LuaFunction luaOnDispose = null;
    [NonSerialized] private int luaStatus = 0;

    protected override void OnBindToLua()
    {
        base.OnBindToLua();

        luaOnInit = GetBindFunction(Func_OnInit);
        luaOnEnter = GetBindFunction(Func_OnEnter);
        luaOnExit = GetBindFunction(Func_OnExit);
        luaOnStopEnter = GetBindFunction(Func_OnStopEnter);
        luaOnStopExit = GetBindFunction(Func_OnStopExit);
        luaOnFocus = GetBindFunction(Func_OnFocus);
        luaRefresh = GetBindFunction(Func_Refresh);
        luaReturn = GetBindFunction(Func_Return);
        luaHelp = GetBindFunction(Func_Help);
        //luaGetBounds = GetBindFunction(Func_GetBounds);
        luaOnEnable = GetBindFunction(Func_OnEnable);
        luaOnDisable = GetBindFunction(Func_OnDisable);
        luaOnDispose = GetBindFunction(Func_OnDispose);
    }

    /// <summary>
    /// 窗体体积
    /// </summary>
    //public Bounds bounds
    //{
    //    get
    //    {
    //        if (NoFunction(ref luaGetBounds)) return mIsFiexd ? EmptyBounds : NGUIMath.CalculateRelativeWidgetBounds(mScene ? mScene.transform : cachedTransform, cachedTransform, true);
    //        luaGetBounds.BeginPCall();
    //        if (isInstance) luaGetBounds.Push(mLua);
    //        luaGetBounds.PCall();
    //        Bounds b = luaGetBounds.CheckBounds();
    //        luaGetBounds.EndPCall();
    //        return b;
    //    }
    //}
    /// <summary>
    /// 初始化对象
    /// </summary>
    public object initObj
    {
        get { return mInitObj; }
        protected set
        {
            if (mInitObj is LuaBaseRef)
            {
                (mInitObj as LuaBaseRef).Dispose();
            }
            mInitObj = value;
        }
    }

    #region 重载的功能事件
    /// <summary>
    /// Unity事件OnEnable
    /// </summary>
    private void OnEnable() { CallFunction(ref luaOnEnable); }
    /// <summary>
    /// Unity事件OnDisable
    /// </summary>
    private void OnDisable() { CallFunction(ref luaOnDisable); }
    /// <summary>
    /// 帮助功能
    /// </summary>
    public void Help() { CallFunction(ref luaHelp); }
    /// <summary>
    /// 立即刷新窗体
    /// </summary>
    public void Refresh() { CallFunction(ref luaRefresh); }
    /// <summary>
    /// 此界面返回
    /// </summary>
    public void Return() { if (CallFunction(ref luaReturn)) return; Exit(); }
    /// <summary>
    /// 初始化
    /// </summary>
    private void OnInit() { CallFunction(ref luaOnInit); }
    /// <summary>
    /// 进入时
    /// </summary>
    private IEnumerator OnEnter()
    {
        if (NoTable) yield break;

        if (NoFunction(ref luaOnEnter))
        {
            goto lbl_anim;
        }
        else
        {
            luaOnEnter.BeginPCall();
            if (isInstance) luaOnEnter.Push(mLua);
            luaOnEnter.PCall();
            try
            {
                if (luaOnEnter.CheckBoolean())
                {
                    luaOnEnter.EndPCall();
                    goto lbl_wait;
                }
                else
                {
                    luaOnEnter.EndPCall();
                    goto lbl_end;
                }
            }
            catch
            {
                luaOnEnter.EndPCall();
                goto lbl_anim;
            }
        }

    lbl_wait:
        while (luaStatus == LS_Entering) yield return null;

        lbl_anim:
        UITweener[] uts = GetComponents<UITweener>();
        UITweener u = null;
        if (uts.GetLength() > 0)
        {
            u = uts[0];
            foreach (UITweener ut in uts) { ut.PlayForward(); if (ut.duration > u.duration) u = ut; }
        }

        ActiveAnimation aa = null;
        Animation animation = GetComponent<Animation>();
        if (animation)
        {
            if (mPanel) mPanel.alpha = 0.01f;
            aa = ActiveAnimation.Play(animation, AnimationOrTween.Direction.Forward);
        }

        if (u) while (u.enabled) yield return null;
        if (aa) while (aa.isPlaying) yield return null;

            lbl_end:
        while (luaStatus == LS_Entering) yield return null;
    }
    /// <summary>
    /// 退出时
    /// </summary>
    private IEnumerator OnExit()
    {
        if (NoTable) yield break;

        if (NoFunction(ref luaOnExit))
        {
            goto lbl_anim;
        }
        else
        {
            luaOnExit.BeginPCall();
            if (isInstance) luaOnExit.Push(mLua);
            luaOnExit.PCall();
            try
            {
                if (luaOnExit.CheckBoolean())
                {
                    luaOnExit.EndPCall();
                    goto lbl_wait;
                }
                else
                {
                    luaOnExit.EndPCall();
                    goto lbl_end;
                }
            }
            catch
            {
                luaOnExit.EndPCall();
                goto lbl_anim;
            }
        }

    lbl_wait:
        while (luaStatus == LS_Exting) yield return null;

        lbl_anim:
        UITweener[] uts = GetComponents<UITweener>();
        if (active)
        {
            UITweener u = null;
            if (uts.GetLength() > 0)
            {
                u = uts[0];
                foreach (UITweener ut in uts) { ut.PlayReverse(); if (ut.duration > u.duration) u = ut; }
            }

            ActiveAnimation aa = null;
            Animation animation = GetComponent<Animation>();
            if (animation)
            {
                aa = ActiveAnimation.Play(animation, AnimationOrTween.Direction.Reverse);
            }
            if (u) while (u.enabled) yield return null;
            if (aa) while (aa.isPlaying) yield return null;
        }
        else if (uts.GetLength() > 0)
        {
            foreach (UITweener ut in uts) ut.ResetToInit();
        }

    lbl_end:
        while (luaStatus == LS_Exting) yield return null;
    }
    /// <summary>
    /// 进入被终止
    /// </summary>
    private void OnStopEnter() { CallFunction(ref luaOnStopEnter); }
    /// <summary>
    /// 退出被终止
    /// </summary>
    private void OnStopExit() { CallFunction(ref luaOnStopExit); }
    /// <summary>
    /// 聚焦时
    /// </summary>
    /// <param name="isFocus">是否聚焦</param>
    public void OnFocus(bool isFocus) { CallFunction(ref luaOnFocus, isFocus); }
    /// <summary>
    /// 释放
    /// </summary>
    private void OnDispose() { CallFunction(ref luaOnDispose); }
    #endregion

    #region LUA注册
    public new static void Register(LuaState L)
    {
        L.BeginClass(typeof(Win), typeof(LuaContainer));
        L.RegFunction("Open", Open);
        L.RegFunction("GetWin", GetWin);
        L.RegFunction("GetActiveWin", GetActiveWin);
        L.RegFunction("GetOpenWin", GetOpenWin);
        L.RegFunction("GetWins", GetWins);
        L.RegFunction("ExitWin", ExitWin);
        L.RegFunction("ExitWinExcept", ExitWinExcept);
        L.RegFunction("ExitBackWin", ExitBackWin);
        L.RegFunction("ExitMutexWin", ExitMutexWin);
        L.RegFunction("ExitAllWin", ExitAllWin);
        L.RegFunction("Close", Close);
        L.RegFunction("ShowMainPanel", ShowMainPanel);
        L.RegFunction("CheckWinLayer", CheckWinLayer);
        L.RegFunction("Enter", Enter);
        L.RegFunction("Exit", Exit);
        L.RegFunction("Focus", Focus);
        L.RegFunction("ShowPage", ShowPage);
        L.RegFunction("HidePage", HidePage);
        L.RegFunction("ClearPage", ClearPage);
        L.RegFunction("RefreshPage", RefreshPage);
        L.RegFunction("__eq", op_Equality);
        L.RegFunction("__tostring", ToLua.op_ToString);
        L.RegVar("initObj", get_initObj, set_initObj);
        L.RegVar("winName", get_winName, null);
        L.RegVar("scene", get_scene, null);
        L.RegVar("status", get_status, set_status);
        L.RegVar("isOpen", get_isOpen, null);
        L.RegVar("active", get_active, set_active);
        L.RegVar("lifeTime", get_lifeTime, set_lifeTime);
        L.RegVar("autoHide", get_autoHide, set_autoHide);
        L.RegVar("isFloat", get_isFloat, set_isFloat);
        L.RegVar("depth", get_depth, set_depth);
        L.RegVar("isBackLayer", get_isBackLayer, set_isBackLayer);
        L.RegVar("isFixed", get_isFixed, set_isFixed);
        L.RegVar("mutex", get_mutex, set_mutex);
        L.RegVar("sort", get_sort, set_sort);
        L.RegVar("sizeStyle", get_sizeStyle, set_sizeStyle);
        L.RegVar("bounds", get_bounds, set_bounds);
        L.RegVar("cachedGameObject", get_cachedGameObject, null);
        L.RegVar("cachedTransform", get_cachedTransform, null);
        L.EndClass();
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Open(IntPtr L)
    {
        try
        {
            if (SceneManager.current)
            {
                int count = LuaDLL.lua_gettop(L);

                if (count == 1)
                {
                    ToLua.Push(L, SceneManager.current.OpenWin(ToLua.CheckString(L, 1)));
                }
                else if (count == 2)
                {
                    ToLua.Push(L, SceneManager.current.OpenWin(ToLua.CheckString(L, 1), ToLua.ToVarObject(L, 2)));
                }
                else
                {
                    return LuaDLL.luaL_throw(L, "invalid arguments to method: Win.Open");
                }
                return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetWin(IntPtr L)
    {
        try
        {
            if (SceneManager.current)
            {
                ToLua.CheckArgsCount(L , 1);
                ToLua.Push(L, SceneManager.current.GetWin(ToLua.CheckString(L, 1))); return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetActiveWin(IntPtr L)
    {
        try
        {
            if (SceneManager.current)
            {
                ToLua.CheckArgsCount(L, 1);
                ToLua.Push(L, SceneManager.current.GetActiveWin(ToLua.CheckString(L, 1))); return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetOpenWin(IntPtr L)
    {
        try
        {
            if (SceneManager.current)
            {
                ToLua.CheckArgsCount(L, 1);
                ToLua.Push(L, SceneManager.current.GetOpenWin(ToLua.CheckString(L, 1))); return 1;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int GetWins(IntPtr L)
    {
        try
        {
            if (SceneManager.current)
            {
                int count = LuaDLL.lua_gettop(L);
                if (count == 0)
                {
                    ToLua.Push(L, SceneManager.current.GetWins()); return 1;
                }
                if (count == 1)
                {
                    ToLua.Push(L, SceneManager.current.GetWins(LuaDLL.luaL_checkboolean(L, 1))); return 1;
                }
                return LuaDLL.luaL_throw(L, "invalid arguments to method: Win.GetWins");
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ExitWin(IntPtr L)
    {
        try
        {
            if (SceneManager.current)
            {
                int count = LuaDLL.lua_gettop(L);
                if (count == 0)
                {
                    SceneManager.current.ExitWin(); return 0;
                }
                if (count == 1)
                {
                    if (LuaDLL.lua_type(L, 1) == LuaTypes.LUA_TBOOLEAN)
                    {
                        SceneManager.current.ExitWin(LuaDLL.tolua_toboolean(L, 1));
                    }
                    else
                    {
                        Win win = SceneManager.current.GetWin(ToLua.CheckString(L, 1));
                        if (win) win.Exit();
                    }
                    return 0;
                }
                for (int i = 1; i <= count; i++)
                {
                    Win win = SceneManager.current.GetWin(ToLua.CheckString(L, i));
                    if (win) win.Exit();
                }
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ExitWinExcept(IntPtr L)
    {
        try
        {
            if (SceneManager.current)
            {
                int count = LuaDLL.lua_gettop(L);
                if (count == 0)
                {
                    SceneManager.current.ExitWin(); return 0;
                }
                Win[] wins = SceneManager.current.GetWins();
                if (count == 1)
                {
                    string wnm = ToLua.CheckString(L, 1);
                    foreach (Win win in wins)
                    {
                        if (win.winName == wnm) continue;
                        win.Exit();
                    }
                    return 0;
                }
                System.Collections.Generic.HashSet<string> wnms = new System.Collections.Generic.HashSet<string>();
                for (int i = 1; i <= count; i++)
                {
                    wnms.Add(ToLua.CheckString(L, i));
                }
                foreach (Win win in wins)
                {
                    if (wnms.Contains(win.winName)) continue;
                    win.Exit();
                }
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ExitBackWin(IntPtr L)
    {
        try
        {
            if (SceneManager.current)
            {
                int count = LuaDLL.lua_gettop(L);
                if (count == 0)
                {
                    SceneManager.current.ExitBackWin(); return 0;
                }
                if (count == 1)
                {
                    SceneManager.current.ExitBackWin(LuaDLL.luaL_checkboolean(L, 1)); return 0;
                }
                return LuaDLL.luaL_throw(L, "invalid arguments to method: Win.ExitBackWin");
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ExitMutexWin(IntPtr L)
    {
        try
        {
            if (SceneManager.current)
            {
                if (1 == LuaDLL.lua_gettop(L))
                {
                    SceneManager.current.ExitMutexWin((int)LuaDLL.luaL_checknumber(L, 1)); return 0;
                }
                return LuaDLL.luaL_throw(L, "invalid arguments to method: Win.ExitMutexWin");
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ExitAllWin(IntPtr L)
    {
        try
        {
            if (SceneManager.current)
            {
                SceneManager.current.ExitAllWin(); return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
   [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Close(IntPtr L)
    {
        try
        {
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ShowMainPanel(IntPtr L)
    {
        try
        {
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int CheckWinLayer(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (SceneManager.current)
            {
                if (count == 0)
                {
                    SceneManager.current.CheckWinLayer(); return 0;
                }
                if (count == 1)
                {
                    SceneManager.current.CheckWinLayer(LuaDLL.luaL_checkboolean(L, 1)); return 0;
                }
                if (count == 2)
                {
                    SceneManager.current.CheckWinLayer(LuaDLL.luaL_checkboolean(L, 1), LuaDLL.luaL_checkboolean(L, 2)); return 0;
                }
            }
            else
            {
                return LuaDLL.luaL_throw(L, "current scene [" + SceneManager.currentName + "] dose not have a [Scene] object");
            }

            return LuaDLL.luaL_throw(L, "invalid arguments to method: Win.CheckWinLayer");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Enter(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count == 1)
            {
                (ToLua.CheckObject<Win>(L, 1) as Win).Enter();
                return 0;
            }
            else if (count == 2)
            {
                (ToLua.CheckObject<Win>(L, 1) as Win).Enter(ToLua.ToVarObject(L, 2));
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to method: Win.Enter");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Exit(IntPtr L)
    {
        try
        {
            (ToLua.CheckObject<Win>(L, 1) as Win).Exit();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Focus(IntPtr L)
    {
        try
        {
            (ToLua.CheckObject<Win>(L, 1) as Win).Focus();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ShowPage(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count >= 2)
            {
                Win win = ToLua.CheckObject<Win>(L, 1) as Win;
                if (win)
                {
                    if (TypeChecker.CheckType(L, typeof(Page), 2))
                    {
                        if (count == 2)
                        {
                            win.ShowPage(ToLua.ToObject(L, 2) as Page); return 0;
                        }
                        if (count == 3)
                        {
                            win.ShowPage(ToLua.ToObject(L, 2) as Page, ToLua.ToObject(L, 3) as Transform); return 0;
                        }
                        if (count == 4)
                        {
                            win.ShowPage(ToLua.ToObject(L, 2) as Page, ToLua.ToObject(L, 3) as Transform, ToLua.ToVarObject(L, 4)); return 0;
                        }
                    }
                    else
                    {
                        if (count == 2)
                        {
                            win.ShowPage(ToLua.CheckString(L, 2)); return 0;
                        }
                        if (count == 3)
                        {
                            win.ShowPage(ToLua.CheckString(L, 2), ToLua.ToObject(L, 3) as Transform); return 0;
                        }
                        if (count == 4)
                        {
                            win.ShowPage(ToLua.CheckString(L, 2), ToLua.ToObject(L, 3) as Transform, ToLua.ToVarObject(L, 4)); return 0;
                        }
                    }
                }
            }

            return LuaDLL.luaL_throw(L, "invalid arguments to method: Win.ShowPage");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int HidePage(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count > 0)
            {
                Win win = ToLua.CheckObject<Win>(L, 1) as Win;
                if (win)
                {
                    if (count == 1)
                    {
                        win.HidePage(); return 0;
                    }
                    if (TypeChecker.CheckType(L, typeof(Page), 2))
                    {
                        win.HidePage(ToLua.ToObject(L, 2) as Page);
                    }
                    else
                    {
                        win.HidePage(ToLua.CheckString(L, 2));
                    }
                    return 0;
                }
            }

            return LuaDLL.luaL_throw(L, "invalid arguments to method: Win.HidePage");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int RefreshPage(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);
            if (count == 1)
            {
                (ToLua.CheckObject<Win>(L, 1) as Win).RefresPage();
                return 0;
            }
            if (count == 2)
            {
                (ToLua.CheckObject<Win>(L, 1) as Win).RefresPage(ToLua.CheckString(L, 2));
                return 0;
            }

            return LuaDLL.luaL_throw(L, "invalid arguments to method: Win.RefreshPage");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ClearPage(IntPtr L)
    {
        try
        {
            if (1 == LuaDLL.lua_gettop(L))
            {
                (ToLua.CheckObject<Win>(L, 1) as Win).ClearPage();
                return 0;
            }

            return LuaDLL.luaL_throw(L, "invalid arguments to method: Win.ClearPage");
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_initObj(IntPtr L)
    {
        try
        {
            ToLua.Push(L, (ToLua.CheckObject<Win>(L, 1) as Win).mInitObj);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_initObj(IntPtr L)
    {
        try
        {
            int count = LuaDLL.lua_gettop(L);

            if (count > 0)
            {
                (ToLua.CheckObject<Win>(L, 1) as Win).initObj = count > 1 ? ToLua.ToVarObject(L, 2) : null;
                return 0;
            }
            else
            {
                return LuaDLL.luaL_throw(L, "invalid arguments to Win.initObj");
            }
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_winName(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushstring(L, (ToLua.CheckObject<Win>(L, 1) as Win).winName);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_scene(IntPtr L)
    {
        try
        {
            ToLua.Push(L, (ToLua.CheckObject<Win>(L, 1) as Win).scene);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private  static int get_status(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, (int)((ToLua.CheckObject<Win>(L, 1) as Win).status));
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_status(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).luaStatus = (int)LuaDLL.luaL_checknumber(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isOpen(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, (ToLua.CheckObject<Win>(L, 1) as Win).isOpen);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_active(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, (ToLua.CheckObject<Win>(L, 1) as Win).active);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_active(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).active = LuaDLL.luaL_checkboolean(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_lifeTime(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, (ToLua.CheckObject<Win>(L, 1) as Win).mLifeTime);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_lifeTime(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).mLifeTime = (float)LuaDLL.luaL_checknumber(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_autoHide(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, (ToLua.CheckObject<Win>(L, 1) as Win).autoHide);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_autoHide(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).autoHide = LuaDLL.luaL_checkboolean(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isFloat(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, (ToLua.CheckObject<Win>(L, 1) as Win).isFloat);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_isFloat(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).isFloat = LuaDLL.luaL_checkboolean(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_depth(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, (ToLua.CheckObject<Win>(L, 1) as Win).depth);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_depth(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).depth = (int)LuaDLL.luaL_checknumber(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isBackLayer(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, (ToLua.CheckObject<Win>(L, 1) as Win).isBackLayer);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_isBackLayer(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).isBackLayer = LuaDLL.luaL_checkboolean(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_isFixed(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushboolean(L, (ToLua.CheckObject<Win>(L, 1) as Win).isFixed);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_isFixed(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).isFixed = LuaDLL.luaL_checkboolean(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_mutex(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, (ToLua.CheckObject<Win>(L, 1) as Win).mutex);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_mutex(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).mutex = (int)LuaDLL.luaL_checknumber(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_sort(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, (ToLua.CheckObject<Win>(L, 1) as Win).sort);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_sort(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).sort = (int)LuaDLL.luaL_checknumber(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_sizeStyle(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushnumber(L, (int)((ToLua.CheckObject<Win>(L, 1) as Win).sizeStyle));
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_sizeStyle(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).sizeStyle = (SizeStyle)LuaDLL.luaL_checkinteger(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_bounds(IntPtr L)
    {
        try
        {
            ToLua.Push(L, (ToLua.CheckObject<Win>(L, 1) as Win).bounds);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int set_bounds(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            (ToLua.CheckObject<Win>(L, 1) as Win).bounds = ToLua.CheckBounds(L, 2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_cachedGameObject(IntPtr L)
    {
        try
        {
            ToLua.Push(L, (ToLua.CheckObject<Win>(L, 1) as Win).cachedGameObject);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int get_cachedTransform(IntPtr L)
    {
        try
        {
            ToLua.Push(L, (ToLua.CheckObject<Win>(L, 1) as Win).cachedTransform);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    static int op_Equality(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            LuaDLL.lua_pushboolean(L, (ToLua.ToObject(L, 1) as UnityEngine.Object) == (ToLua.ToObject(L, 2) as UnityEngine.Object));
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    #endregion
}
#endif