local _w = { }

local _body = nil
local _ref = nil

local btnUp = nil
local btnSet = nil
local skillPanel = nil
local matPanel = nil
local item_goods = nil
--[0=名称，1=当前等级，2=当前属性，3=当前学习条件，4=下一等级，5=下一属性，6=学习/升级]
local infos = nil


local hero = nil
local items = nil
local sel = nil
local mats = nil
local skills = nil

local function SetMat(rws)
    print("SetMatSetMatSetMat    ",kjson.print(rws))
   if rws and #rws > 0 then 
        if not mats then mats = {} end
        for i = 1,#rws do  
            if mats[i] == nil or mats[i].go == nil then 
                mats[i] = ItemGoods(matPanel:AddChild(item_goods, "mat_"..i))
                mats[i].go.transform.localScale=mats[i].go.transform.localScale * 0.8
                mats[i].go.luaBtn:SetClick("ClickMat")
                mats[i].go.luaBtn.luaContainer = _body
                mats[i].name:SetActive(false)
                mats[i].go:SetActive(true)
            else
                mats[i].go:SetActive(true)
            end
            mats[i]:Init(rws[i])
        end
        if #mats > #rws then for i = #rws + 1,#mats do mats[i].go:SetActive(false) end end
   elseif mats then
     for k,v in ipairs(mats) do v.go:SetActive(false) end
   end
end


local function IEBuildItems()
    skills = DB.skp
    print("----skills--------",kjson.encode(skills),#skills)
    items={}
    local first = true
    local grid=skillPanel:GetCmp(typeof(UIWrapGrid))
    grid:Reset()
    grid.realCount = #skills + 1
    local scorollView = skillPanel:GetCmp(typeof(UIScrollView))
    scorollView.enabled = #skills > 6
end

local function RefreshSkill(init)
    if init then IEBuildItems()
    else 
        for i = 1,#items do 
            local data= items[i].dat
            items[i].BeUsed = data.sn == hero.skp
--            items[i].Selected = data.sn == hero.skp
        end
    end
end

function _w.RefreshInfo()
    local data = sel and sel.dat or nil
    if data then 
        local lv = hero:GetSkpLv(data.sn)
        local canLearn = true 
        if data.rsk > 0 then canLearn = hero:GetSkpLv(data.rsk) >= data.rlv end
        local tlist--用来储存TEXT数据  [1=名称，2=当前等级，3=当前属性，4=当前学习条件，5=下一等级，6=下一属性，7=学习/升级]
        tlist = { 
                [1] = data == DB_SKP.undef and L("不使用锦囊技") or data.nm    ,
                [2] = lv > 0 and L("当前等级")..":"..lv or L("学习条件")..":"  ,
                [3] = lv > 0 and data:getIntro(lv) or ""                     ,
                [4] = lv > 0 and "" or (data.rsk>0 and DB.GetSkp(data.rsk).nm..L("达到")..data.rlv or L("无")),
                [5] = lv < data:MaxLevel() and L("下一等级")..":"..(lv+1) or L("等级已满"),
                [6] = lv < data:MaxLevel() and data:getIntro(lv+1) or ""     ,
                [7] = lv <= 0 and L("学习消耗")..":" or lv<data:MaxLevel() and L("升级消耗")..":" or L("等级已满")                                                     
        }
        for k,val in ipairs(infos) do val.text=tlist[k] end
        btnUp:GetCmpInChilds(typeof(UILabel),false).text= lv<=0 and L("学习") or L("升级")
        if lv>=data:MaxLevel() then canLearn=false end
        btnUp:GetCmpInChilds(typeof(UIButton)).isEnabled=canLearn 
        if lv > 0 and lv < data:MaxLevel() then 
            local rws = data:GetMat(lv+1).m
            if rws then 
                SetMat(rws) 
            else 
                SetMat()
            end
        else
            SetMat()
        end
        if hero.skp == data.sn then
            btnSet:GetCmp(typeof(UIButton)).isEnabled= false
            btnSet:GetCmpInChilds(typeof(UILabel),false).text=L("已使用")
        else
            btnSet:GetCmp(typeof(UIButton)).isEnabled= lv>0 or data == DB_SKP.undef
            btnSet:GetCmpInChilds(typeof(UILabel),false).text=L("使用")
        end
        matPanel:GetCmp(typeof(UIGrid)).repositionNow = true
    else
        for k,val in ipairs(infos) do val.text = "" end
        btnUp:GetCmp(typeof(UIButton)).isEnabled = false
        btnSet:GetCmp(typeof(UIButton)).isEnabled = false
    end
end


function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK })
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad","OnWrapGridInitItem",
                    "ClickUp","ClickSet","ClickSkill","ClickMat")
    _ref = c.nsrf.ref
    btnUp = _ref.btnUp
    btnSet = _ref.btnSet
    skillPanel = _ref.skillPanel
    matPanel = _ref.matPanel
    item_goods = _ref.item_goods
    infos = _ref.infos

end

function _w.OnInit() 
      print("_w: -----OnInit------") 
     f = 1
     hero=_w.initObj
     if hero then 
        IEBuildItems()
     else
        _body:Exit()
     end
end
function _w.OnDispose()
    print("_w: -----OnDispose------") 
    if mats then 
        for k,v in ipairs(mats) do 
            if v.go then v.go:Destroy() end 
        end 
        mats = nil
    end
    if items then
        for i,v in ipairs(items) do
            v.Selected = false
        end
    end
    
    
    hero = nil
    sel = nil
    item = nil
end

function _w.OnUnLoad(c)
end

function _w.OnWrapGridInitItem(parent,ig, index)
    if index < 0 then return false end
    index = index + 1
    local data = index <= #skills and skills[index] or DB_SKP.undef
    local it = ItemGoods(ig)
    local lv = hero:GetSkpLv(data.sn)
    it:Init(data, lv > 0 or data == DB_SKP.undef, lv, hero:CanLearnSkp(data), data.sn == hero.skp)
    if it.BeUsed then _w.ClickSkill(it.go) end
    it.go.luaBtn:SetClick("ClickSkill",it)
    it.go.luaBtn.luaContainer = _body
    items[index] = it
    if not sel and index == 1 then _w.ClickSkill(it.go) end
    return true
end

function _w.ClickSkill(it)
    local ig = Item.Get(it)
    if sel ~= ig then 
        if sel then sel.Selected = false end
        sel = ig
        if sel then sel.Selected = true end 
        _w.RefreshInfo()
    end
end

function _w.ClickMat(ig)
    ig = Item.Get(ig)
    ig:ShowPropTip()
end

local function OnLearnUp()
    local mask = ToolTip.Mask(2)
    local rot = infos[1].transform.parent.gameObject
    if mats then
        local ef=AM.LoadPrefab("ef_skp_up_1")
        if ef then 
            for i=1,#mats do
                if mats[i] and mats[i].go.activeSelf then 
                    rot:AddChild(ef,"ef_skp_up_1").transform.position=mats[i].go.transform.position
                end
            end
            coroutine.wait(1.5)
        end
    end

    rot:AddChild(AM.LoadPrefab("ef_skp_up_2"),ef_skp_up_2,false)
    _w.RefreshInfo()
    RefreshSkill(true)
    --mask:Destroy()
end

function _w.ClickUp()
    local data = sel and sel.dat or nil
    if data then  
        SVR.LearnUpSkp(hero.sn,data.sn,function(res)
            if res.success then   
                local win = Win.GetOpenWin("PopHeroDetail")
                if w then win.RefreshSkp() end
                coroutine.start(OnLearnUp)
            end
        end)
    end
end

function _w.ClickSet()
    local data = sel and sel.dat or nil
    if data then  
        SVR.SetSkp(hero.sn,data.sn,function(res)
            if res.success then 
            print(kjson.encode(SVR.datCache))
                _w.RefreshInfo()
                RefreshSkill(false)
                local win=Win.GetOpenWin("PopHeroDetail")
                if w then win.RefreshSkp() end
            end
    end)
    end
end

function _w.ClickHelp()
    Win.Open("PopRule" , DB_Rule.PocketSkill)
end

--[Comment]
--战法
PopPocketSkill = _w