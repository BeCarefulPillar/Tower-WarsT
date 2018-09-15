
public interface IScene
{
    float loadingProgress { get; }

    /// <summary>
    /// 打开以类型名称指定的且挂有指定类型脚本的窗体
    /// </summary>
    /// <typeparam name="T">窗体类型</typeparam>
    T OpenWin<T>() where T : Win;
    /// <summary>
    /// 打开以类型名称指定的且挂有指定类型脚本的窗体
    /// </summary>
    /// <typeparam name="T">窗体类型</typeparam>
    /// <param name="param">初始化参数</param>
    T OpenWin<T>(object param) where T : Win;
    /// <summary>
    /// 打开指定名称且挂有指定类型脚本的窗体
    /// </summary>
    /// <param name="winName">窗体名称</param>
    T OpenWin<T>(string winName) where T : Win;
    /// <summary>
    /// 打开指定名称且挂有指定类型脚本的窗体
    /// </summary>
    /// <param name="winName">窗体名称</param>
    /// <param name="param">初始化参数</param>
    T OpenWin<T>(string winName, object param) where T : Win;
    /// <summary>
    /// 打开指定名称的窗体
    /// </summary>
    /// <param name="winName">窗体名称</param>
    Win OpenWin(string winName);
    /// <summary>
    /// 打开指定名称的窗体
    /// </summary>
    /// <param name="winName">窗体名称</param>
    /// <param name="param">初始化参数</param>
    Win OpenWin(string winName, object param);

    /// <summary>
    /// 从已有窗口列表中获取指定类型的窗口
    /// </summary>
    /// <typeparam name="T">窗口类型</typeparam>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    T GetWin<T>() where T : Win;
    /// <summary>
    /// 从已有窗口列表中获取指定类型的窗口
    /// </summary>
    /// <param name="type">窗口类型</param>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    Win GetWin(System.Type type);
    /// <summary>
    /// 从已有窗口列表中获取指定类名的窗口
    /// </summary>
    /// <param name="winName">窗口唯一名称</param>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    Win GetWin(string winName);

    /// <summary>
    /// 从已有窗口列表中获取指定类型的活动窗口
    /// </summary>
    /// <typeparam name="T">窗口类型</typeparam>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    T GetActiveWin<T>() where T : Win;
    /// <summary>
    /// 从已有窗口列表中获取指定类型的活动窗口
    /// </summary>
    /// <param name="type">窗口类型</param>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    Win GetActiveWin(System.Type type);
    /// <summary>
    /// 从已有窗口列表中获取指定类名的活动窗口
    /// </summary>
    /// <param name="winName">窗口唯一名称</param>
    /// <returns>返回所获取的窗口，若为Null则列表中没有</returns>
    Win GetActiveWin(string winName);

    /// <summary>
    /// 获取所有窗口(不排序)
    /// </summary>
    Win[] GetWins();
    /// <summary>
    /// 获取所有窗口
    /// </summary>
    Win[] GetWins(bool sort);

    /// <summary>
    /// 初始事件
    /// </summary>
    void OnInitEvent();
    /// <summary>
    /// 检查窗体层级显示
    /// </summary>
    void CheckWinLayer(bool depth, bool visable);
    /// <summary>
    /// 有窗体退出
    /// </summary>
    void OnWinDestroy(Win win);
}
