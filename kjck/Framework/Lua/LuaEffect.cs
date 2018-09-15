#if TOLUA
using System;
using UnityEngine;
using LuaInterface;

public static class LuaEffect
{
    public static void Register(LuaState L)
    {
        L.BeginModule("EF");
        L.RegFunction("FadeIn", FadeIn);
        L.RegFunction("FadeOut", FadeOut);
        L.RegFunction("MoveIn", MoveIn);
        L.RegFunction("MoveOut", MoveOut);
        L.RegFunction("Move", Move);
        L.RegFunction("Scale", Scale);
        L.RegFunction("Rotate", Rotate);
        L.RegFunction("Alpha", Alpha);
        L.RegFunction("Volume", Volume);
        L.RegFunction("ResetToInit", ResetToInit);
        L.RegFunction("SpriteTurn", SpriteTrun);
        L.RegFunction("TweenClear", TweenClear);
        L.RegFunction("Damp", Damp);
        L.RegFunction("DampClear", DampClear);
        L.RegFunction("DampIsPlaying", DampIsPlaying);

        L.RegFunction("Whirling", Whirling_Begin);

        L.RegFunction("PlayAni", PlayAni);
        L.RegFunction("AniIsPlaying", AniIsPlaying);

        L.RegFunction("MoveSVTo", MoveScrollViewTo);
        L.RegFunction("OnClipMoveAdd", OnClipMoveAdd);
        L.RegFunction("OnClipMoveRemove", OnClipMoveRemove);

        L.RegFunction("ClearITween", ClearITween);
        L.RegFunction("MoveTo", iTween_MoveTo);
        L.RegFunction("ScaleTo", iTween_ScaleTo); 
        L.RegFunction("ColorTo", iTween_ColorTo);
        L.RegFunction("RotateTo", iTween_RotateTo);
        L.RegFunction("ColorFrom", iTween_ColorFrom);
        L.RegFunction("MoveFrom" , iTween_MoveFrom);
        L.RegFunction("ScaleFrom", iTween_ScaleFrom);
        L.RegFunction("RotateFrom", iTween_RotateFrom);
        L.RegFunction("SpringPos", SpringPosBegin);
        L.RegFunction("ShakePosition", iTween_ShakePosition);
        L.RegFunction("ShakeScale", ShakeScale);

        L.RegFunction("TypeText", TypeText);

        L.RegFunction("BindWidgetColor", SetBindWidgetColor);
        L.RegFunction("BindWidgetDepth", SetBindWidgetDepth);
        L.RegFunction("BindRectCorner", SetBindRectCorner);
        L.RegFunction("TimerBegin", TimerBegin);
        L.RegFunction("wsCast", wsCast);

        L.RegFunction("bdMinDis", bdMinDis);

        L.RegFunction("ShowSkill", ShowSkill);
        
        L.EndModule();
    }

    #region Tween
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SpringPosBegin(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt == 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    SpringPosition.Begin(go, ToLua.ToVector3(L, 2), (float)LuaDLL.luaL_checknumber(L, 3));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ClearITween(IntPtr L)
    {
        try
        {
            object obj = ToLua.ToObject(L, 1);
            if (obj == null) return 0;
            GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
            iTween[] itws = go.GetComponents<iTween>();
            if (itws.GetLength() > 0) { foreach (iTween it in itws) it.Destruct(); }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int iTween_MoveTo(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    if (argCnt % 2 == 0) argCnt = argCnt - 1;
                    object[] args = new object[argCnt - 1];
                    for (int i = 2; i <= argCnt; i++) args[i - 2] = ToLua.ToVarObject(L, i);
                    iTween.MoveTo(go, iTween.Hash(args));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int iTween_ScaleTo(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    if (argCnt % 2 == 0) argCnt = argCnt - 1;
                    object[] args = new object[argCnt - 1];
                    for (int i = 2; i <= argCnt; i++) args[i - 2] = ToLua.ToVarObject(L, i);
                    iTween.ScaleTo(go, iTween.Hash(args));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
   [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int iTween_ColorTo(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    if (argCnt % 2 == 0) argCnt = argCnt - 1;
                    object[] args = new object[argCnt - 1];
                    for (int i = 2; i <= argCnt; i++) args[i - 2] = ToLua.ToVarObject(L, i);
                    iTween.ColorTo(go, iTween.Hash(args));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int iTween_RotateTo(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    if (argCnt % 2 == 0) argCnt = argCnt - 1;
                    object[] args = new object[argCnt - 1];
                    for (int i = 2; i <= argCnt; i++) args[i - 2] = ToLua.ToVarObject(L, i);
                    iTween.RotateTo(go, iTween.Hash(args));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int iTween_ColorFrom(IntPtr L) {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    if (argCnt % 2 == 0) argCnt = argCnt - 1;
                    object[] args = new object[argCnt - 1];
                    for (int i = 2; i <= argCnt; i++) args[i - 2] = ToLua.ToVarObject(L, i);
                    iTween.ColorFrom(go, iTween.Hash(args));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int iTween_MoveFrom(IntPtr L){
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    if (argCnt % 2 == 0) argCnt = argCnt - 1;
                    object[] args = new object[argCnt - 1];
                    for (int i = 2; i <= argCnt; i++) args[i - 2] = ToLua.ToVarObject(L, i);
                    iTween.MoveFrom(go, iTween.Hash(args));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int iTween_ScaleFrom(IntPtr L) {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    if (argCnt % 2 == 0) argCnt = argCnt - 1;
                    object[] args = new object[argCnt - 1];
                    for (int i = 2; i <= argCnt; i++) args[i - 2] = ToLua.ToVarObject(L, i);
                    iTween.ScaleFrom(go, iTween.Hash(args));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int iTween_RotateFrom(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    if (argCnt % 2 == 0) argCnt = argCnt - 1;
                    object[] args = new object[argCnt - 1];
                    for (int i = 2; i <= argCnt; i++) args[i - 2] = ToLua.ToVarObject(L, i);
                    iTween.RotateFrom(go, iTween.Hash(args));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int iTween_ShakePosition(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    if (argCnt % 2 == 0) argCnt = argCnt - 1;
                    object[] args = new object[argCnt - 1];
                    for (int i = 2; i <= argCnt; i++) args[i - 2] = ToLua.ToVarObject(L, i);
                    iTween.ShakePosition(go, iTween.Hash(args));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ShakeScale(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    if (argCnt % 2 == 0) argCnt = argCnt - 1;
                    object[] args = new object[argCnt - 1];
                    for (int i = 2; i <= argCnt; i++) args[i - 2] = ToLua.ToVarObject(L, i);
                    iTween.ShakeScale(go, iTween.Hash(args));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int TweenClear(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt > 0)
            {
                object obj = ToLua.ToObject(L, 1);
                UITweener[] ts = (obj is Component) ? (obj as Component).GetComponents<UITweener>() : (obj as GameObject).GetComponents<UITweener>();
                if (argCnt > 1 && LuaDLL.luaL_checkboolean(L, 2))
                {
                    for (int i = 0; i < ts.Length; i++) ts[i].Destruct();
                }
                else
                {
                    for (int i = 0; i < ts.Length; i++) ts[i].enabled = false;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int FadeIn(IntPtr L)
    {
        try
        {
            int coount = LuaDLL.lua_gettop(L);
            if (coount > 0)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    TweenFade.Begin(go, true, coount > 1 ? (float)LuaDLL.luaL_checknumber(L, 2) : 0f, coount > 2 ? (float)LuaDLL.luaL_checknumber(L, 3) : 0f);
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int FadeOut(IntPtr L)
    {
        try
        {
            int coount = LuaDLL.lua_gettop(L);
            if (coount > 0)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go && go.activeSelf)
                {
                    TweenFade.Begin(go, false, coount > 1 ? (float)LuaDLL.luaL_checknumber(L, 2) : 0f, coount > 2 ? (float)LuaDLL.luaL_checknumber(L, 3) : 0f);
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int MoveIn(IntPtr L)
    {
        try
        {
            int coount = LuaDLL.lua_gettop(L);
            if (coount > 0)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    TweenMove.Begin(go, true, coount > 1 ? (float)LuaDLL.luaL_checknumber(L, 2) : 0f, coount > 2 ? (float)LuaDLL.luaL_checknumber(L, 3) : 0f);
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int MoveOut(IntPtr L)
    {
        try
        {
            int coount = LuaDLL.lua_gettop(L);
            if (coount > 0)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go && go.activeSelf)
                {
                    TweenMove.Begin(go, false, coount > 1 ? (float)LuaDLL.luaL_checknumber(L, 2) : 0f, coount > 2 ? (float)LuaDLL.luaL_checknumber(L, 3) : 0f);
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Move(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt > 2)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    TweenPosition tp = TweenPosition.Begin(go, (float)LuaDLL.luaL_checknumber(L, 2), ToLua.ToVector3(L, 3));
                    tp.delay = argCnt > 3 ? (float)LuaDLL.luaL_checknumber(L, 4) : 0f;
                    ToLua.Push(L, tp);
                }
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Scale(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt > 2)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    TweenScale ts = TweenScale.Begin(go, (float)LuaDLL.luaL_checknumber(L, 2), ToLua.ToVector3(L, 3));
                    ts.delay = argCnt > 3 ? (float)LuaDLL.luaL_checknumber(L, 4) : 0f;
                    ToLua.Push(L, ts);
                }
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Rotate(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt > 2)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    TweenRotation tr = TweenRotation.Begin(go, (float)LuaDLL.luaL_checknumber(L, 2), Quaternion.Euler(ToLua.ToVector3(L, 3)));
                    tr.delay = argCnt > 3 ? (float)LuaDLL.luaL_checknumber(L, 4) : 0f;
                    ToLua.Push(L, tr);
                }
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Alpha(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt > 2)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    TweenAlpha ta = TweenAlpha.Begin(go, (float)LuaDLL.luaL_checknumber(L, 2), (float)LuaDLL.luaL_checknumber(L, 3));
                    ta.delay = argCnt > 3 ? (float)LuaDLL.luaL_checknumber(L, 4) : 0f;
                    ToLua.Push(L, ta);
                }
            }
            return 1;
        }
        catch(Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Volume(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt > 2)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    TweenVolume tv = TweenVolume.Begin(go, (float)LuaDLL.luaL_checknumber(L, 2), (float)LuaDLL.luaL_checknumber(L, 3));
                    tv.delay = argCnt > 3 ? (float)LuaDLL.luaL_checknumber(L, 4) : 0f;
                    ToLua.Push(L, tv);
                }
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ResetToInit(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt == 1)
            {
                object obj = ToLua.ToObject(L, 1);
                UITweener ut = null;
                if (obj is UITweener) ut = obj as UITweener;
                else
                {
                    GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                    if (go)
                    {
                        ut = go.GetComponent<UITweener>();
                        if (ut == null) ut = go.AddComponent<UITweener>();
                    }
                }
                if (ut != null) ut.ResetToInit();
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SpriteTrun(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt > 1)
            {
                object obj = ToLua.ToObject(L, 1);
                UISprite sprite = null;
                if (obj is UISprite)
                {
                    sprite = obj as UISprite;
                }
                else if (obj is Component)
                {
                    sprite = (obj as Component).GetComponent<UISprite>();
                }
                else if (obj is GameObject)
                {
                    sprite = (obj as GameObject).GetComponent<UISprite>();
                }
                if (sprite)
                {
                    TurnSprite.Begin(sprite, ToLua.CheckString(L, 2), argCnt > 2 ? (float)LuaDLL.luaL_checknumber(L, 3) : 0.2f);
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Damp(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt > 2)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    Vector3 v = ToLua.CheckVector3(L, 2);
                    ActiveAnima.Style style = (ActiveAnima.Style)LuaDLL.luaL_checkinteger(L, 3);
                    if (argCnt > 3)
                    {
                        float loop = (float)LuaDLL.luaL_checknumber(L, 4);
                        if (argCnt > 4)
                        {
                            float spring = (float)LuaDLL.luaL_checknumber(L, 5);
                            if (argCnt > 5)
                            {
                                ToLua.Push(L, ActiveAnima.Begin(go, v, style, loop, spring, (float)LuaDLL.luaL_checknumber(L, 6)));
                            }
                            else
                            {
                                ToLua.Push(L, ActiveAnima.Begin(go, v, style, loop, spring));
                            }
                        }
                        else
                        {
                            ToLua.Push(L, ActiveAnima.Begin(go, v, style, loop));
                        }
                    }
                    else
                    {
                        ToLua.Push(L, ActiveAnima.Begin(go, v, style));
                    }
                    return 1;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DampClear(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt == 1)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go) ActiveAnima.Remove(go);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int DampIsPlaying(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt == 1)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go) ToLua.Push(L, ActiveAnima.IsPlaying(go));
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);

        }
    }
    #endregion

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int bdMinDis(IntPtr L)
    {
        try
        {
            if(LuaDLL.lua_gettop(L)==3)
            {
                GameObject go = ToLua.ToObject(L, 1) as GameObject;
                go.AddComponent<BindMinDis>().Bind(
                    ToLua.ToObject(L, 2) as Transform,
                    (float)LuaDLL.luaL_checknumber(L, 3));
            }
            return 0;
        }
        catch(Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    #region Animation
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int PlayAni(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt < 2)
            {
                return LuaDLL.luaL_throw(L, "PlayAnim requires at least 2 params");
            }

            Animation an = null;
            Animator at = null;
            object obj = ToLua.ToObject(L, 1);
            if (obj is Animation)
            {
                an = obj as Animation;
            }
            else if (obj is Animator)
            {
                at = obj as Animator;
            }
            else if (obj is GameObject)
            {
                GameObject go = obj as GameObject;
                an = go.GetComponent<Animation>();
                if(an == null) at = go.GetComponent<Animator>();
            }
            else if (obj is Component)
            {
                Component cmp = obj as Component;
                an = cmp.GetComponent<Animation>();
                if (an == null) at = cmp.GetComponent<Animator>();
            }
            else
            {
                return LuaDLL.luaL_throw(L, "PlayAnim first arg must be Animation/Animator/GameObject/Component");
            }
            if (an)
            {
                ActiveAnimation.Play(an, ToLua.CheckString(L, 2), argCnt > 2 ? (AnimationOrTween.Direction)LuaDLL.luaL_checkinteger(L, 3) : AnimationOrTween.Direction.Forward,
                    argCnt > 3 ? (AnimationOrTween.EnableCondition)LuaDLL.luaL_checkinteger(L, 4) : AnimationOrTween.EnableCondition.DoNothing,
                    argCnt > 4 ? (AnimationOrTween.DisableCondition)LuaDLL.luaL_checkinteger(L, 5) : AnimationOrTween.DisableCondition.DoNotDisable);
            }
            if (at)
            {
                ActiveAnimation.Play(at, ToLua.CheckString(L, 2), argCnt > 2 ? (AnimationOrTween.Direction)LuaDLL.luaL_checkinteger(L, 3) : AnimationOrTween.Direction.Forward,
                    argCnt > 3 ? (AnimationOrTween.EnableCondition)LuaDLL.luaL_checkinteger(L, 4) : AnimationOrTween.EnableCondition.DoNothing,
                    argCnt > 4 ? (AnimationOrTween.DisableCondition)LuaDLL.luaL_checkinteger(L, 5) : AnimationOrTween.DisableCondition.DoNotDisable);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int AniIsPlaying(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt == 1)
            {
                object obj = ToLua.ToObject(L, 1);
                if (obj is ActiveAnimation)
                {
                    ToLua.Push(L, (obj as ActiveAnimation).isPlaying);
                    return 1;
                }
                ActiveAnimation aa = obj is Component ? (obj as Component).GetComponent<ActiveAnimation>() : (obj is GameObject ? (obj as GameObject).GetComponent<ActiveAnimation>() : null);
                if (aa)
                {
                    ToLua.Push(L, aa.isPlaying);
                    return 1;
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);

        }
    }
    #endregion

    #region other
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int TypeText(IntPtr L) {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt ==2) {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                go.GetComponent<TypeWriterEffect>().TypeText(LuaDLL.lua_tostring(L,2));
            }
                return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int Whirling_Begin(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 3)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                float time = argCnt > 3 ? (float)LuaDLL.luaL_checknumber(L, 4) : 0;
                float delay = argCnt > 4 ? (float)LuaDLL.luaL_checknumber(L, 5) : 0;
                Whirling.Begin(go, ToLua.ToVector3(L, 2), (float)LuaDLL.luaL_checknumber(L, 3), time, delay);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
   [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int MoveScrollViewTo(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt == 3)
            {
                object obj = ToLua.ToObject(L, 1);
                UIScrollView sv = (obj is Component ? (obj as Component).gameObject : obj as GameObject).GetComponent<UIScrollView>();
                sv.MoveTo(ToLua.ToVector3(L, 2), LuaDLL.luaL_checkboolean(L, 3));
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int OnClipMoveAdd(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 2)
            {
                object obj = ToLua.ToObject(L, 1);
                UIPanel pnl = obj is Component ? (obj as Component).GetComponent<UIPanel>() : (obj as GameObject).GetComponent<UIPanel>();
                pnl.onClipMove += (UIPanel.OnClippingMoved)ToLua.CheckDelegate<UIPanel.OnClippingMoved>(L, 2);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int OnClipMoveRemove(IntPtr L)
    {
        try
        {
            if (LuaDLL.lua_gettop(L) == 2)
            {
                object obj = ToLua.ToObject(L, 1);
                UIPanel pnl = obj is Component ? (obj as Component).GetComponent<UIPanel>() : (obj as GameObject).GetComponent<UIPanel>();
                pnl.onClipMove -= (UIPanel.OnClippingMoved)ToLua.CheckDelegate<UIPanel.OnClippingMoved>(L, 2);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetBindWidgetColor(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 2)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                BindWidgetColor bwc = go.GetComponent<BindWidgetColor>() ?? go.AddComponent<BindWidgetColor>();
                if (TypeChecker.CheckTypes<Color>(L, 2))
                {
                    bwc.defaultColor = ToLua.CheckColor(L, 2);
                    if (argCnt > 2) bwc.bind = ToLua.CheckObject<UIWidget>(L, 3) as UIWidget;
                }
                else if (TypeChecker.CheckTypes<UIWidget>(L, 2))
                {
                    bwc.bind = ToLua.CheckObject<UIWidget>(L, 2) as UIWidget;
                    if (argCnt > 2) bwc.defaultColor = ToLua.CheckColor(L, 3);
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetBindWidgetDepth(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 2)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                BindWidgetDepth bwc = go.GetComponent<BindWidgetDepth>() ?? go.AddComponent<BindWidgetDepth>();
                if (TypeChecker.CheckTypes<Color>(L, 2))
                {
                    bwc.depthOffset = (int)LuaDLL.luaL_checknumber(L, 2);
                    if (argCnt > 2) bwc.bind = ToLua.CheckObject<UIWidget>(L, 3) as UIWidget;
                }
                else if (TypeChecker.CheckTypes<UIWidget>(L, 2))
                {
                    bwc.bind = ToLua.CheckObject<UIWidget>(L, 2) as UIWidget;
                    if (argCnt > 2) bwc.depthOffset = (int)LuaDLL.luaL_checknumber(L, 3);
                }
                else if (TypeChecker.CheckTypes<Component>(L, 2) || TypeChecker.CheckTypes<GameObject>(L, 2))
                {
                    obj = ToLua.ToObject(L, 2);
                    go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                    BindWidgetDepth tmp = go.GetComponent<BindWidgetDepth>();
                    if (tmp) bwc.Bind(tmp.bind, tmp.depthOffset);
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int SetBindRectCorner(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 2)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                BindRectCorner brc = go.GetComponent<BindRectCorner>() ?? go.AddComponent<BindRectCorner>();
                brc.rect = ToLua.CheckObject<UIRect>(L, 2) as UIRect;
                if (argCnt >= 3) brc.offset = (float)LuaDLL.luaL_checknumber(L, 3);
                if (argCnt >= 4) brc.dre = LuaDLL.luaL_checkinteger(L, 4);
                brc.MarkAsChanged();
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int TimerBegin(IntPtr L) {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 2)
            {
                UISpriteTimer.Begin(L.GetCmp<UISprite>(1), (float)LuaDLL.luaL_checknumber(L, 2), argCnt >= 3 ? (float)LuaDLL.luaL_checknumber(L, 3) : 0f);
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int wsCast(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt >= 2)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                UITexture tex = go.GetComponent<UITexture>() ?? go.AddComponent<UITexture>();
                WidgetShadow.Cast(tex, (float)LuaDLL.luaL_checknumber(L, 2));
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int ShowSkill(IntPtr L)
    {
        try
        {
            int argCnt = LuaDLL.lua_gettop(L);
            if (argCnt == 2)
            {
                object obj = ToLua.ToObject(L, 1);
                GameObject go = obj is Component ? (obj as Component).gameObject : obj as GameObject;
                if (go)
                {
                    EFShowSkill ss = go.GetComponent<EFShowSkill>();
                    if (ss) ss.Show(ToLua.CheckString(L, 2));
                }
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    #endregion

}
#endif