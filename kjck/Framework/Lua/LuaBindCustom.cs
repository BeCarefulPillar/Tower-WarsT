#if TOLUA
using LuaInterface;

public static class LuaBindCustom
{
    public static void Bind(LuaState L)
    {
        L.BeginModule(null);

        LuaContainer.Register(L);
        Scene.Register(L);
        Win.Register(L);
        Page.Register(L);
        Server.Register(L);
        WinButton.Register(L);
        LuaButton.Register(L);
        LuaCmp.Register(L);
        LuaCmpLife.Register(L);
        LuaCmpFloat.Register(L);
        LuaCmpItem.Register(L);
        LuaSerializeRef.Register(L);
        LuaFuncBridge.Register(L);
        UIWrapGridWrap.Register(L);
        TypeWriterEffectWrap.Register(L);
        UILuaWidget.Register(L);

        LuaTool.Register(L);
        LuaStr.Register(L);
        LuaIO.Register(L);
        LuaEffect.Register(L);
        LuaAdapter.Register(L);
        LuaReflect.Register(L);
        LuaStateLite.Register(L);

        LuaBaseExtend.ArrayReg(L);
        LuaBaseExtend.WWWReg(L);
        LuaBaseExtend.GameObjectReg(L);
        LuaBaseExtend.ComponentReg(L);
        LuaBaseExtend.TransformReg(L);
        LuaBaseExtend.MaterialReg(L);
        LuaBaseExtend.UIRectReg(L);
        LuaBaseExtend.UIWidgetReg(L);
        LuaBaseExtend.UIPanelReg(L);
        LuaBaseExtend.UITextureReg(L);
        LuaBaseExtend.UISpriteReg(L);
        LuaBaseExtend.UIScrollViewReg(L);
        LuaBaseExtend.UIInputReg(L);
        LuaBaseExtend.UIPopupListReg(L);

        BU_Map.Register(L);

        L.EndModule();
    }
}
#endif