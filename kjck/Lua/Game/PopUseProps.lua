local _w = { }

local _ref

local _body
local _slider
local _lblQty
local _btnSure
local _img
local _labName
local _labIntro

local _callback
local _dat
local _datTyp
local _trg
local _msg
local _qty = 1

local _sliderWidth = 1
local _dragValue = 0

local QTY_LMT = 5

function _w.OnLoad(c)
    WinBackground(c,{k = WinBackground.MASK })
    _body = c
    _ref = _body.nsrf.ref
    table.print("_ref", _ref)

    c:BindFunction("OnUnLoad", "OnInit", "OnDispose", "OnExit", "OnDragChange",
    "ClickSure", "ClickAdd", "ClickReduce", "OnPress", "OnDrag")

    _slider = _ref.countPro
    _lblQty = _ref.countLab
    _btnSure = c:Child("btn_sure")
    _img = _ref.img
    _labName = _ref.labName
    _labIntro = _ref.labIntro

    _sliderWidth = _slider.foregroundWidget.width
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _slider, _lblQty, _btnSure = nil, nil, nil
    end
end

local function MaxCount()
    if _datTyp == PY_Props then return _dat.bat > 0 and math.min(_dat.bat, _dat.qty) or _dat.qty end
    if _datTyp == PY_DequipSp then return math.floor(_dat.qty / DB.GetDequipSpUpCnt(_dat.rare)) end --为可合成的最大数量，不是当前残片数量
    return _dat and _dat.qty or 0
end

local function Refresh()
    local max = MaxCount()
    _qty = Mathf.Clamp(_qty, 1, max)
    _slider.value = _qty / max
    if _datTyp == PY_Props then
        _lblQty.text = _dat.qty > max and _qty .. "/" .. max .. "(" .. _dat.qty .. ")" or _qty .. "/" .. max
    else
        _lblQty.text = _qty .. "/" .. max
    end
end
_w.Refresh = Refresh

function _w.OnInit()
    assert(_dat and (_datTyp == PY_Props or _datTyp == PY_DequipSp or _datTyp == PY_Sexcl), "PopUseProps dat must be PY_Props, PY_DequipSp, PY_Sexcl")
    _labName.text = _dat.nm
    _labIntro.text = _dat.i
    _img:LoadTexAsync(ResName.PropsIcon(_dat.img))
    Refresh()
end

function _w.OnDispose()
    _qty = 1
--    _dat = nil
--    _dattyp, _trg, _msg = nil, nil, nil
--    _callback = nil
end

--function _w.OnEnter()
--    local pos = _body.cachedTransform.parent.worldToLocalMatrix:MultiplyPoint3x4(UICamera.lastWorldPosition) - _btnSure.localPosition
--    local tmp = _body.bounds.size
--    tmp.x = (SCREEN.WIDTH - tmp.x) * 0.5
--    tmp.y = (SCREEN.HEIGHT - tmp.y) * 0.5
--    pos.x = Mathf.Clamp(pos.x, -tmp.x, tmp.x)
--    pos.y = Mathf.Clamp(pos.y, -tmp.y, tmp.y)
--    _body.cachedTransform.localPosition = pos
--end

function _w.OnExit()
    _datTyp, _trg, _msg = nil, nil, nil
    _callback = nil
end

function _w.OnDragChange()
    _qty = Mathf.Round(_slider.value * MaxCount());
    Refresh()
end

local function OnUseResult(t)
    if t.success then
        BGM.PlaySOE("sound_cost_prop")
        if SVR.datCache.usedQty < _qty then
            MsgBox.Show(string.format(L("主公，本次使用了%s"), ColorStyle.Blue(_dat:getName()) .. NameStyle.QtyTag(SVR.datCache.usedQty)))
        end
        if _dat.qty > 0 then
            Refresh()
        else
            if _callback then _callback(t) else PopRewardShow.Show(SVR.datCache.rws) end
            _body:Exit()
            return
        end
        if _callback == nil then PopRewardShow.Show(SVR.datCache.rws) end
    end
    if _callback then _callback(t) end
end

local function Close()
    _body:Exit()
end

function _w.ClickSure()
    if _dat == nil or _datTyp == nil then
        _body:Exit()
        return
    end
    if _trg then
        local db = _dat.db
        if _datTyp == PY_Props then
            if db.trg == 2 then
                --对武将
                SVR.UseProps(db.sn, _qty, _trg, OnUseResult)
            elseif db.trg == 3 then
                --对玩家赠送
                SVR.UsePropsForPnm(db.sn, _trg, _qty, msg, OnUseResult)
            elseif db.trg == 4 then
                --对PVP城池
                SVR.UsePropsForPvp(db.sn, _qty, _trg, msg, OnUseResult)
            elseif db.trg == 6 then
                --对副将
                SVR.UsePropsForDehero(db.sn, _qty, _trg, OnUseResult)
            else
                --对自身
                SVR.UseProps(db.sn, _qty, 0, OnUseResult)
            end
        elseif _datTyp == PY_DequipSp then
            --军备残片
            SVR.DequipSpOption("up|"..PY_DequipSp.GetSnFromDbAndRare(_dat.dbsn, _dat.rare).."|".._qty, function(t)
                if t.success then
                    _qty = Mathf.Round(_slider.value * MaxCount())
                    Refresh()
                    if _callback then _callback(t) end
                end
            end)
        elseif _datTyp == PY_Sexcl then
            --天机专属
            SVR.ItemSell("csx|"..db.sn.."|".._qty, function(t)
                if t.success then
                    _qty = Mathf.Round(_slider.value * MaxCount())
                    Refresh()
                    if _callback then _callback(t) end
                end
            end)
        else
            _body:Exit()
        end
    else
        --无目标时为选择
        if _callback then _callback(_qty) end
        _body:Exit()
    end

    Invoke(Close, 0.2, true)
end

function _w.ClickAdd()
    _qty = _qty + 1
    Refresh()
end

function _w.ClickReduce()
    _qty = _qty - 1
    Refresh()
end

function _w.OnPress(press)
    _dragValue = _slider.value
end

function _w.OnDrag(delta)
    _dragValue = Mathf.Clamp01(_dragValue + delta.x / _sliderWidth)
    _slider.value = _dragValue
end
--[Comment]
--使用道具通用窗口，请使用 PopUseProps.Use()
PopUseProps = _w

local function DefaultReturn(t)
    if t.success then
        BGM.PlaySOE("sound_cost_prop")
        PopRewardShow.Show(SVR.datCache.rws)
    end
end
--[Comment]
--使用物品
--dat : 可为 PY_Props, PY_DequipSp, PY_Sexcl
--trg : 可为 PY_Hero, PY_Dehero, PY_PvpCity, 或相应的sn, psn, pnm, nil(表示选择)
--callback : 回调，当target为nil时，回调参数为选择的数量，否则为执行的NetTask
--msg : 赠送等的消息，可为nil
--isHeroInfoUse:武将界面用道具特殊处理
function _w.Use(dat, trg, callback, msg, isHeroInfoUse)
    if isHeroInfoUse == nil then
        isHeroInfoUse = false   
    end
    local typ = objt(dat)
    assert(typ == PY_Props or typ == PY_DequipSp or typ == PY_Sexcl, "Use dat must be PY_Props, PY_DequipSp, PY_Sexcl")
    if typ == PY_Props then
        local db = dat.db
        if db.sn == DB_Props.GAI_MING then
            --改名卡特殊处理
            if user.GetPropsQty(DB_Props.GAI_MING) > 0 then
                MsgBox.Show(L("修改名称"), L("取消")..","..L("确定"), nil, "{b16}"..L("新名称"), function(bid, ipt)
                    if bid == 1 then
                        ipt = ipt[0]
                        if ipt == nil or ipt == "" or ipt == user.nick then
                            ToolTip.ShowPopTip(ColorStyle.Warning(L("请输入新的名称！")))
                        elseif DB.HX_Check(ipt) then
                            ToolTip.ShowPopTip(ColorStyle.Warning(L("输入的名称含有非法字符！")))
                        elseif MsgBox.InputHasInvisibleChar(0) then
                            ToolTip.ShowPopTip(ColorStyle.Warning(L("输入的名称含有空白字符！")))
                        else
                            SVR.ChangeUserInfo("nm|"..ipt, function(t)
                                if t.success then ToolTip.ShowPopTip(ColorStyle.Warning(L("名称修改成功！"))) end
                                MsgBox.Exit()
                            end)
                        end
                    else
                        MsgBox.Exit()
                    end
                end, true)
            end
            return
        end

        --检测目标对象
        if db.trg == 2 or db.trg == 4 or db.trg == 6 then
            if trg then
                trg = type(trg) == "table" and trg.sn or trg
                assert(db.trg ~= 4 and trg or PY_PvpCity.IsPvpCity(trg), "use props ["..db.nm.."] target error")
            end
        end

        if trg == nil and callback then
            --无目标时为选择
        elseif db.bat == 1 or dat.qty < QTY_LMT or user.gmMaxCity < CONFIG.T_LEVEL or isHeroInfoUse then
--            if trg == nil then
--                --无目标时为选择
--                if callback then callback(1) end
--                return 
--            end
            --直接使用
            if db.trg == 2 then
                --对武将
                if callback then
                    SVR.UseProps(db.sn, 1, trg, function(t) 
                        callback(t)
                        if t.success then BGM.PlaySOE("sound_cost_prop") end
                    end)
                else
                    SVR.UseProps(db.sn, 1, trg, DefaultReturn)
                end 
            elseif db.trg == 3 then
                --对玩家赠送
                if callback then
                    SVR.UsePropsForPnm(db.sn, trg, 1, msg, function(t) 
                        callback(t)
                        if t.success then BGM.PlaySOE("sound_cost_prop") end
                    end)
                else
                    SVR.UsePropsForPnm(db.sn, trg, 1, msg, DefaultReturn)
                end
            elseif db.trg == 4 then
                --对PVP城池
                if callback then
                    SVR.UsePropsForPvp(db.sn, 1, trg, msg, function(t) 
                        callback(t)
                        if t.success then BGM.PlaySOE("sound_cost_prop") end
                    end)
                else
                    SVR.UsePropsForPvp(db.sn, 1, trg, msg, DefaultReturn)
                end
            elseif db.trg == 6 then
                --对副将
                if callback then
                    SVR.UsePropsForDehero(db.sn, 1, trg, function(t) 
                        callback(t)
                        if t.success then BGM.PlaySOE("sound_cost_prop") end
                    end)
                else
                    SVR.UsePropsForDehero(db.sn, 1, trg, DefaultReturn)
                end
            else
                --对自身
                if callback then
                    SVR.UseProps(db.sn, 1, 0, function(t) 
                        callback(t)
                        if t.success then BGM.PlaySOE("sound_cost_prop") end
                    end)
                else
                    SVR.UseProps(db.sn, 1, 0, DefaultReturn)
                end
            end
            return
        end
    end

    --启用批量
    _dat, _datTyp = dat, typ
    _callback = callback
     _trg = trg
    _msg = msg
    print(kjson.print(_dat))
    Win.Open("PopUseProps", _dat)
end