local _w = { }

local _body = nil
local _ref = nil

--组件绑定
local _btnReset = nil
local _btnImprint = nil
local _luIcon = nil
local _luName = nil
local _luImp = nil
local _resetPrice = nil
local _impPrice = nil

local _imps = {
    star = nil,
    attrib = nil,
    lockTag = nil,
    rare = nil,
}

--数据
local _hero = nil
local _lineup = nil
local _imprint = nil

--设置词条
local function SetAtt(i, k, col) 
    _imps[i].star.spriteName = "star_"..k
    _imps[i].attrib.color = ColorStyle.GetRareColor(k + 1)
    _imps[i].attrib.effectColor = col
end

--设置未铭刻
local function SetA(i)
    _imps[i].rare = 0
    _imps[i].attrib.text = L("未铭刻")
    _imps[i].attrib.color = Color(0.5,0.5,0.5,1)
    _imps[i].star.spriteName = "star_0"
    _imps[i].lockTag:SetActive(false)
end
--更新锁定
local function UpdateLock()
    local cnt = 0
    for i = 1 ,#_imps do
        if _imps[i].lockTag.activeSelf then
            cnt = cnt + 1
            _resetPrice.text = tostring(cnt * DB.param.prLnpImpLock)
            _btnReset.isEnabled = #_imprint > 0 and cnt < #_imprint
        end
    end
    
end

--显示信息
local function UpdateInfo(reset)
    if reset == nil then reset = false end
    UpdateLock()
    _impPrice.color = user.GetPropsQty(DB_Props.ZHEN_WEN_FU) < DB.param.prLnpImp and Color.red or Color.green
    local imp = _hero:GetLnpImpQty(_lineup.sn)
    _luImp.text = imp > 0 and "+" .. imp or ""
    local len = #_imprint
    for i = 1,#_imps do 
        if i <= len then  
            if reset then _imps[i].lockTag:SetActive(true) end
            local vals = _imprint[i] 
            if #vals > 1 then  
                 _imps[i].attrib.text =  DB.GetAttWord(vals) 
                 local value= tonumber(vals[2])
                 _imps[i].rare = DB.GetLnpImpRare(vals[1],value)
                 local att = _imps[i].rare
                 if att == 2 then
                    SetAtt(i, 2, Color(0.23, 0.26, 0.38, 1))
                 elseif att==3 then
                    SetAtt(i, 3, Color(0.25, 0.16, 0.2, 1))
                 else
                    SetAtt(i, 1, Color(0.2, 0.32,0.19 , 1))
                 end
            else 
                SetA(i)
            end
        else 
            SetA(i)
        end
    end
end

--确定重置 
local function IeReset()
    local atp = StatusBar.ShowR()
    --重铸特效
    for i = 1,#_imps do 
        if _imps[i].rare > 0 and not _imps[i].lockTag.activeSelf then 
            WidgetEffect.Detonate(_imps[i].star,  math.random(2, 4), math.random(2, 4), 0, false)
            _imps[i].star.spriteName = "star_0"
            TweenAlpha.Begin(_imps[i].attrib.gameObject, 0.3, 0)
        end
    end
    coroutine.wait(0.3)
    UpdateInfo(true)
    for i = 1,#_imps do  
        TweenAlpha.Begin(_imps[i].attrib.gameObject, 0.3, 1)
    end
    atp:Done()
end

--重置
local function Reset(flag)
    if flag == nil then return end
    local cnt = #_imprint
    local idx=""
    for i = 1, #_imps do 
        if _imprint[i] and _imps[i].lockTag.activeSelf then
            cnt = cnt - 1
            idx = idx..i..","  
       end
    end
    idx = string.sub(idx, 1, string.len(idx) - 1)
    if cnt > 0 then 
       SVR.ImpLnp(_hero.sn, _hero:GetLnpIdx(_lineup.sn),"set|" .. idx, function(res)
          if res.success then  
            _imprint = ExtAtt(SVR.datCache.imp)
--            local w = Win.GetOpenWin("PopHeroDetail")
--            if w then PopHeroDetail.LnpImpUpdate(lineup.sn) end
            if _body.activeSelf then 
                coroutine.start(IeReset)
            else
                UpdateInfo(true)
            end
          end
       end)
    end
end

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK })
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad",
                    "ClickReset","ClickImprint","ClickItem","ClickLock")
    _ref = c.nsrf.ref
    _btnReset = _ref.btnReset
    _btnImprint = _ref.btnImprint
    _luIcon = _ref.luIcon
    _luName = _ref.luName
    _luImp = _ref.luImp
    _resetPrice = _ref.resetPrice
    _impPrice = _ref.impPrice
    local temp = {_ref.imp1, _ref.imp2, _ref.imp3, _ref.imp4, _ref.imp5, 
             _ref.imp6, _ref.imp7, _ref.imp8, _ref.imp9, _ref.imp10,}
    print("temptemptemp   " , kjson.print(temp))

    for i = 1 , #temp do
        _imps[i] = {}
        _imps[i].star = temp[i][1]
        _imps[i].attrib = temp[i][2]
        _imps[i].lockTag = temp[i][3]
    end
    print("aaaaaaaaaaaaaaa   " , kjson.print(_imps))
    for k,val in ipairs(_imps) do val.attrib.luaBtn:SetClick("ClickLock",k) end
    
end

function _w.OnInit() 
    local var = _w.initObj
    print("OnInit var  ", kjson.print(var))
    _hero = var[1]
    _lineup = var[2]
    if _hero ~= nil and _lineup ~= nil and _hero:LnpAvailable(_lineup.sn) then
        _luIcon:LoadTexAsync(ResName.LineupIcon(_lineup.sn))
        _luName.text = L(_lineup.nm.."阵")
        _impPrice.text = "×"..DB.param.prLnpImp
        _hero:GetLnpImp(_lineup.sn,function(imp)
            _imprint = ExtAtt(imp) or {}
        end)
        UpdateInfo()
        print("imprintimprint   ",kjson.print(_imprint))
    end
end

function _w.OnDispose()


    _hero = nil
    _lineup = nil
    _imprint = nil
end

function _w.OnUnLoad(c)
    _body = nil
    _ref = nil
    _btnReset = nil
    _btnImprint = nil
    _luIcon = nil
    _luName = nil
    _luImp = nil
    _resetPrice = nil
    _impPrice = nil
end

--重置
function _w.ClickReset()
    if user.IsTipLineupReset then 
        user.IsTipLineupReset = false
        MsgBox.Show(L("重铸会将未锁定的属性全部清除，请谨慎使用！"),L("确定")..","..L("取消"),function(flag) if flag==0 then Reset(flag) end end)
    else
        for i=1,#_imps do 
            if _imps[i].rare>2 and not _imps[i].lockTag.activeSelf then
                MsgBox.Show(L("您还有紫色属性未被锁定，是否继续重铸？"),L("确定")..","..L("取消"),function(flag) if flag==0 then Reset(flag) end end)
                return
            end
        end
        Reset(1)
    end
end
--铭刻
function _w.ClickImprint()
    SVR.ImpLnp(_hero.sn, _hero:GetLnpIdx(_lineup.sn), "upg", function(res)
        if res.success then 
            _imprint = ExtAtt(SVR.datCache.imp)
            Invoke(UpdateInfo, 0.1)
--            local w=PopHeroDetail
--            if w then w.LnpImpUpdate(lineup.sn) end
            --显示特效
            for i = 1,#_imps do 
                if _imps[i].rare <= 0 then 
                    _imps[i].star.gameObject:AddChild(AM.LoadPrefab("ef_lineup_imp1"),"ef_lineup_imp1")
                    _imps[i].attrib.gameObject:AddChild(AM.LoadPrefab("ef_lineup_imp2"),"ef_lineup_imp2")
                    return
                end
            end
        end
    end)    
end
--物品提示
function _w.ClickItem()
    DB.GetProps(DB_Props.ZHEN_WEN_FU):ShowData()
end
--上锁
function _w.ClickLock(idx)
    local tag = _imps[idx].lockTag
    if tag.gameObject.activeSelf then 
        tag.gameObject:SetActive(false)
        UpdateLock()
    elseif _imprint[idx] then 
        local cnt = 0
        for k,v in ipairs(_imps) do 
            if v.lockTag.activeSelf then cnt = cnt+1 end
        end
        if cnt < #_imprint then
            tag:SetActive(true)
            UpdateLock()
        end
    end
end


--[Comment]
--阵法铭刻
PopLineupImprint = _w