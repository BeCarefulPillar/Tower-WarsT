local ipairs = ipairs

local _w = { }

local _body = nil
local _ref = nil

local _tec = nil
local _sn = nil
local _lv = nil
local _dat = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
    _sn = 0
    _lv = 0
    for i, v in ipairs(_ref.labAsk) do
        v:SetActive(false)
    end
end

local function BulidItem()
    if not _tec then
        return
    end

    local t = _tec[_sn]
    _ref.labSkillPoint.text = L("剩余技能点：") .. _dat.skillPoint

    --当前等级数据
    local valNow = t.vals[_lv] or 0

    --下一等级数据  如果是最高级则是最高等级数据
    local maxLv = #t.vals
    local valNext = t.vals[_lv >= maxLv and _lv or _lv + 1]
    _ref.labName.text = "[CCB13F]" .. t.nm .. ":[-][00ff00]Lv." .. _lv

    _ref.labInfo.text = string.format(t.intro,
    valNow > 0 and ColorStyle.Orange(valNow .. "") or ColorStyle.Grey(valNow .. ""))

    _ref.labValueNow.text = tostring(valNow)
    _ref.labValueNow:SetActive(_lv < maxLv)
    _ref.labValueNext.text = _lv >= maxLv and L("满级") or tostring(valNext)

    --加载图片
    _ref.texIcon:LoadTexAsync("tech_p_" .. _sn)

    --是否解锁
    local isUnLock = false

    if #t.ask > 0 then
        local ask = t.ask
        for i, v in ipairs(ask) do
            local askSn = v[1]
            local askLv = v[2]
            _ref.labAsk[i].text = L("需要") .. _tec[askSn].nm .. "    Lv." .. askLv
            if _dat.techSkill[askSn * 2] >= askLv then
                _ref.labAsk[i]:ChildWidget("sp_state").spriteName = "sp_tech_yes"
                isUnLock = true
            else
                _ref.labAsk[i]:ChildWidget("sp_state").spriteName = "sp_tech_no"
            end
            _ref.labAsk[i]:SetActive(true)
        end
    end

    --不需要前置条件或满足前置条件，且技能点大于0，
    --等级小于最高级，且国家等级不小于需要解锁的国家等级，则将按钮激活
    if ((not(#t.ask > 0) or isUnLock)) and _dat.skillPoint > 0 and _lv < maxLv and user.nat.lv >= t.unlock then
        _ref.btnAdd.isEnabled = true
        _ref.btnAddOne.isEnabled = true
    else
        _ref.btnAdd.isEnabled = false
        _ref.btnAddOne.isEnabled = false
    end
end

function _w.OnInit()
    if type(_w.initObj) == "table" then
        _tec = DB.Get(LuaRes.Tech_P)
        _sn = _w.initObj.sn
        _lv = _w.initObj.lv
        _dat = _w.initObj.dat
        BulidItem()
    end
end

--[Comment]
--加点
function _w.ClickAdd()
    SVR.TechPersonal("up|" .. _sn .. "|1", function(t)
        if t.success then
            --stab.S_TechP
            _dat = SVR.datCache
            _lv = _dat.techSkill[2 * _sn]
            BulidItem()
        end
    end )
end

--[Comment]
--一键加点
function _w.ClickAddOne()
    SVR.TechPersonal("up|" .. _sn .. "|2", function(t)
        if t.success then
            --stab.S_TechP
            _dat = SVR.datCache
            _lv = _dat.techSkill[2 * _sn]
            BulidItem()
        end
    end )
end

function _w.OnDispose()
    _ref.labName.text = ""
    _ref.labInfo.text = ""
    _ref.labValueNow.text = ""
    _ref.labValueNext.text = ""
    _ref.labSkillPoint.text = ""
    for i, v in ipairs(_ref.labAsk) do
        v.text = ""
        v:SetActive(false)
    end
    _ref.texIcon:UnLoadTex()
end

function _w.ClickCheck()
    Win.Open("PopTechBrowse", _tec[_sn])
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _tec = nil
        _sn = nil
        _lv = nil
        _dat = nil
        --package.loaded["Game.PopTechInfoLvUp"] = nil
    end
end

---<summary>
---科技
---</summary>
PopTechInfoLvUp = _w