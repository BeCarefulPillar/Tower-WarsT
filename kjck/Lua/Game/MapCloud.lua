


MapCloud = {}
MapCloud.isOpen = false
local rd = Mathf.Random

local _body = nil
MapCloud.body = _body
local _cure = nil
local _atlas = nil

local _areaW = 1662
local _areaH = 1087

local _showBird = nil
local _nextTime = 0
local _nextBridTime = 0
local _tran = nil

local _pos = Vector3(0, 0, 0)
local _time = os.time()
local _sp = nil
local _tmp1 = nil
local _tmp2 = nil
local _dire = nil
local _cnt = nil
local _birdS = nil
local _posList = { }
local _life = nil

local function OnCutMap(s, sb, dp)
    sb = sb or false
    dp = dp or 0
    local goc = _tran.gameObject
    local go = nil
    local clouds = { }
    local tmp = nil
    -- ´´½¨¶¯»­Ãæ°å
    go = Tools.CreatAnimPanel(SceneGame.body.gameObject, db,  true, 5)
    for i = 1, 5 do
        clouds[i] = go:AddWidget(typeof(UISprite), "cloud_"..i)
        clouds[i].atlas = _atlas:GetCmp(typeof(UIAtlas))
    end
    -- ÒÆ¶¯ 700 ÏñËØ
    -- ×ó±ßÁ½¿é
    tmp = clouds[1]
    tmp.spriteName = "cloud_5"
    tmp.width, tmp.height = 902, 426
    tmp.cachedTransform.localPosition = Vector3(-982, 59, 0)
    tmp = tmp.cachedGameObject:AddCmp(typeof(TweenPosition))
    tmp.animationCurve = _cure
    tmp.from, tmp.to = Vector3(-982, 59, 0), Vector3(931, 59, 0)
    tmp = clouds[2]
    tmp.spriteName = "cloud_2"
    tmp.width, tmp.height = 834, 346
    tmp.cachedTransform.localPosition = Vector3(-1159, -125, 0)
    tmp = tmp.cachedGameObject:AddCmp(typeof(TweenPosition))
    tmp.animationCurve = _cure
    tmp.from, tmp.to = Vector3(-1159, -125, 0), Vector3(754, -125, 0)
    -- ÓÒ±ßÈý¿é
    tmp = clouds[3]
    tmp.spriteName = "cloud_6"
    tmp.width, tmp.height = 928, 430
    tmp.cachedTransform.localPosition = Vector3(957, 72, 0)
    tmp = tmp.cachedGameObject:AddCmp(typeof(TweenPosition))
    tmp.animationCurve = _cure
    tmp.from, tmp.to = Vector3(957, 72, 0), Vector3(-956, 72, 0)

    tmp = clouds[4]
    tmp.spriteName = "cloud_4"
    tmp.width, tmp.height = 682, 376
    tmp.cachedTransform.localPosition = Vector3(929, -27, 0)
    tmp = tmp.cachedGameObject:AddCmp(typeof(TweenPosition))
    tmp.animationCurve = _cure
    tmp.from, tmp.to = Vector3(929, -27, 0), Vector3(-984, -27, 0)

    tmp = clouds[5]
    tmp.spriteName = "cloud_1"
    tmp.width, tmp.height = 716, 316
    tmp.cachedTransform.localPosition = Vector3(834, -160, 0)
    tmp = tmp.cachedGameObject:AddCmp(typeof(TweenPosition))
    tmp.animationCurve = _cure
    tmp.from, tmp.to = Vector3(834, -160, 0), Vector3(-1079, -160, 0)
    goc:GetCmp(typeof(UIPanel)).alpha = 1
    coroutine.wait(0.3)
    if s then
        coroutine.step()
        _showBird = sb
        if not sb then
            tmp = _tran:FindChild("bird")
            while tmp do
                Destroy(tmp.gameObject)
                tmp.parent = nil
                tmp = _tran:FindChild("bird")
            end
        end
        EF.Alpha(goc, 0.3, 1)
        coroutine.wait(0.1)
        go:GetCmp(typeof(UE.BoxCollider)).enabled = false
        coroutine.wait(0.6)
    else
        EF.Alpha(goc, 0.3, 1)
        coroutine.wait(0.1)
        go:GetCmp(typeof(UE.BoxCollider)).enabled = false
        coroutine.wait(0.2)
        goc:SetActive(false)
        coroutine.wait(0.4)
    end
    Destroy(go)
end

local function Update()
    if not _tran.gameObject.activeSelf then return end
    _tran.localPosition = _pos
    _time = os.time()
    if _time > _nextTime then
        math.randomseed(string.reverse(_time))
        _nextTime = _time + rd(5, 25)
        sp = _tran.gameObject:AddWidget(typeof(UISprite), "cloud")
        sp.atlas = _atlas:GetCmp(typeof(UIAtlas))
        sp.spriteName = "cloud_"..rd(1, 6)
        sp.depth = rd(0, 10)
        sp:MakePixelPerfect()
        _tmp1 = Vector3(-_areaW * 0.5 - sp.width * 0.5 , rd(-_areaH * 0.5, _areaH * 0.5), 0)
        sp.cachedTransform.localPosition = _tmp1
        _tmp2 = rd(30, 60)
        _tmp1.x = _tmp1.x + _areaW + sp.width
        EF.Move(sp.cachedGameObject, _tmp2, _tmp1)
        Destroy(sp.cachedGameObject, _tmp2)
        _sp = nil
        _tmp1 = nil
        _tmp2 = nil
    end
    if _showBird and _time > _nextBridTime then
        math.randomseed(string.reverse(os.time()))
        _nextBridTime = _time + rd(30, 60)
        _dire = rd(-1.1, 1.1) < 0
        _tmp1 = Vector2(400, 300)
        _tmp2 = Vector2(_dire and (-_areaW * 0.5 - _tmp1.x) or (_areaW * 0.5), rd(-_areaH * 0.5, _areaH * 0.5 - _tmp1.y))
        _cnt = rd(1, Mathf.Ceil(_tmp1.x * _tmp1.y / 10000.0))
        _birdS = Vector2(148, 170)
        _posList = { }
        for i = 25, _tmp1.x, 50 do
            for j = 25, _tmp1.y, 50 do table.insert(_posList, Vector2(_tmp2.x + i, _tmp2.y + j)) end
        end
        _life = rd(30, 60)
        for i = 1, _cnt do
            sp = _tran.gameObject:AddWidget(typeof(UISprite), "bird")
            sp.atlas = _atlas:GetCmp(typeof(UIAtlas))
            sp.spriteName = "bird_01"
            sp:MakePixelPerfect()
            _tmp2 = nil
            _tmp2 = rd(0.2, 0.4)
            sp.depth = (_tmp2 - 0.46) * 200
            sp.width = _birdS.x * _tmp2
            sp.height = _birdS.y * _tmp2
            _tmp2 = nil
            _tmp2 = rd(1, #_posList)
            _tmp1 = _posList[_tmp2]
            table.remove(_posList, _tmp2)
            
            sp.cachedTransform.localPosition = Vector3(_tmp1.x, _tmp1.y, 0)
            sp.cachedTransform.localEulerAngles = Vector3(0, _dire and 180 or 0, 0)
            _tmp1.x = (_dire and 0.5 or -0.5) * (_areaW + sp.width)
            _tmp2 = _life * rd(0.98, 1.02)
            EF.Move(sp.cachedGameObject, _tmp2, Vector3(_tmp1.x, _tmp1.y, 0))
            _tmp1 = sp.cachedGameObject:AddCmp(typeof(UISpriteAnimation))
            _tmp1.namePrefix = "bird_";
            _tmp1.framesPerSecond = rd(8, 13);
            _tmp1.pixelPerfect = false;
            _tmp1.PlayIndex = rd(0, _tmp1.frames);

            Destroy(sp.cachedGameObject, _tmp2)
        end
    end
end

local _update = nil

function MapCloud.OnLoad(c)
    _body = c
    _tran = _body.transform

    c:BindFunction("OnUnLoad", "OnEnter", "OnExit", "OnDispose")

    local tmp = c.srf.curves
    _cure = tmp[0]
    tmp = c.gos
    _atlas = tmp[0]
    _update = UpdateBeat:CreateListener(Update)
    UpdateBeat:AddListener(_update)
end

function MapCloud.OnEnter()
    _tran = _body.transform
    MapCloud.isOpen = true
end

function MapCloud.OnExit()
    MapCloud.isOpen = nil
end

function MapCloud.OnDispose()
    MapCloud.isOpen = false
    _showBird = nil
    _nextTime = 0
    _nextBridTime = 0
    _tran = nil
    _time = nil
    _sp = nil
    _tmp1 = nil
    _tmp2 = nil
    _dire = nil
    _cnt = nil
    _birdS = nil
    _posList = { }
    _life = nil
    if not _tran then _tran = _body.transform end
    _tran:DesAllChild()
end

function MapCloud.OnUnLoad()
    _body = nil
    _cure = nil
    _atlas = nil

    if _update ~= nil then UpdateBeat:RemoveListener(_update) end
end

function MapCloud.StartCutMap(s, sb, dp)
    coroutine.start(OnCutMap, s, sb, dp)
end


