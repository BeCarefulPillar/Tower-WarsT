//Assets Manager Copyright © 何权

using UnityEngine;

/// <summary>
/// 资源元数据
/// </summary>
[System.Serializable]
public class AssetMeta
{
    /// <summary>
    /// 资源名称
    /// </summary>
    [SerializeField] public string name;
    /// <summary>
    /// 资源路径ID
    /// </summary>
    [SerializeField] public int path;
    /// <summary>
    /// 资源内存总占用
    /// </summary>
    [SerializeField] public int size;
    /// <summary>
    /// 需要异步加载
    /// </summary>
    [SerializeField] public bool needAsyncLoad;
    /// <summary>
    /// 有外部资源
    /// </summary>
    [System.NonSerialized] public bool hasExtAsset = false;
    ///// <summary>
    ///// 预下载的外部资源
    ///// </summary>
    //[System.NonSerialized] public bool perLoad = false;
    ///// <summary>
    ///// 外部资源的包大小
    ///// </summary>
    //[System.NonSerialized] public int bundleSize;
    ///// <summary>
    ///// 外部资源的效验码
    ///// </summary>
    //[System.NonSerialized] public string crc;
}
