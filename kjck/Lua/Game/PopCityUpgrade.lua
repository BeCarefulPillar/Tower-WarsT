local _w = { }

local _body = nil
local _ref = nil

local _data = nil
local _maxCost = 0

local _showCityUp = false
local _cityUpAtt = nil
local _lastAttShow = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })

    c:BindFunction(
    "OnInit",
    "OnDispose",
    "ClickSure",
    "OnUnLoad"
    )
end

local function InitPveCity()
print(kjson.print(_data))
    local db = _data.db
    _ref.title.text = db.nm
    local lv = _data.lv
    local toLevel = math.min(lv + 1, DB.maxCityLv)
    local crop = _data.crop

    local cityLv = _ref.infoLevel:ChildWidget("city_lv")
    local nextCityLv = _ref.infoLevel:ChildWidget("city_nextLv")
    local cityCrop = _ref.infoCrop:ChildWidget("city_crop")
    local nextCityCrop = _ref.infoCrop:ChildWidget("city_nextCrop")
    local maxSilver = _ref.infoMaxSilver:ChildWidget("maxSilver")
    local nextMaxSilver = _ref.infoMaxSilver:ChildWidget("nextLv_maxSilver")


    cityLv.text = tostring(lv)
    cityCrop.text = tostring(_data.crop)
    maxSilver.text = tostring(_data.crop * 48)
    print(kjson.print(_data))

    if toLevel > lv then
        _maxCost = math.max(0, _data.upCost)
        crop = PY_City.CalcCrop(_data.sn, toLevel)
        nextCityLv.text = tostring(toLevel)
        nextCityCrop.text = tostring(crop)
        nextMaxSilver.text = tostring(crop * 48)
        _ref.cost.text = L("花费银币") .. _maxCost
        _ref.tip:SetActive(true)
    else
        _maxCost = -1
        nextCityLv.text = L("已达最高等级")
        nextCityCrop.text = L("已达上限")
        nextMaxSilver.text = L("已达上限")
        _ref.cost.text = ""
        _ref.tip:SetActive(false)
    end

    _ref.btnSure:GetCmp(typeof(UIButton)).isEnabled = toLevel > lv
    local l = lv
    local img = db.main == 3 and db.img + 100 or db.img
    local idx = 0
    while l > 0 do
        idx = idx + 1
        local spname = "city_" .. img .. "_" .. l
        l = l - 1
        if _ref.city.atlas:GetSprite(spname) ~= nil then
            _ref.city.spriteName = spname
            break
        end
    end
    _ref.city:MakePixelPerfect()
end

function _w.OnInit()
    _ref.lables[1].text = L("城池开发")
    _ref.lables[2].text = L("开 发")

    if type(_w.initObj) == "number" then
        _data = user.GetPveCity(_w.initObj)
        if _data then
            InitPveCity()
        else
            Destroy(_body)
        end
    elseif objt(_w.initObj) == PY_PvpCity then
        _data = _w.initObj
        if _data then
            InitPveCity()
        else
            Destroy(_body)
        end
    end
end

local function ShowCityAtt(att)
    if att == nil or _showCityUp then return end
    _showCityUp = true
    local len = #att
    for k = 1, len do
        local str = att[1]
        if not str then
            coroutine.wait(0.5)
        else
            local lab = _body:AddWidget(typeof(UILabel), "attrib")
            Destroy(lab.gameObject, 2.5)
            lab.trueTypeFont = AM.mainFont
            lab.overflowMethod = UILabel.Overflow.ResizeFreely
            lab.fontSize = 32
            lab.width = 128
            lab.height = 32
            lab.depth = 200
            lab.effectStyle = UILabel.Effect.Outline
            lab.effectDistance = Vector2(0.5, 0.5)
            lab.applyGradient = false
            lab.color = Color.green
            lab.text = str

            if _lastAttShow then
                EF.bdMinDis(lab.cachedGameObject, 32)
            end
            _lastAttShow = lab


            lab.cachedTransform.localPosition = Vector3(0, 0, 0)

            EF.ColorFrom(lab.gameObject, "color", Color.white, "time", 0.3, "easetype", iTween.EaseType.easeInQuad)
            EF.MoveFrom(lab.gameObject, "y", -90, "time", 0.4, "islocal", true, "easetype", iTween.EaseType.easeOutExpo)
            EF.ScaleFrom(lab.gameObject, "scale", Vector3.one * 1.4, "time", 0.3, "easetype", iTween.EaseType.easeOutQuad)
            coroutine.wait(0.25)
            TweenAlpha.Begin(lab.gameObject, 0.5, 0).delay = 1
        end
        if att and #att > 0 then
            table.remove(att, 1)
        end
    end
    _showCityUp = false
end

local function OnUpgrade(lv)
    local go = _body:AddChild(AM.LoadPrefab("ef_city_up"), "ef_city_up", false)
    go:SetActive(false)
    coroutine.step()
    coroutine.step()
    go:SetActive(true)
    Destroy(go, 1.2)
    if _data then
        InitPveCity()
        _cityUpAtt = { }
        table.insert(_cityUpAtt, L("城池等级+1"))
        table.insert(_cityUpAtt, L("银币产出+") ..(PY_City.CalcCrop(_data.sn, _data.lv) - PY_City.CalcCrop(_data.sn, _data.lv - 1)))
        table.insert(_cityUpAtt, L("搜索装备概率提升"))
        table.insert(_cityUpAtt, "")
        coroutine.start(ShowCityAtt, _cityUpAtt)
       local home = Win.GetOpenWin("PopHome")
       if home then
           home.RefreshCityInfo()
       end
    end
end

function _w.ClickSure()
    if _maxCost < 0 then
        ToolTip.ShowPopTip(L("已开发到最高等级!"))
    else
        if _data == nil then
            local nl = user.Home.lsn
            if user.hlv < nl then
                ToolTip.ShowPropTip(ColorStyle.Bad(string.format("需要通关 第%s章",(nl - 1)) .. " " .. DB.GetGmLv(nl - 1).nm))
            else
                local curLv = user.hlv
                local siler = user.coin
                SVR.HomeUpgrade( function(re)
                    if re.success then
                        local res = SVR.datCache
                        if res.lv > curLv then
                            coroutine.start(OnUpgrade(res.lv))
                        end
                    end
                end )
            end
        elseif _data.sn > 0 then
            local curLv = _data.lv
            SVR.CityUpgrade(_data.sn, function(re)
                if re.success then
                    local res = SVR.datCache
                    _data:SetLv(res.lv)
                    --if (MapManager.Instance) MapManager.Instance.RefreshLevelMapCity();
                    if res.lv > curLv then
                        coroutine.start(OnUpgrade, res.lv)
                    end
                end
            end )
        end
    end
end

function _w.OnDispose()
    _data = nil
    _showCityUp = false
    _cityUpAtt = nil
    _ref.btnSure:GetCmp(typeof(UIButton)).isEnabled = true
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        --package.loaded["Game.PopCityUpgrade"] = nil
    end
end

--[Comment]
--城池升级
PopCityUpgrade = _w