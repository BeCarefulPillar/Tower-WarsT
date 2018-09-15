using UnityEngine;
using LuaInterface;
using UnityEngine.EventSystems;

public class LuaButton : MonoBehaviour, IPointerClickHandler
{
    public LuaContainer luaContainer;
    [SerializeField]
    private bool mTransferSelf = false;
    [SerializeField]
    private bool mTransferPos = false;
    [SerializeField]
    private string mOnClick;
    public object param;
    public void OnPointerClick(PointerEventData eventData)
    {
        if(luaContainer && !string.IsNullOrEmpty(mOnClick))
        {
            LuaFunction func = luaContainer.GetLuaFunction(mOnClick);
            if (func == null)
                return;
            func.BeginPCall();
            if (mTransferSelf)
                func.Push(this);
            if (mTransferPos)
                func.Push(eventData.position);
            if (param != null)
                func.Push(param);
            func.PCall();
            func.EndPCall();
            func.Dispose();
            func = null;
        }
    }
}