local _w = { }

function _w.OnLoad(go)
    local item = UnityEngine.Resources.Load("Prefabs/PromptItem", typeof(UnityEngine.GameObject))
    local grid = go.transform:Find("ScrollView/Grid")
    local count = 20

    for i=1,count do
        local go = UnityEngine.Object.Instantiate(item)
        go.name = string.format("item_%03d",i)
        go.transform:SetParent(grid)
        go.transform.localScale = Vector3.one
        go.transform.localPosition = Vector3.zero
        go.transform:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text)).text = tostring(i)
    end

    print(_w.initObj.str)
    print(PanelNames)
end

Prompt = _w