using UnityEngine;

public interface IPage
{
    /// <summary>
    /// Transform的缓存[只读]
    /// </summary>
    Transform cacheTransform { get; }
    /// <summary>
    /// gameObject的缓存[只读]
    /// </summary>
    GameObject cacheGameObject { get; }
    /// <summary>
    /// 是否已初始化
    /// </summary>
    bool isInit { get; }
    /// <summary>
    /// 是否在显示
    /// </summary>
    bool isShow { get; }

    /// <summary>
    /// 初始化
    /// </summary>
    void Init(object data);
    /// <summary>
    /// 显示
    /// </summary>
    void Show();
    /// <summary>
    /// 刷新
    /// </summary>
    void Refresh();
    /// <summary>
    /// 帮助
    /// </summary>
    void Help();
    /// <summary>
    /// 隐藏
    /// </summary>
    void Hide();
}
