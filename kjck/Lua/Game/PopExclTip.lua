local _w = { }

local _body = nil
local _ref = nil

function _w.OnLoad(c)
    _body = c
    c:BindFunction("OnInit","OnDispose","OnUnLoad")
    _ref = c.nsrf.ref


end

function _w.OnInit() 
    local data = _w.initObj
    local hero = nil
    local equip = nil
    local e_py = nil
    if objt(data) == DB_Hero then 
        hero = data
        equip = DB.GetExclEquip(hero.sn)
    elseif objt(data)==PY_Hero then 
        hero = data.db
        e_py = data:GetExclEquip()
        equip = e_py == nil and DB.GetExclEquip(hero.sn) or e_py.db
    end

    if hero and equip then
        _ref.title.text = hero.nm..L("专属")
        _ref.eName.text = equip.nm
        _ref.eName.color = ColorStyle.GetRareColor(equip.rare)  
        _ref.frame.spriteName = "frame_" .. equip.rare
        _ref.icon:LoadTexAsync(ResName.EquipIcon(equip.img))
        local s = ""
        local excl = equip:GetExclAtt(e_py == nil and 0 or e_py.exclStar) 
        if excl then 
            local head = e_py ~= nil and e_py.ExclActive and (ColorStyle.GoldStar.. ColorStyle.GOOD) or (ColorStyle.GreyStar..ColorStyle.GREY)
            for i=1,#excl do s = s..(i>1 and "\n" or "" )..head..DB.GetAttWord(excl[i])..ColorStyle.EncodeEnd end 
        end
        _ref.attrib.text = s
        _body.transform.position = UICamera.lastWorldPosition
        _ref.root.transform.localPosition = Vector3(136,-15,0)
    else 
        _body:Exit()
    end
end

function _w.OnDispose()

end

function _w.OnUnLoad(c)
    _body = nil
    _ref = nil
end


--[Comment]
--专属提示
PopExclTip = _w