using UnityEngine;
using System.Collections;

public class NotiConst
{
    /// <summary>
    /// Controller层消息通知
    /// </summary>
    public const string START_UP = "StartUp";                       //启动框架//StartUpCommand
    public const string DISPATCH_MESSAGE = "DispatchMessage";       //派发信息//SocketCommand

    /// <summary>
    /// View层消息通知
    /// </summary>
    public const string UPDATE_MESSAGE = "UpdateMessage";           //更新消息//AppView
    public const string UPDATE_EXTRACT = "UpdateExtract";           //更新解包//AppView
    public const string UPDATE_DOWNLOAD = "UpdateDownload";         //更新下载//AppView
    public const string UPDATE_PROGRESS = "UpdateProgress";         //更新进度//AppView
}
