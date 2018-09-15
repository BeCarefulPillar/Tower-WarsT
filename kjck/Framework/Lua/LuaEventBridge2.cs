#if TOLUA
public class LuaEventBridge2 : LuaFuncBridge
{
    public override byte MaxFuncCount { get { return 2; } }

    public void LuaEventOne() { CallFunction(0); }

    public void LuaEventTwo() { CallFunction(1); }
}
#endif