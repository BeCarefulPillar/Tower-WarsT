local _w = { }

local _body = nil
local _ref = nil

local _bg = nil
local _dat = nil
local _buildItems = nil
local _items = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    _bg = WinBackground(c, { n = L("国家科技"), i = true, r = DB_Rule.EmpireTech })

    _items = { }
    for i, v in ipairs(_ref.item_tech) do
        _items[i] = v.ref
    end
    _ref.item_tech = nil
end

local c1 = Color(128 / 255, 0, 128 / 255)
local c2 = Color(128 / 255, 128 / 255, 128 / 255)
local c3 = Color(57 / 255, 253 / 255, 57 / 255)
local c4 = Color(47 / 255, 54 / 255, 65 / 255)

local function IEBuildItems()
    local tec = DB.Get(LuaRes.Tech_P)
    for i, v in ipairs(tec) do
        local item = _items[i]
        item.tex:LoadTexAsync("tech_p_" .. v.sn)
        item.labName.text = L(v.nm)
        local skillLv = _dat.techSkill[2 * i]
        item.tex.color = skillLv <= 0 and c1 or c2

        -- 是否解锁
        if #v.ask > 0 then
            local ask = v.ask
            local isarr = false
            for j, u in ipairs(ask) do
                -- 前置条件技能的编号
                local askSn = u[1]
                -- 前置条件技能的等级
                local askLv = u[2]
                -- 解锁
                if _dat.techSkill[askSn * 2] >= askLv and user.nat.lv >= v.unlock then
                    item.arrow.color = c3
                    if #ask > 1 then
                        item.arrows[j].color = c3
                        isarr = true
                    end

                    if not isarr then
                        if item.arrows and #item.arrows > 0 then
                            item.arrows[j].color = c3
                        end
                    end
                else
                    if #ask > 1 then
                        item.arrows[j].color = c4
                    end
                    item.arrow.color = c4
                    if not isarr then
                        if item.arrows and #item.arrows > 0 then
                            item.arrows[j].color = c4
                        end
                    end
                end
            end
        end

        item.labLv.text = skillLv .. "/" .. #v.vals
        item.tex.luaBtn.param = v.sn
        coroutine.wait(0.01)
    end
    _ref.labSkillPoint.text = L("剩余技能点：") .. _dat.skillPoint
end

local function StopBuildItems()
    if _buildItems then
        coroutine.stop(_buildItems)
        _buildItems = nil
    end
end

local function BuildItems()
    StopBuildItems()
    _buildItems = coroutine.start(IEBuildItems)
end

local function UpdateInfo(dataTechP)
    _dat = dataTechP
    BuildItems()
end

function _w.OnEnter()
    UpdateEmpireTech:Add(UpdateInfo)
end

function _w.OnExit()
    UpdateEmpireTech:Remove(UpdateInfo)
end

function _w.OnInit()
    SVR.NatOverview( function(t)
        if t.success then
            ------
            for i, v in ipairs(_ref.locks) do
                if i <= user.nat.lv then
                    v:SetActive(false)
                else
                    v:SetActive(true)
                end
            end
            -- 查询技能详情
            SVR.TechPersonal("inf", function(t)
                if t.success then
                    _dat = SVR.datCache
                    -- 得到重置卡的数量
                    local props = DB.AllProps( function(p)
                        return p.sn == 122
                    end )
                    user.SetPropsQty(122, _dat.resetCard)
                    BuildItems()
                end
            end )
            ----------------
        end
    end )
end

function _w.ClickItem(sn)
    local lv = _dat.techSkill[2 * sn]
    Win.Open("PopTechInfoLvUp", { sn = sn, lv = lv, dat = _dat })
end

function _w.OnDispose()
    for i, v in ipairs(_ref.locks) do
        v:SetActive(true)
    end
    StopBuildItems()
end

function _w.ClickReset()
    Win.Open("PopTechReset")
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _bg:dispose()
        _bg = nil
        _dat = nil
        _buildItems = nil
        _items = nil
        -- package.loaded["Game.WinEmpireTech"] = nil
    end
end

--- <summary>
--- 科技
--- </summary>
WinEmpireTech = _w