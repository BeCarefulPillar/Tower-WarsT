using UnityEngine;

public interface IUITextureLoader : System.IDisposable, IProgress
{
    UITexture uiTexture { get; }
    Texture texture { get; }
    void SetOnLoad(System.Action<IUITextureLoader> onload);
}