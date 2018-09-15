local _w = { }

local _body = nil
local _ref = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
    _ref.btnCountry1.param = 1
    _ref.btnCountry2.param = 2
    _ref.btnCountry3.param = 3
end

function _w.OnInit()
    _ref.btnCountry1.isEnabled = user.ally.nsn ~= 1
    _ref.btnCountry2.isEnabled = user.ally.nsn ~= 2
    _ref.btnCountry3.isEnabled = user.ally.nsn ~= 3

    user.ally.remdCountry = 2

    _ref.recommend:SetActive(true)
    if user.ally.remdCountry == 1 then
        _ref.recommend.parent = _ref.btnCountry1.transform
    elseif user.ally.remdCountry == 2 then
        _ref.recommend.parent = _ref.btnCountry2.transform
    elseif user.ally.remdCountry == 3 then
        _ref.recommend.parent = _ref.btnCountry3.transform
    else
        _ref.recommend:SetActive(false)
    end
    _ref.recommend.localPosition = Vector3(-92, 181, 0)
end

function _w.ClickCountry(i)
    --if MapCountry.IsAutoPath then
    if false then
        MsgBox.Show(L("自动国战中！无法进行其他操作！是否取消自动国战"), L("否,是"), function(bid)
            if bid == 1 then
                --MapCountry.IsAutoPath=false
                MsgBox.Show(DB_Rule.GetContent(8
                --[[ DB_Rule.CountryJoin ]]
                ),
                function(flag)
                    if flag then
                        if user.nsn > 0 then
                            SVR.AllyOption("chag|" .. i, function(t)
                                if t.success then
                                    user.gsn = 0
                                    _body:Exit()
                                end
                            end )
                        else
                            SVR.AllyOption("nati|" .. i, function(t)
                                if t.success then
                                    --if (MapManager.Instance) MapManager.Instance.ShowCountryMap();
                                    Win.ExitAllWin( function(w)
                                        return true
                                    end )
                                end
                            end )
                        end
                    end
                end )
            end
        end )
    else
        MsgBox.Show(DB_Rule.GetContent(DB_Rule.CountryJoin
        --[[ DB_Rule.CountryJoin ]]
        ),
        function(flag)
            if flag then
                if user.nsn > 0 then
                    SVR.AllyOption("chag|" .. i, function(t)
                        if t.success then
                            user.gsn = 0
                            _body:Exit()
                        end
                    end )
                else
                    SVR.AllyOption("nati|" .. i, function(t)
                        if t.success then
                            --if (MapManager.Instance) MapManager.Instance.ShowCountryMap();
                            Win.ExitAllWin( function(w)
                                return true
                            end )
                        end
                    end )
                end
            end
        end )
    end
end

function _w.Help()
    Win.Open("PopRule", DB_Rule.CountryJoin)
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        --package.loaded["Game.PopSelectCountry"] = nil
    end
end

---<summary>
---移名
---</summary>
PopSelectCountry = _w