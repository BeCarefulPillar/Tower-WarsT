local _w = { }

local _body = nil
local _ref = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
    _ref.title.text = L("选择场景")
    c:BindFunction("OnInit", "OnUnLoad", "ClickPvp1","ClickPvp2")
end

local function CoExit()
    ToolTip.Mask(0.2, true)
    coroutine.step()
    coroutine.step()
    _body:Exit()
end

function _w.OnInit()
    if user.hlv < DB.unlock.pvp then
        _ref.lock1:SetActive(true)
        _ref.lock1:ChildWidget("Label").text = string.format(L("主城%d级后开放"), DB.param.pvp)
    else
        _ref.lock1:SetActive(false)
    end

    if user.hlv < DB.unlock.country then
        _ref.lock2:SetActive(true)
        _ref.lock2:ChildWidget("Label").text = string.format(L("主城%d级后开放"), DB.param.country)
    else
        _ref.lock2:SetActive(false)
    end
end

function _w.ClickPvp1()
    print("1")
    if user.hlv < DB.unlock.pvp then
        ToolTip.ShowPopTip(string.format(L("主城%s级后开放",
        ColorStyle.Bad(DB.unlock.pvp))))
        return
    end
    --if (MapManager.Instance) MapManager.Instance.ShowPvpMap();
    if user.TipBtnPVP and user.IsPvpUL then
        user.TipBtnPVP = false
    end
    --MainPanel.Instance.CheckTutorial();
end

function _w.ClickPvp2()
    print("2")
    if user.hlv < DB.unlock.country then
        ToolTip.ShowPopTip(string.format(L("主城%s级后开放",
        ColorStyle.Bad(DB.unlock.country))))
        return
    end
    if user.nsn <= 0 then
        MsgBox.Show(L("参加国战需要先加入国家！"), L("否,是"), function(bid)
            if bid == 1 then
                Win.Open("PopSelectCountry")
            end
        end)
        return  
    end
    Win.Open("MapNat")
    coroutine.start(CoExit)
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        --package.loaded["Game.PopSelectPvp"] = nil
    end
end

---<summary>
---pvp选择
---</summary>
PopSelectPvp = _w