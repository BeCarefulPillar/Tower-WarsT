using UnityEngine;

public interface IWrapGridHolder : IAlive
{
    /// <summary>
    /// Item初始化接口
    /// </summary>
    /// <param name="grid">Item所属Grid</param>
    /// <param name="item">Item对象</param>
    /// <param name="readIndex">真实索引</param>
    /// <returns>是否初始化成功</returns>
    bool OnWrapGridInitItem(UIWrapGrid grid, GameObject item, int readIndex);
    /// <summary>
    /// Item对齐
    /// </summary>
    /// <param name="grid">Item所属Grid</param>
    /// <param name="readIndex">真实索引</param>
    /// <returns>是否初始化成功</returns>
    void OnWrapGridAlignItem(UIWrapGrid grid, int readIndex);
    /// <summary>
    /// 请求更多的Item数量
    /// </summary>
    /// <param name="grid">当前请求的Grid</param>
    /// <returns>是否还有新的数据</returns>
    bool OnWrapGridRequestCount(UIWrapGrid grid);
}
