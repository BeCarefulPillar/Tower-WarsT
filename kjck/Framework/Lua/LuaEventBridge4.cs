#if TOLUA
public class LuaEventBridge4 : LuaFuncBridge
{
    public override byte MaxFuncCount { get { return 4; } }

    public void LuaEventOne() { CallFunction(0); }

    public void LuaEventTwo() { CallFunction(1); }

    public void LuaEventThree() { CallFunction(2); }

    public void LuaEventFour() { CallFunction(3); }
}
#endif