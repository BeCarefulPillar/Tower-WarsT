#if TOLUA
public class LuaEventBridge8 : LuaFuncBridge
{
    public override byte MaxFuncCount { get { return 8; } }

    public void LuaEventOne() { CallFunction(0); }

    public void LuaEventTwo() { CallFunction(1); }

    public void LuaEventThree() { CallFunction(2); }

    public void LuaEventFour() { CallFunction(3); }

    public void LuaEventFive() { CallFunction(4); }

    public void LuaEventSix() { CallFunction(5); }

    public void LuaEventSeven() { CallFunction(6); }

    public void LuaEventEight() { CallFunction(7); }
}
#endif