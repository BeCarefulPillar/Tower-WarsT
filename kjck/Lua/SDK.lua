local _SDK = SDK

SDK = { __index = _SDK }

setmetatable(SDK, SDK)

--[Comment]
--渠道
SDK.cid = _SDK.channel
--[Comment]
--子渠道
SDK.fid = _SDK.subChannel
--[Comment]
--用户ID
SDK.uuid = ""
--[Comment]
--玩家GUID
SDK.guid = ""
--[Comment]
--用户年龄
SDK.age = 0

--[Comment]
--SDK是否已登录
function SDK.IsLogin()
    return SDK.uuid ~= nil and SDK.uuid ~= ""
end
--[Comment]
--SDK预登录结果
function SDK.OnSdkPreLogin(ret)

end
--[Comment]
--SDK登录结果
function SDK.OnSdkLogin(ret)

end
--[Comment]
--SDK登出结果
function SDK.OnSdkLogout(ret)

end
--[Comment]
--SDK重登录结果
function SDK.OnSdkRelogin(ret)

end
--[Comment]
--SDK支付结果
function SDK.OnSdkPay(ret)

end
--[Comment]
--SDK验证
function SDK.OnSdkAdultInfo(ret)

end

--[Comment]
-- 弹出运营商退出窗口
function SDK.ShowExitView()

end