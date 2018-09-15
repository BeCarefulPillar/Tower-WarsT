PopEquipExcl = { }
local _body
local root = nil
local title = nil
local attrib = nil
local condition = nil
local stars = nil
local btnForge = nil
PopEquipExcl.body = _body
local _ref

function PopEquipExcl.OnLoad(c)
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
    condition = _ref.condition
    stars = _ref.stars
    btnForge = _ref.btnForge
    root = _ref.root
end

function PopEquipExcl.OnInit() 
    local equip = PopEquipExcl.initObj 
    if  equip ~= nil and equip.db.excl  then
        title.text = DB.GetHero(equip.db.excl).nm .. L("专属")
        stars.TotalCount = equip.exclStar 
        stars.transform.localScale = Vector3(1, equip.exclStar > 0 and 1 or 0, 1)
        print(kjson.encode(user.ally))
        if (not equip.IsEquiped) or  equip.belong.db.sn~=equip.db.excl  then
            condition.text = "[FF4600]" .. L("激活条件") .. ":[-][FF0000]" .. DB.GetHero(equip.db.excl).nm .. L("装备") .. "[-]"
        elseif not user.ally or not user.ally.gsn or tonumber(user.ally.gsn)<=0  then
            condition.text = "[FF4600]" .. L("激活条件") .. ":[-][FF0000]" .. L("加入联盟") .. "[-]"
        else
            condition.text = "[FF4600]" .. L("激活条件") .. ":[-][00FF00]" .. L("已激活") .. "[-]"
        end
        attrib.text = ""
        local excl = equip.exclAtt
        if excl then
            for i = 1, #excl do
                if equip.ExclActive then
                    attrib.text = attrib.text ..(i > 1 and "\n" or "") .. ColorStyle.GoldStar .. ColorStyle.Good(DB.GetAttWord(excl[i]))
                else
                    attrib.text = attrib.text ..(i > 1 and "\n" or "") .. ColorStyle.GreyStar .. ColorStyle.Grey(DB.GetAttWord(excl[i]))
                end
            end 
        end
        if equip.CanExclForge then
            btnForge.transform.localScale=Vector3(1,1,1)
            local lab=btnForge:GetCmpInChilds(typeof(UILabel),false)
            if user.IsExclForgeUL then  
                btnForge:GetCmp(typeof(UnityEngine.BoxCollider)).enabled=true
                btnForge:GetCmp(typeof(LuaButton)):SetClick("ClickForge",equip)
                btnForge:GetCmp(typeof(UIButton)).isEnabled=true
                lab.applyGradient = false
                lab.text = L("锻造")
            else
                btnForge:GetCmp(typeof(UnityEngine.BoxCollider)).enabled=false
                btnForge:GetCmp(typeof(UIButton)).isEnabled=false
                lab.applyGradient = true;
                lab.text = string.format(L("主城").."%d"..L("级开启锻造"), DB.unlock.exclForge)
            end
        else
            btnForge.transform.localScale=Vector3(1,0,1)
            btnForge:GetCmp(typeof(UnityEngine.BoxCollider)).enabled=false
            btnForge:GetCmp(typeof(UIButton)).isEnabled=false
        end
        _body.transform.position=UICamera.lastWorldPosition
        local w=PopHeroDetail
        print("open??",w and w.isOpen or "未打开诶!")
        root.transform.localPosition =  Vector3(w and w.isOpen and -136 or 136, 0, 0)
    else PopEquipExcl.body:Exit()
    end
end

function PopEquipExcl.OnDispose()
    title.text = ""
    attrib.text = ""
    root.transform.localPosition = Vector3.zero
    _body.transform.localPosition = Vector3.zero
end



function PopEquipExcl.ClickForge(param)
    Win.Open("PopExclForge", param)
    _body:Exit()
end