local Destroy = UnityEngine.Object.Destroy
local table = table
local math = math
local DB = DB
local user = user

local _ref
--[Comment]
--锻造
PopExclForge = { }
local self = PopExclForge

function PopExclForge.OnLoad(c)
    self.body = c
    _ref = c.nsrf.ref

    c:BindFunction("OnInit", "OnDispose")

    self.ef_1 = _ref.ef_1
    self.ef_2 = _ref.ef_2
    self.ef_3 = _ref.ef_3
    self.mainEquip = _ref.mainEquip
    self.subEquip = _ref.subEquip

    self.propsUtx = _ref.propsUtx
    self.propsNum = _ref.propsNum
    self.starsFrom = _ref.starsFrom
    self.starsTo = _ref.starsTo
    --[Comment]
    --1=名称1 2=属性1 3=名称2 4=属性2
    self.infos = _ref.infos

    self.btnHelp = _ref.btnHelp
    self.btnForge = _ref.btnForge

    self.btnHelp:SetClick(self.ClickHelp)
    self.btnForge:SetClick(self.ClickForge)
    self.mainEquip:GetCmp(typeof(LuaButton)):SetClick(self.ClickMainEquip)
    self.subEquip:GetCmp(typeof(LuaButton)):SetClick(self.ClickSubEquip)
    self.propsNum.cachedTransform.parent:GetCmp(typeof(LuaButton)):SetClick( function() DB.GetProps(DB.param.exclForgeProp):ShowData(user.GetPropsQty(DB.param.exclForgeProp)) end)
end

function PopExclForge.OnInit()
    self.mainEd = self.initObj

    if self.mainEd then
        local equipHero = { }

        local ues = user.GetEquips( function(e) return PY_Equip.CheckForgeOblation(self.mainEd, e) end)
        for i = 1, #ues do
            local ed = ues[i]
            if ed.IsEquiped then
                table.insert(equipHero, ed.belong)
            elseif self.subEd == nil or PY_Equip.Compare(self.subEd, ed) == true then
                self.subEd = ed
            end
        end

        if self.subEd == nil then
            if #equipHero > 0 then
                MsgBox.Show(ColorStyle.Warning(L("可用的祭品装备正被武将穿戴")), L("查看,确定"), function(input)
                    if input == 0 then
                        Win.Open("PopHeroDetail", equipHero)
                    end
                end )
            else
                ToolTip.ShowPopTip(ColorStyle.Warning(L("没有可用的祭品装备")))
            end
        end
    end

    self.UpdateInfo()
end

function PopExclForge.UpdateInfo()
    self.propsUtx:LoadTexAsync(ResName.PropsIcon(DB.param.exclForgeProp))

    if self.mainEd ~= nil then
        local cur = user.GetPropsQty(DB.param.exclForgeProp)
        local cost = self.mainEd.exclForgeCost

        self.propsNum.text = cur .. "/" .. cost
        self.propsNum.color = cur < cost and Color.red or Color.green

        self.infos[1].text = self.mainEd.nm
        self.infos[3].text = self.mainEd.nm

        local nextStar = math.min(self.mainEd.exclStar + 1, self.mainEd:MaxExclStar())

        self.starsFrom.TotalCount = self.mainEd.exclStar
        self.starsTo.TotalCount = nextStar

        self.infos[2].text = ""
        self.infos[4].text = ""

        local excl = self.mainEd.exclAtt
        if excl then
            for i = 1, #excl do
                self.infos[2].text = self.infos[2].text ..(i > 1 and "\n" or "") .. ColorStyle.GoldStar .. ColorStyle.Good(DB.GetAttWord(excl[i]))
            end

            if self.mainEd.IsMaxExclStar then
                self.infos[4].text = ColorStyle.Good(L("锻造星级已满"))
            else
                excl = DB_Equip.GetExclAtt(self.mainEd, nextStar + 1)
                for i = 1, #excl do
                    self.infos[4].text = self.infos[4].text ..(i > 1 and "\n" or "") .. ColorStyle.GoldStar .. ColorStyle.Good(DB.GetAttWord(excl[i]))
                end
            end
        else
            self.infos[2].text = ColorStyle.Bad(self.mainEd.db.excl > 0 and L("无属性") or L("非专属装备"))
            self.infos[4].text = ColorStyle.Bad(self.mainEd.db.excl > 0 and L("无属性") or L("非专属装备"))
        end

        if not PY_Equip.CheckForgeOblation(self.mainEd, self.subEd) then
            self.subEd = nil
        end

        self.btnForge:GetCmp(typeof(UIButton)).isEnabled =(self.subEd ~= nil and self.mainEd.CanExclForge)
    else
        self.propsNum.text = tostring(user.GetPropsQty(DB.param.exclForgeProp))
        self.propsNum.color = Color.white
        self.starsFrom.TotalCount = 0
        self.starsTo.TotalCount = 0
        self.infos[1].text = "----"
        self.infos[3].text = "----"
        self.infos[2].text = ""
        self.infos[3].text = ""

        self.subEd = nil

        self.btnForge:GetCmp(typeof(UIButton)).isEnabled = false
    end

    self.InitEquip(self.mainEquip, self.mainEd)
    self.InitEquip(self.subEquip, self.subEd)
end

function PopExclForge.InitEquip(go, data)
    if go then
        local t = go.transform
        if data then
            go:GetCmp(typeof(UISprite)).spriteName = "frame_" .. data.rare
            t:FindChild("img"):GetCmp(typeof(UITexture)):LoadTexAsync(ResName.EquipIcon(data.img))
            t:FindChild("name"):GetCmp(typeof(UILabel)).text = data.nm
            t:FindChild("lv"):GetCmp(typeof(UILabel)).text = "Lv:" .. data.lv
            t:FindChild("tip").gameObject:SetActive(false)

            ItemGoods.SetEquipGems(go, data.gems)
            ItemGoods.SetEquipExclStar(go, data.exclStar)
            ItemGoods.SetEquipEvo(go, data.evo, data.rare)
            ItemGoods.AddEquipEffect(go, data.rare, data.HasFrameEffect, data.IsMaxLv, data.ExclActive, data.SuitActive and data.dbsn or 0)
        else
            go:GetCmp(typeof(UISprite)).spriteName = ""
            t:FindChild("img"):GetCmp(typeof(UITexture)):UnLoadTex()
            t:FindChild("name"):GetCmp(typeof(UILabel)).text = ""
            t:FindChild("lv"):GetCmp(typeof(UILabel)).text = ""
            t:FindChild("tip").gameObject:SetActive(true)

            ItemGoods.SetEquipGems(go)
            ItemGoods.SetEquipExclStar(go)
            ItemGoods.SetEquipEvo(go)
            ItemGoods.AddEquipEffect(go)
        end
    end
end

function PopExclForge.OnDispose()
    self.mainEd = nil
    self.subEd = nil
    self.InitEquip(self.mainEquip, nil)
    self.InitEquip(self.subEquip, nil)
end

function PopExclForge.Exit()
    self.body:Exit()
end

function PopExclForge.ClickHelp()
    Win.Open("PopRule", DB_Rule.ExclForge)
end

function PopExclForge.ClickMainEquip()
    local ues = user.GetEquips( function(e) return e.CanExclForge end)
    if #ues > 0 then
        table.sort(ues,PY_Equip.Compare)
        Win.Open("PopSelectEquip",{function(sel)
            if sel and #sel>0 then
                self.mainEd = sel[1]
                self.UpdateInfo()
            end
        end,ues,{self.mainEd}})
    else
        ToolTip.ShowPopTip(ColorStyle.Warning(L("没有可锻造的专属装备")))
    end
end

function PopExclForge.ClickSubEquip()
    if self.mainEd == nil then
        ToolTip.ShowPopTip(ColorStyle.Warning(L("请先选择锻造装备")))
        return
    end

    local all = user.GetEquips( function(e) return PY_Equip.CheckForgeOblation(self.mainEd, e) end)

    if #all > 0 then
        local ava = table.findall(all, function(e) return not e.IsEquiped end)
        if #ava > 0 then
            table.sort(ava,PY_Equip.CompareInv)
            Win.Open("PopSelectEquip",{function(sel)
                if sel and #sel>0 then
                    self.subEd = sel[1]
                    self.UpdateInfo()
                end
            end,ava,{self.subEd}})
        else
            MsgBox.Show(ColorStyle.Warning(L("可用的祭品装备正被武将穿戴")), L("查看,确定"), function(input)
                if input == 0 then
                    local heros = { }
                    for i = 1, #all do
                        heros[i] = all[i].belong
                    end
                    Win.Open("PopHeroDetail", heros)
                end
            end )
        end
    else
        ToolTip.ShowPopTip(ColorStyle.Warning(L("没有可用的祭品装备")))
    end
end

function PopExclForge.ClickForge()
    if self.mainEd == nil then
        ToolTip.ShowPopTip(ColorStyle.Warning(L("请先选择锻造装备")))
        return
    end

    if not PY_Equip.CheckForgeOblation(self.mainEd, self.subEd) then
        self.subEd = nil
        self.UpdateInfo()
    end

    if self.subEd == nil then
        ToolTip.ShowPopTip(ColorStyle.Warning(L("请选择祭品装备")))
        return
    end

    SVR.EquipExclForge(self.mainEd.sn, self.subEd.sn, function(result)
        if result.success then
            self.subEd = nil
            local win = Win.GetOpenWin("WinGoods")
            if win then WinGoods.Refresh(result) end
            local phd = Win.GetOpenWin("PopHeroDetail")
            if phd then PopHeroDetail.RefreshView() end
            coroutine.start(self.OnForge)
        end
    end )
end

function PopExclForge.OnForge()
    local wt = 2
    local mask = ToolTip.Mask(2)

    self.ef_1.cachedGameObject:SetActive(true)
    self.ef_1:Replay()

    Destroy(UICopy.Copy(self.ef_1, self.propsUtx.cachedGameObject).cachedGameObject, wt + 1)

    coroutine.wait(wt)

    self.ef_1:Stop()

    local ef2 = self.propsUtx.cachedGameObject:AddChild(self.ef_2, "EF_2")
    Destroy(ef2, 1)
    ef2:SetActive(true)
    ef2 = self.subEquip:AddChild(self.ef_2, "EF_2")
    Destroy(ef2, 1)
    ef2:SetActive(true)

    self.ef_3:Replay()

    coroutine.wait(0.2)

    self.UpdateInfo()
end