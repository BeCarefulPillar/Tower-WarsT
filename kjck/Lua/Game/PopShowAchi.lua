local notnull = notnull

local _w = { }

local _body = nil
local _ref = nil

---<summary>当前页面。1=头像 2=称号</summary>
local _view = nil

---<summary>抽象数据。头像DB_Avatar，称号DB_HTitle</summary>
local _dat = nil

---<summary>当前选中（打勾勾）的头像</summary>
local _selectedAva = nil

local _musicval = nil
local _soundval = nil

function _w.OnLoad(c)
    _body = c
    _ref = c.nsrf.ref
    WinBackground(c, { k = WinBackground.MASK })
    _view = 0
    _musicval = 0
    _soundval = 0
    for i, btn in ipairs(_ref.btnTabs) do
        btn.param = i
    end
    _ref.proMusic.onChange:Add(EventDelegate(_w.OnMusicChange))
    _ref.proSound.onChange:Add(EventDelegate(_w.OnSoundChange))
    _ref.togMusic.onChange:Add(EventDelegate(_w.OnMusicToggleChange))
    _ref.togSound.onChange:Add(EventDelegate(_w.OnSoundToggleChange))
    --[[
#if !UNITY_EDITOR && SDK_CENTER
        btnLogout.GetComponentInAllChild<UILabel>(false).text = "用户中心";
#endif
]]
end

local function BuildItems()
    if _dat then
        _ref.grid:Reset()
        _ref.grid.realCount = #_dat
    end
end

--[Comment]
--获取数据后刷新页面
local function PriRefresh(v)
    if v == 1 then
        --头像页面
        if user.avaLst and table.len(user.avaLst)>0 then
            _dat = { }
            local cur = nil
            local ava = nil
            for i, v in pairs(user.avaLst) do
                --for i,v in ipairs({true,true,true,true,true,true,true,true,true,true,true,true}) do
                ava = DB.GetAvatar(i)
                if ava.sn == user.ava then
                    cur = ava
                else
                    table.insert(_dat, ava)
                end
            end
            table.insert(_dat, cur)
            _ref.viewsAni[2]:SetActive(false)
            _ref.viewsAni[3]:SetActive(false)
            _ref.viewsAni[1]:SetActive(true)
            _ref.viewsAni[1]:ResetToBeginning()
            _ref.viewsAni[1]:PlayForward()
            BuildItems()
            _ref.btnChange.text = L("更 换")
            _ref.btnChange.isEnabled = _selectedAva ~= nil
            _ref.btnChange:SetActive(true)
        else
            _body:Exit()
        end
        _ref.btnChange.transform.localPosition = Vector3(317, -271, 0)
    elseif v == 2 then
        --称号页面
    elseif v == 3 then
        _ref.viewsAni[1]:SetActive(false)
        _ref.viewsAni[2]:SetActive(false)
        _ref.viewsAni[3]:SetActive(true)
        _ref.btnChange:SetActive(false)

        _musicval = BGM.volume
        _soundval = BGM.soeVolume
        _ref.proMusic.value = _musicval
        _ref.proSound.value = _soundval

        _ref.togMusic.value = _musicval ~= 0
        _ref.spMusicF.widget.color = _musicval ~= 0 and Color.gray or Color.white
        _ref.togSound.value = _soundval ~= 0
        _ref.spSoundF.widget.color = _soundval ~= 0 and Color.gray or Color.white

        _ref.musicValue.text = math.toint(_ref.proMusic.value * 100)
        _ref.soundValue.text = math.toint(_ref.proSound.value * 100)

        _ref.avatar:LoadTexAsync(ResName.PlayerIcon(user.ava))
        _ref.nickname.text = user.nick
        _ref.lv.text = tostring(user.hlv)
        _ref.vipLv.text = L("Vip等级：") .. user.vip
        _ref.heroCount.text = tostring(#user.GetHeros())
    end
end

--[Comment]
--切换页面。1=头像 2=称号 3=设置。可同一页面刷新 
local function ChangeView(v)
    _selectedAva = nil

    --并非同一页面刷新，更新tab状态
    if v ~= _view then
        if _view > 0 then
            _ref.btnTabs[_view].widget.spriteName = "tab_normal"
        end
        _view = v
        _ref.btnTabs[_view].widget.spriteName = "btn_change"
    end

    if not _ref.btnChange.activeSelf then
        _ref.btnChange:SetActive(true)
    end

    if _view == 1 then
        --头像页面
        if #user.avaLst < 1 then
            SVR.SyncValue("ava", function(t)
                if t.success then
                    PriRefresh(_view)
                end
            end )
        else
            PriRefresh(_view)
        end
    elseif _view == 2 then
        --称号页面
    elseif _view == 3 then
        --设置界面
        PriRefresh(_view)
    end
end

function _w.OnInit()
    --默认打开头像页面
    local v = 1
    _ref.btnTabs[v + 1].widget.spriteName = "tab_normal"
    _ref.btnTabs[v + 2].widget.spriteName = "tab_normal"
    if type(_w.initObj) == "number" then
        v = _w.initObj
    end
    ChangeView(v)
end

function _w.Help()
    Win.Open("PopRule", DB_Rule.AvaTitle)
end

--[Comment]
--点击标签，切换页面
function _w.ClickTab(i)
    BGM.PlaySOE("sound_click_btn")
    if _view == i then
        return
    end
    ChangeView(i)
end

function _w.OnWrapGridInitItem(item, i)
    if i < 0 or i >= #_dat then
        return false
    end

    local d = _dat[i + 1]

    local ig = ItemGoods(item)
    ig:Init(d, d.sn == user.ava)
    ig.go.transform.localScale = Vector3(1.4, 1.4, 1.4)
    ig.go.luaBtn.luaContainer = _body
    ig.MeltSelected = _selectedAva == ig

    return true
end

function _w.ClickHelp()
    Win.Open("PopLuaHelp")
end

--[Comment]
--点击更换
function _w.ClickChange()
    if _view == 1 then
        --更换头像
        local d = _selectedAva.dat
        SVR.ChangeUserInfo("ava|" .. d.sn, function(t)
            if t.success then
                _selectedAva = nil
                ChangeView(_view)
                --更新主城显示头像
                if MainUI then
                    MainUI.UpdateUserInfo()
                end
            end
        end )
    elseif _view == 2 then
        --更换称号
    elseif _view == 3 then
        --设置界面
        _ref.btnChange:SetActive(false)
    end
end

function _w.ClickItemGoods(btn)
    local ig = btn and Item.Get(btn.gameObject)
    if ig.dat.sn ~= user.ava then
        if _selectedAva then
            _selectedAva.MeltSelected = false
        end
        if _selectedAva ~= ig then
            _selectedAva = ig
            _selectedAva.MeltSelected = true
        else
            _selectedAva = nil
        end
    end
    _ref.btnChange.isEnabled = _selectedAva ~= nil
end

function _w.ClickExcode()
    MsgBox.Show(L("请输入兑换码"), "取消,确定", "", L("{b24}兑换码"),
    function(bid, ipt)
        if bid == 1 and #ipt[0] > 0 then
            SVR.UseExCode(ipt[0], function(t)
            end )
        end
    end )
end

function _w.OnMusicChange()
    if notnull(UIProgressBar.current) then
        BGM.volume = _ref.proMusic.value
        _ref.musicValue.text = math.modf(_ref.proMusic.value * 100)
        local f = _ref.proMusic.value ~= 0
        _ref.togMusic.value = f
        _ref.spMusicF.widget.color = f and Color.white or Color.gray
    end
end

function _w.OnSoundChange()
    if notnull(UIProgressBar.current) then
        BGM.soeVolume = _ref.proSound.value
        _ref.soundValue.text = math.modf(_ref.proSound.value * 100)
        local f = _ref.proSound.value ~= 0
        _ref.togSound.value = f
        _ref.spSoundF.widget.color = f and Color.white or Color.gray
    end
end

function _w.OnMusicToggleChange()
    if _ref.togMusic.value then
        BGM.volume = _musicval
        _ref.proMusic.value = _musicval
    else
        _musicval = _ref.proMusic.value
        BGM.soeVolume = 0
        _ref.proMusic.value = 0
    end
    _ref.musicValue.text = math.modf(_ref.proMusic.value * 100)
end

function _w.OnSoundToggleChange()
    if _ref.togSound.value then
        BGM.volume = _soundval
        _ref.proSound.value = _soundval
    else
        _soundval = _ref.proSound.value
        BGM.volume = 0
        _ref.proSound.value = 0
    end
    _ref.soundValue.text = math.modf(_ref.proSound.value * 100)
end

function _w.ClickLogout()
    SVR.LogOut()
end

function _w.OnDispose()
    if _view > 0 then
        _ref.btnTabs[_view].widget.spriteName = "tab_normal"
    end
    _view = 0
    _dat = nil
end

function _w.OnUnLoad(c)
    if _body == c then
        _body = nil
        _ref = nil
        _view = nil
        _dat = nil
        _selectedAva = nil
        _musicval = nil
        _soundval = nil
    end
end

---<summary>设置</summary>
PopShowAchi = _w