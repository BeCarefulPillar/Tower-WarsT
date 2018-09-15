local ipairs = ipairs

local _w = { }

local _body = nil
local _ref = nil
local _dat = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, {n=L("武斗场")})

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "ClickRank",
    "OnUnLoad"
    )

    _dat = {
        { nm = L("战役"), open = true, lv = DB.unlock.gmWar, ul = user.IsWarUL },
        { nm = L("竞技场"), open = true, lv = DB.unlock.rank, ul = user.IsRankUL },
        { nm = L("乱世争雄"), open = true, lv = DB.unlock.gmClan, ul = user.IsClanWarUL },
        { nm = L("极限挑战"), open = false, },
    }
end

function _w.OnInit()
    --WinBg.SetName("武斗场");
    --WinBg.RefreshInfo();

    local r = nil
    local date = nil
    for i, v in ipairs(_dat) do
        r = _ref.Panel:AddChild(_ref.rank, string.format("rank_%02d", i))
        r:SetActive(true)
        date = r:ChildWidget("lab_date")
        if v.open then
            date.text = v.ul and L("全天开放") or L("主城") .. v.lv .. L("级开启")
            r.luaBtn.param = i
        else
            date.text = L("敬请期待")
        end
        date.color = v.ul and ColorStyle.OutLight_2 or ColorStyle.Red
        r:ChildWidget("lock"):SetActive(not v.ul)
        r:ChildWidget("title_bg").spriteName = "bg_jiaobiao" ..(i % 2 == 1 and "1" or "2")
        r:ChildWidget("hero"):LoadTexAsync("rank_war_new_" .. i)
        r:ChildWidget("title").text = v.nm
    end
    _ref.Panel.repositionNow = true
end

function _w.ClickRank(i)
    if i == 1 then
        Win.Open("WinWar")
    elseif i == 2 then
        Win.Open("WinRankSolo")
    elseif i == 3 then
        Win.Open("WinClanWar")
    end
end

function _w.OnDispose()
    _ref.Panel:DesAllChild()
    print("dis")
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _dat = nil
        --package.loaded["Game.WinRank"] = nil
    end
end

--[Comment]
--武场
WinRank = _w