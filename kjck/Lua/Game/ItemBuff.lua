

local _ibf = class()
ItemBuff = _ibf


local function OnClick(i)
    local bf = i.buff
    local dbf = i.dbf
    if bf == nil or dbf == nil then return end
    local intro = L("效果:")..dbf:GetIntroWithColor(bf:GetAtt(dbf.aid))
    local id = bf.sn / 10000
    local sksn = (bf.sn % 10000) / 10
    if id == 1 then -- 武将
        intro = L("来源:武将技-")..DB.GetSkc(sksn).nm.."\n"..intro
    elseif id == 2 then -- 副将
        intro = L("来源:副将技-")..DB.GetSkd(sksn).nm.."\n"..intro
    elseif id == 3 then -- 天机
        intro = L("来源:天机技-")..DB.GetSks(sksn).nm.."\n"..intro
    end
    if bf.multi > 1 then intro = L("叠加:")..bf.multi.."层\n"..intro end
    ToolTip.ShowPropTip(dbf.nm, intro)
end

function _ibf.ctor(i, ctrl, go)
    assert(ctrl and notnull(go), "create ItemBuff need BU_Control and gameObject")
    i.go = go
    i.ctrl = ctrl
    i.icon = go:ChildWidget("tex_icon")
    i.rep = go:ChildWidget("lab_rep")
    i.mask = go:ChildWidget("sp_mask")
    i.tag = go:ChildWidget("sp_tag")
end

function _ibf.Init(i, bf, dbf)
    i.bf = bf
    i.dbf = dbf
    print("dbf ", kjson.print(dbf))
    if bf == nil or dbf == nil or bf:GetAtt(dbf.aid) == 0 then i:Dispose()
    else
        i.sn = bf.sn
        i.rep.text = bf.multi > 1 and tostring(bf.multi) or ""
        i.mask.fillAmount = bf.timePercent
        i.tag.spriteName = "sp_buff_"..(DB_Buff:IsDebuff(dbf, bf:GetAtt(dbf.aid)) and 1 or 0)
        i.utl = i.icon:LoadTexAsync(ResName.BuffIcon(dbf.sn))
        local btn = i.go:GetCmp(typeof(LuaButton))
        btn:SetClick(OnClick, i)
        i.go:SetActive(true)
        local w = i.go:GetCmp(typeof(UIWidget)) or i.go:AddCmp(typeof(UIWidget))
        w.alpha = 0
        EF.Alpha(w, 0.2, 1);
        if i.ctrl and notnull(i.ctrl.go) then
            w = i.ctrl.go:GetCmp(typeof(UIGrid))
            if w then w.repositionNow = true end
        end
    end
end

function _ibf.Update(i)
    if i.bf ~= nil and i.bf.sn == i.sn and i.bf.isAlive and i.bf:GetAtt(i.dbf.aid) ~= 0 then
        i.mask.fillAmount = (i.bf.lifeTime < 1000 or i.bf.isEver) and 1 or i.bf.timePercent
        if i.bf.multi > 1 then i.rep.text = tostring(i.bf.multi) end
    else i:Dispose()
    end
end

function _ibf.MatchAddsn(i, bf, sn) return i.bf ~= nil and i.bf == bf and i.dbf ~= nil and i.dbf.sn == sn end

function _ibf.Match(i, bf) return i.bf ~= nil and i.bf == bf end

function _ibf.Dispose(i)
    i.sn = nil
    i.bf = nil
    i.dbf = nil
    i.go:SetActive(false)
    if i.ctrl then
        i.ctrl:OnItemDispose(i)
        if notnull(i.ctrl.go) then
            w = i.ctrl.go:GetCmp(typeof(UIGrid))
            if w then w.repositionNow = true end
        end
    end
end
