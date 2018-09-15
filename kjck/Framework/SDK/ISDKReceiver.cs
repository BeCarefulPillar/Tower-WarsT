public interface ISDKReceiver
{
    void OnSdkInit(string ret);
    void OnSdkPreLogin(string ret);
    void OnSdkLogin(string ret);
    void OnSdkLogout(string ret);
    void OnSdkRelogin(string ret);
    void OnSdkPay(string ret);
    void OnSdkAdultInfo(string ret);
}
