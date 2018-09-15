local _w = { }
ItemHeroResult = _w

function _w:OnLoad(c)
    table.copy(c.nsrf.ref, self)
    self.go = c.gameObject
    self.body = c
    self.upt = UpdateBeat:CreateListener(self.Update, self)
    self.speed=1
    UpdateBeat:AddListener(self.upt)
end

function _w:Init(hd, level, exp)
    if not hd then
        return
    end
    print(tts(hd))
    self.show = false
    self.showAtt = false
    self.attQueue = nil
    self.lastLab = nil
    self.hd = hd
    self.curLv = math.clamp(level, 1, hd.lv)
    exp = math.clamp(exp, 0, hd.exp)
    self.toExp = math.clamp(hd.PercentExp, 0, 0.999) + math.max(hd.lv - level, 0)

    self.heroName.text = hd:GetEvoName(hd.evo)
    self.heroIcon:LoadTexAsync(ResName.HeroIcon(hd.db.img))
    self.heroLv.text = tostring(level)
    self.heroStar.TotalCount = hd.star
    local lvExp = DB.GetHeroLvExp(level)
    self.heroExpPro.value = math.clamp01((exp - lvExp) /(DB.GetHeroLvExp(level + 1) - lvExp))
    self.heroExp.text = string.format("%0.1f%%", self.heroExpPro.value * 100)
    self.expAdd.text = L("经验+") .. hd.exp - exp
end

function _w:ShowEffectQuickly()
    self.show = true
    self.speed = 10000
end

function _w.ShowHeroAtt()
    if self.showAtt or not self.attQueue then
        return
    end

    self.showAtt = true

    while #self.attQueue > 0 do
        local str = table.remove(self.attQueue, 1)
        if string.isEmpty(str) then
            coroutine.wait(0.5)
        else
            local lab = self.go:AddWidget(typeof(UILabel), "attrib")
            Destroy(lab.gameObject, 2.5)
            lab.trueTypeFont = AM.mainFont
            lab.fontSize = 32
            lab.width = 128
            lab.height = 32
            lab.depth = 200
            lab.effectStyle = UILabel.Effect.Outline
            lab.effectDistance = Vector2(0.5, 0.5)
            lab.applyGradient = true
            lab.gradientTop = Color.white
            lab.text = "[b]" .. str

            if string.find(str, L("武")) == 1 then
                lab.gradientBottom = ColorStyle.GetHeroAttColor(1)
            elseif string.find(str, L("智")) == 1 then
                lab.gradientBottom = ColorStyle.GetHeroAttColor(2)
            elseif string.find(str, L("统")) == 1 then
                lab.gradientBottom = ColorStyle.GetHeroAttColor(3)
            elseif string.find(str, L("命")) == 1 then
                lab.gradientBottom = ColorStyle.GetHeroAttColor(4)
            elseif string.find(str, L("技")) == 1 then
                lab.gradientBottom = ColorStyle.GetHeroAttColor(5)
            elseif string.find(str, L("兵")) == 1 then
                lab.gradientBottom = ColorStyle.GetHeroAttColor(6)
            end

            if self.lastLab then
                EF.bdMinDis(self.lastLab.cachedGameObject, lab.cachedTransform, 32)
            end
            self.lastLab = lab

            lab.cachedTransform.localScale = Vector3(1.1, 1.1, 1.1)
            lab.cachedTransform.localPosition = Vector3(0, 0, 0)

            EF.ColorFrom(lab, "a", 0.3, "time", 0.2)
            EF.MoveFrom(lab, "y", -90, "time",
            0.3, "islocal", true, "easetype", iTween.EaseType.easeOutExpo)
            EF.ScaleFrom(lab, "scale", Vector3(1.4, 1.4, 1.4), "time",
            0.3, "easetype", iTween.EaseType.easeOutQuad)
            coroutine.wait(0.2)
            TweenAlpha.Begin(lab, 0.5, 0).delay = 1
        end
    end

    self.showAtt = false
end

function _w:SetLvTxT(lv)
    coroutine.wait(1)
    self.heroLv.text = tostring(lv)

    if user.battleRet.kind == 1 then
        return
    end

    --检测是否解锁技能
    if self.hd then
        local skill = self.hd:LvULSkc(lv)
        if skill.sn > 0 then
            coroutine.start(Tools.ShowSkillUL, skill, self.go.transform.position, true)
        else
            skill = self.hd:LvULSkt(lv)
            if skill.sn > 0 then
                coroutine.start(Tools.ShowSkillUL, skill, self.go.transform.position, false)
            end
        end
    end

    if self.hd and lv > 1 then
        if not self.attQueue then
            self.attQueue = { }
        end
        table.insert(self.attQueue, L("武+") .. self.hd.db.lstr)
        table.insert(self.attQueue, L("智+") .. self.hd.db.lwis)
        table.insert(self.attQueue, L("统+") .. self.hd.db.lcap)
        table.insert(self.attQueue, "")
        if not self.showAtt then
            coroutine.start(self.ShowHeroAtt, self)
        end
    end
end

function _w:Update()
    if self.show and self.heroExp then
    print(self.toExp)
    print(self.speed)
        if self.heroExpPro.value < self.toExp then
            self.heroExpPro.value = self.heroExpPro.value + math.min(Time.deltaTime, 0.04) * self.speed
            if self.heroExpPro.value >= 1 then
                self.heroExpPro.value = 0
                self.toExp = self.toExp - 1
                --播放升级动画
                self.upef = self.go:AddChild(self.ef_up, "ef_hero_up")
                Destroy(self.upef, 2)
                self.curLv = self.curLv + 1
                self.curLv = math.min(self.curLv, hd.lv)
                --等级文本改变
                coroutine.start(self.SetLvTxT, self, self.curLv)
            end
            if not self.ef_exp.activeSelf then
                self.ef_exp:SetActive(true)
            end
            if not self.ef_exp.isPlaying then
                self.ef_exp:Play()
            end
            self.ef_exp.cachedTransform.localPosition = Vector3(3 + 96 * self.heroExpPro.value, 210, 0)
        else
            self.ef_exp:Stop()
            self.heroExpPro.value = self.toExp
            self.show = false
        end

        self.heroExp.text = string.format("%0.1f%%", self.heroExpPro.value * 100)
    end
end

function _w:ShowEffect()
    self.show = true
end

function _w:IsShow()
    return self.show or self.upef --or PopTutorialHeroUp.IsShow(self.hd)
end

function _w:OnUnLoad(c)
    print("OnUnLoad")
    if self.body == c then
        print("OnUnLoad")
        self.heroIcon:UnLoadTex()
        UpdateBeat:RemoveListener(self.upt)
    end
end