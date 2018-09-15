//Assets Manager Copyright © 何权

/// <summary>
/// 获取url
/// </summary>
public struct Url
{
#if UNITY_IPHONE
    private static System.Random random = new System.Random();
    /// <summary>
    /// 获得动态的url
    /// </summary>
    public static string Dynamic(string url)
    {
        return url + "?" + random.Next();
    }
#else
    /// <summary>
    /// 获得动态的url(安卓原样返回)
    /// </summary>
    public static string Dynamic(string url)
    {
        return url;
    }
#endif
}