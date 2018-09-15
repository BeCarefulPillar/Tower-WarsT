PopSuggest = {}
local _body = nil
PopSuggest.body = _body

local _ref
local sugServer
local sugName
local sugIntro
local labCount
local btnSure

function PopSuggest.OnLoad(c)
    WinBackground(c, {k = WinBackground.MASK})
    _body = c
    _ref = _body.nsrf.ref

    c:BindFunction("OnInit", "OnEnter", "OnInputChanged", "ClickSure", "OnDispose", "OnUnLoad")

    sugServer = _ref.sugServer
    sugName = _ref.sugName
    sugIntro = _ref.sugIntro
    labCount = _ref.labCount
    btnSure = _ref.btnSure
end

function PopSuggest.OnInit()
    sugName.text = user.nick
    sugServer.text = user.rsn
    labCount.text = "0/200"
end

function PopSuggest.OnEnter()
    EF.PlayAni(_body, "PopMidIn", AOT_DRE.Forward, AOT_EC.EnableThenPlay, AOT_DC.DoNotDisable)
end

--获取含中文的字符串长义度
local function getStringCharCount(str)
    local lenInByte = #str
    local charCount = 0
    local i = 1
    while (i <= lenInByte) do
        local curByte = string.byte(str, i)
        local byteCount = 1;
        if curByte > 0 and curByte <= 127 then
            byteCount = 1                                               --1字节字符
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2                                               --双字节字符
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3                                               --汉字
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4                                               --4字节字符
        end
        
        local char = string.sub(str, i, i + byteCount - 1)
        i = i + byteCount                                               -- 重置下一字节的索引
        charCount = charCount + 1                                       -- 字符的个数（长度）
    end
    return charCount
end

function PopSuggest.OnInputChanged()
    local lines = string.split(sugIntro.value, "\n")
    if #lines > 12 then
        local str = lines[1]
        for i=1, 12 do
            str = str .. "\n" .. lines[i]
        end
        sugIntro.value = str
    end
    
    labCount.text = getStringCharCount(sugIntro.value) .. "/200"
end

function PopSuggest.ClickSure()
    if string.len(sugIntro.value) < 8 then ToolTip.ShowPopTip("请输入最少8个字") return end

    SVR.SuggestOpt(1, sugIntro.value, function(result)
        if result.success then
            MsgBox.Show("感谢您的反馈!")
            PopSuggest.OnDispose()
        end
    end)
end

function PopSuggest.OnDispose()
    sugIntro.value = ""
    labCount.text = "0/200"
end

function PopSuggest.OnUnLoad()
    _body = nil
end
