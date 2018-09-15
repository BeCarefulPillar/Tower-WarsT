

local fpd = { }
FightPlotDialogue = fpd

local _body = nil

local _lRole = nil
local _rRole = nil
local _labL = nil
local _labR = nil
local _lWord = nil
local _rWord = nil

local _isShow = nil
local _cnt = nil
local _wait = nil

local function OnInit(ldat, rdat)
    _isShow = false
    _cnt = 0
    if ldat.sn > 0 and rdat.sn > 0 then
        _lRole:LoadTexAsync(ResName.HeroImage(ldat.img))
        _rRole:LoadTexAsync(ResName.HeroImage(rdat.img))
        _labL.text = ldat.nm
        _labR.text = rdat.nm
        _lRole.alpha = 0
        _rRole.alpha = 0
    end
end

function fpd.OnLoad(c)
    _body = c

    c:BindFunction("OnUnLoad", "ClickPanel")

    local tmp = c.nsrf.ref
    _lRole, _rRole, _labL, _labR, _lWord, _rWord = tmp.leftrole, tmp.rightrole, tmp.leftname, tmp.rightname, tmp.leftword, tmp.rightword
    c.gameObject:SetActive(false)
end
--[Comment]
-- [lsn,rsn : number]
function fpd.InitBySN(lsn, rsn)
    OnInit(DB.GetHero(lsn), DB.GetHero(rsn))
end
--[Comment]
-- [ldat,rdat : DB_Hero]
fpd.Init = OnInit

function fpd.OnShow(ws)
    if ws == nil or #ws <= 0 then
        ws = DB.AllDlg(Dialogue.dlg_type.fight)
        if ws and #ws > 0 then
            local idx = math.floor(math.random(1, #ws + 0.999))
            ws = string.split(ws[idx], "|")
            if ws == nil or #ws < 1 then ws = nil end
        else ws = nil
        end
    end
    if ws ~= nil and #ws > 0 then
        _cnt = _cnt + 1
        while _isShow do coroutine.step() end

        _isShow = true
        _body.gameObject:SetActive(true)
        _body:GetCmp(typeof(TweenAlpha)):Play(true)

        local flag = Mathf.Random(0, 100) < 50
        local tm = 0
        local wd = nil
        for i = 1, #ws do
            wd = ws[i]
            if isTable(wd) then
                if wd[L] ~= nil then
                    flag = true
                    wd = wd[L]
                elseif ws[R] ~= nil then
                    flag = false
                    wd = wd[R]
                end
            end

            if flag then
                _lRole:GetCmp(typeof(TweenAlpha)):Play(true)
                _lRole:GetCmp(typeof(TweenPosition)):Play(true)
                _rRole:GetCmp(typeof(TweenAlpha)):Play(false)
                _rRole:GetCmp(typeof(TweenPosition)):Play(false)
                _lWord:TypeText(wd)
                _rWord:TypeText("")
            else
                _lRole:GetCmp(typeof(TweenAlpha)):Play(false)
                _lRole:GetCmp(typeof(TweenPosition)):Play(false)
                _rRole:GetCmp(typeof(TweenAlpha)):Play(true)
                _rRole:GetCmp(typeof(TweenPosition)):Play(true)
                _lWord:TypeText("")
                _rWord:TypeText(wd)
            end

            flag = not flag
            tm = Time.unscaledTime + 0.3
            while tm > Time.unscaledTime do coroutine.step() end
            _wait = true
            tm = Time.unscaledTime + (string.len(wd) / _lWord.charsPerSecond) + 0.5
            while tm > Time.unscaledTime and _wait do coroutine.step() end
        end
        _lRole:GetCmp(typeof(TweenAlpha)):Play(false)
        _lRole:GetCmp(typeof(TweenPosition)):Play(false)
        _rRole:GetCmp(typeof(TweenAlpha)):Play(false)
        _rRole:GetCmp(typeof(TweenPosition)):Play(false)

        tm = Time.unscaledTime + 0.2
        while tm > Time.unscaledTime do coroutine.step() end
        _body:GetCmp(typeof(TweenAlpha)):Play(false)
        tm = Time.unscaledTime + 0.2
        while tm > Time.unscaledTime do coroutine.step() end
        _isShow = false
        _cnt = Mathf.Max(_cnt - 1, 0)
    end
    if _cnt <= 0 then _body.gameObject:SetActive(false) end
end

function fpd.Dispose()
    _isShow = nil
    _cnt = nil
    _wait = nil
    _lRole:UnLoadTex()
    _rRole:UnLoadTex()
    _body.gameObject:SetActive(false)
end

function fpd.OnUnLoad()
    _body = nil
    _lRole = nil
    _rRole = nil
    _labL = nil
    _labR = nil
    _lWord = nil
    _rWord = nil
end

function fpd.ClickPanel() _wait = false end
