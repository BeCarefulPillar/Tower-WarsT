local _w = { }

local _body = nil
local _ref = nil

local _hero = nil

local _infos = nil

--[Comment]
--将魂图片
local _soul_icon = nil
--[Comment]
--道具图片
local _props_icon = nil
--[Comment]
--将魂图片
local _skill_from = nil
--[Comment]
--将魂图片
local _skill_to = nil

--[Comment]
--升级特效
local _ef = nil

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK})

    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad",
                    "ShowSoulDesc","ShowPropsDesc","ClickSkillFrom","ClickSkillTo",
                    "ClickEvo")

    _ref = c.nsrf.ref
    _infos = _ref.infos
    _soul_icon = _ref.soul_icon
    _props_icon = _ref.props_icon
    _skill_from = _ref.skill_from
    _skill_to = _ref.skill_to
end

function _w.OnInit() 
    _hero = _w.initObj 
    if _hero then
        if _hero.IsMaxEvo then  
            ToolTip.ShowPopTip(ColorStyle.Rare(_hero) .. ColorStyle.Good(L("已达至高觉醒")))
        elseif
             _hero.rare < DB.param.rareHeroEvo then  ToolTip.ShowPopTip(ColorStyle.Rare(_hero) .. ColorStyle.Bad(L("不可觉醒")))
        else 
            if gridTexture == nil then gridTexture= GridTexture.New() end 
            local e_soul, e_level, e_props, e_cost= DB.GetHeroEvo(_hero.rare,_hero.evo)
            _infos[1].text = _hero.db:GetEvoName(_hero.evo)
            _infos[5].text = _hero.db:GetEvoName(_hero.evo + 1)
            local i = 2
            if _hero.db.estr > 0 then 
                _infos[i + 4].text = L("武力:") .. (_hero.MaxStr + _hero.db.estr)
                _infos[i].text = L("武力:") .. _hero.MaxStr
                i = i + 1
            end                                
            if _hero.db.ewis > 0 then        
                _infos[i + 4].text = L("智力:") .. (_hero.MaxWis + _hero.db.ewis)
                _infos[i].text = L("智力:") .. _hero.MaxWis     
                i = i + 1
            end                                 
            if _hero.db.ecap > 0 then             
                _infos[i + 4].text = L("统帅:") .. (_hero.MaxCap + _hero.db.ecap)
                _infos[i].text = L("统帅:") .. _hero.MaxCap    
                i = i + 1
            end                               
            if _hero.db.ehp > 0 and i < 4 then      
                _infos[i + 4].text = L("生命:") .. (_hero.MaxHP + _hero.db.ehp)
                _infos[i].text = L("生命:") .. _hero.MaxHP  
                i = i + 1
            end                                
            if _hero.db.esp > 0 and i < 4 then  
                _infos[i + 4].text = L("技力:") .. (_hero.MaxSP + _hero.db.esp)
                _infos[i].text = L("技力:") .. _hero.MaxSP       
                i = i + 1
            end                                 
            if _hero.db.etp > 0 and i < 4 then    
                _infos[i + 4].text = L("兵力:") .. (_hero.MaxTP + _hero.db.etp)
                _infos[i].text = L("兵力:") .. _hero.MaxTP          
                i = i + 1
            end

            for j = 2, 4 do
                _infos[j].gameObject:SetActive(i > j)
                _infos[j + 4].gameObject:SetActive(i > j)
            end
            _infos[9].text=user.GetSoulQty(_hero.dbsn).."/"..e_soul
            _infos[9].color = (user.GetSoulQty(_hero.dbsn) < e_soul) and Color.red or Color.green
            
            local props= DB.GetProps(DB_Props.HUN_YUAN_DAN)
            _infos[10].text=user.GetPropsQty(DB_Props.HUN_YUAN_DAN).."/"..e_props
            _infos[10].color =(user.GetPropsQty(DB_Props.HUN_YUAN_DAN)< e_props) and Color.red or Color.green
            
            _infos[11].text = tostring(e_cost)
            
            local skill=DB.GetSke(_hero.db.ske)
            _infos[12].text = skill.nm
            _infos[13].text = _hero.evo> 0 and "Lv:" .. _hero.evo or L("未解锁")  
            _infos[13].color = _hero.evo > 0 and Color.white or Color.red
            _infos[14].text = skill.nm
            _infos[15].text = "Lv:" .. (_hero.evo + 1)

            gridTexture:Add(_soul_icon:LoadTexAsync(ResName.HeroIcon(_hero.db.img)))
            _soul_icon:GetCmp(typeof(LuaButton)):SetClick("ShowSoulDesc",_hero.db)
            gridTexture:Add(_props_icon:LoadTexAsync(ResName.PropsIcon(props.img)))
            _props_icon:GetCmp(typeof(LuaButton)):SetClick("ShowPropsDesc",props)
            gridTexture:Add(_skill_from:LoadTexAsync(ResName.SkillIconE(_hero.db.ske)))
            gridTexture:Add(_skill_to:LoadTexAsync(ResName.SkillIconE(_hero.db.ske)))
            _skill_from:GetCmp(typeof(LuaButton)):SetClick("ClickSkillFrom")
            _skill_to:GetCmp(typeof(LuaButton)):SetClick("ClickSkillTo")
        end
    else 
        _body:Exit()
    end
end

function _w.OnDispose()
    if _ef ~= nil then
        _ef.Destroy()
        _ef = nil
    end

    _hero = nil
    _skill_from:UnLoadTex()
    _skill_to:UnLoadTex()
    _soul_icon:UnLoadTex()
    _props_icon:UnLoadTex()
end



function _w.OnUnLoad(c)
    _body = nil
    _ref = nil
end

function _w.ShowSoulDesc(h)
    h:ShowSoulDesc()
end
function _w.ShowPropsDesc(p)
    p:ShowDesc()
end
function _w.ClickSkillFrom()
    if _hero then ToolTip.ShowPropTip(DB.GetSke(_hero.db.ske):getPropTip(_hero.evo)) end
end
function _w.ClickSkillTo()
    if _hero then ToolTip.ShowPropTip(DB.GetSke(_hero.db.ske):getPropTip(_hero.evo + 1)) end
end

--觉醒
function _w.ClickEvo()
    if _hero then
        SVR.HeroEvolution(_hero.sn,function(res)
            if res.success then
                _ef = _body:AddChild(AM.LoadPrefab("ef_hero_evo")):Destroy(3)
                _w.OnInit()
            end
        end)
    end
end


--[Comment]
--觉醒
PopHeroEvo = _w