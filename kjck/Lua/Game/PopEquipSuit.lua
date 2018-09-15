PopEquipSuit = { }
local _body
PopEquipSuit.body = _body
local root = nil
local title = nil
local attrib = nil
local intro = nil
local _ref 

function PopEquipSuit.OnLoad(c)
    _body = c
    _ref = _body.nsrf.ref

    -- 生命周期方法绑定
    c:BindFunction("OnEnter", "OnEnable")
    c:BindFunction("Refresh", "OnDisable")
    c:BindFunction("OnExit")
    c:BindFunction("OnInit")
    c:BindFunction("OnDispose")

    c:BindFunction("ClickForge")
    -- 组件绑定
    title = _ref.title
    attrib = _ref.attrib
    intro = _ref.intro
    root= _ref.root
end

function PopEquipSuit.OnEnter()  
end
 
function PopEquipSuit.OnInit()
print("PopEquipSuit: -----oninit------")
    local suit = nil
    local belong = nil
    local equip = PopEquipSuit.initObj 
    if not equip then print("警告!","PopEquipSuit.initObj 为空值!!!!") end
    if equip then 
        if objt(equip)== PY_Equip then
            if equip.db.suit > 0 then
                suit = DB.GetEquipSuit(equip.db.suit)
                belong = equip.belong 
            end
        elseif objt(equip)== DB_EquipSuit then
            suit = equip
        end 
        if suit==nil then PopEquipSuit.body:Exit()
        else
            title.text=suit.nm
            attrib.text=""
            if suit.att ~=nil then
                local qty=(belong~=nil and suit:CheckExcl(belong.dbsn)) and belong:GetSuitQty(suit.sn) or 0 
                for i=1,#suit.att do
                    if i<qty then attrib.text=attrib.text..(i > 1 and "\n" or "")..ColorStyle.Good("(" .. number.ToCnString(i + 1) .. ")"..L("套装").."：\n  [FFFF40]★[-]"..DB.GetAttWord(suit.att[i]))
                    else attrib.text=attrib.text..(i > 1 and "\n" or "")..ColorStyle.Grey("(" .. number.ToCnString(i + 1) .. ")"..L("套装").."：\n  [FFFF40]★[-]"..DB.GetAttWord(suit.att[i]))
                    end
                end
            end
        end
        
        if suit.excl>0 then
              intro.text=L("专属武将")..(belong~=nil and belong.db.sn==suit.excl and "" or ColorStyle.BAD)..DB.GetHero(suit.excl).nm..ColorStyle.EncodeEnd..(string.isEmpty(suit.i) and "" or ("\n"..suit.i))
        else intro.text=suit.i
        end
        _body.transform.position=UICamera.lastWorldPosition
        root.transform.localPosition=Vector3(PopHeroDetail and PopHeroDetail.isOpen and -136 or 136,0,0)
    end
    
end

function PopEquipSuit.OnDispose()
    title.text = ""
    attrib.text = ""
    root.transform.localPosition = Vector3.zero
    _body.transform.localPosition = Vector3.zero
end
