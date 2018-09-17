local _w = { }

local _body = nil
local _ui = nil

function _w.OnLoad(c)
    _body = c
    print(typeof(SerializeRef))
    _ui = c:GetComponent(typeof(SerializeRef)).ref
    
    local count = 20

    for i=1,count do
        local go = Instantiate(_ui.item)
        go.name = string.format("item_%03d",i)
        go.transform:SetParent(_ui.grid)
        go.transform.localScale = Vector3.one
        go.transform.localPosition = Vector3.zero
        go.transform:Find("Text"):GetComponent("Text").text = tostring(i)
        go:GetComponent(typeof(LuaButton)).luaContainer = _body
        go:GetComponent(typeof(LuaButton)).param = {1,2,3}
    end

    _ui.open.luaContainer = _body

    print(_w.initObj.str)
    print(PanelNames)
end

function _w.OnClick(btn,pos,p)
    print(tostring(btn))
    print(tostring(pos))
    print(tts(p))
end

function _w.OnClickOpen()
    Win.Open("Message")
end

function _w.OnUnLoad(c)
    if _body==c then
        print("OnUnLoad")
        _body=nil
        _ui=nil
    end
end

Prompt = _w