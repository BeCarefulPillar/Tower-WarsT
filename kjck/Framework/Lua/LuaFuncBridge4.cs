#if TOLUA
using UnityEngine;
using LuaInterface;

public class LuaFuncBridge4 : LuaFuncBridge
{
    public override byte MaxFuncCount { get { return 4; } }

    public void LuaFuncOne() { CallFunction(0); }

    public void LuaFuncTwo() { CallFunction(1); }

    public void LuaFuncThree() { CallFunction(2); }

    public void LuaFuncFour() { CallFunction(3); }
}
#endif