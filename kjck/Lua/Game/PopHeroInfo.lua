local _w = { }

local _infos = nil
local _title = nil
function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK})
    _body = c
    c:BindFunction("OnInit","OnDispose")
    _ref = c.nsrf.ref
    _infos = _ref.infos
    _title = _ref.title
end

function _w.OnInit() 
    print("PopHeroInfo: -----OnInit------")
    hero = PopHeroInfo.initObj
    if objt(hero)== PY_Hero then
        -- 标题（武将名称）
        _title.text = hero:getName()
        -- 等级信息
        _infos[1].text = hero.lv
        -- 将星信息
        local from = hero.star > 0 and DB.GetHeroStar(hero.star) or DB_HeroStar.undef
        _infos[2].text = string.format("%d%s%d%s", DB_HeroStar.GetStar(from.sn), L("星"), DB_HeroStar.GetLv(from.sn), L("级"))
        -- 军衔信息
        _infos[3].text = DB.GetHeroTtlNm(hero.ttl).. "(" .. hero.ttl .. L("阶)") 
        -- 生命信息
        _infos[4].text = hero.MaxHP
        -- 技力信息
        _infos[5].text = hero.MaxSP
        -- 兵力信息
        _infos[6].text = hero.MaxTP
        -- 武力信息
        _infos[7].text = hero.str
        -- 智力信息
        _infos[8].text = hero.wis
        -- 统帅信息
        _infos[9].text = hero.cap
        local atts = ExtAtt()
        -- 统计装备加成
        --[Comment]
        -- 所穿戴的套装所属ID，去重
        local suitID = { }
        for i = 1, 5 do
            local equip = hero:GetEquip(i)
            if equip then
                -- 添加专属加成
                if equip.exclAtt then
                    atts:Add(equip.exclAtt)
                end
                -- 添加幻化加成
                if equip.ecAtt then
                    atts:Add(equip.ecAtt)
                end
                if equip.db.suit > 0 and not table.contains(suitID,equip.db.suit) then table.insert(suitID,equip.db.suit) end--记录套装ID
                -- 添加宝石加成
                if equip.gems then
                    atts:Add(equip.gems)
                end
            end
        end

        -- 统计套装加成(在遍历完装备后)
        for i = 1, #suitID do
            local es = DB.GetEquipSuit(suitID[i])
            local qty = hero:GetSuitQty(es.sn)
            -- 该属性激活
            if es:CheckExcl(hero.db.sn) then atts:Add(es) end
        end
--        -- 统计副将加成
--        if hero.dehero then
--            -- 添加专属加成
--            if hero.dehero.ExclActive then atts:Add(hero.dehero.db.exclAtt) end
--            -- 添加天赋
--            local talent = hero.dehero.Talent
--            if talent then atts:Add(talent) end
--            -- 添加军备加成
--            for b = 1, 3 do
--                local e = hero.dehero:GetEquip(b)
--                if e then
--                    -- 添加洗炼加成
--                    atts:Add(e.att)
--                end
--            end
--        end
        -- 统计将星加成
        if hero.db.starAtt then atts:Add(hero.db.starAtt) end
        -- 统计觉醒加成
        local evoSkill = DB.GetSke(hero.db.ske)
        if evoSkill then atts:Add(evoSkill) end
--        -- 全局天机加成
--        local gslv = hero.slv
--        for k, satt in ipairs(DB.satt) do  
--            if satt.sn > gslv then atts:Add(satt.att) end
--        end
        -- 根据索引为每个附加属性赋值
        local nms = {ATT_NM.Crit,ATT_NM.SCrit,ATT_NM.CritDmg,ATT_NM.Dodge,ATT_NM.SDodge,
            ATT_NM.SoA,ATT_NM.SPR,ATT_NM.SSR,ATT_NM.SStun,ATT_NM.CPD,ATT_NM.CSD,ATT_NM.CD,
            ATT_NM.MoveSpeed,ATT_NM.CC,ATT_NM.DG}
        local a = 1
        for n = 10, 24 do
            if n~=22 then 
                _infos[n].text = atts[nms[a]] and atts[nms[a]] .. (n<24 and"%" or "") or "0"
                a = a + 1
            end
        end
        local atks = 0
        if atts[ATT_NM.AtkSpeed]  then atks = atks+ atts[ATT_NM.AtkSpeed] end
        if atts[ATT_NM.QAtkSpeed] then atks = atks+ atts[ATT_NM.QAtkSpeed] end
        _infos[22].text = atks > 0 and atks.."%" or "0"
        
    end
end

function _w.OnDispose()

end


--[Comment]
--将领属性详情
PopHeroInfo = _w