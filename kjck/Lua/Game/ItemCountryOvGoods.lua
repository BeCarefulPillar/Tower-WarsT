local _item = { }

local ts = {
    [1] = L("高概率"),
    [2] = L("一般概率"),
    [3] = L("低概率"),
    [4] = L("极低概率"),
    [5] = L("极微概率"),
    def = L("未知概率"),
}

function _item.Init(ref, data)
    local info = RW(data.rw)
    ref.frame.spriteName = info.frame
    ref.infos[1].text = info.nm

    ItemGoods.SetEquipEvo(ref.icon.cachedGameObject, info.evo, info.rare)

    local piece = ref.icon:Child("piece")
    local isPiece = RW.IsPiece(data.rw)
    if piece then
        piece:SetActive(isPiece)
    elseif isPiece then
        piece = ref.icon:AddWidget(typeof(UISprite), "piece")
        piece.atlas = AM.mainAtlas
        piece.spriteName = "sp_piece"
        piece.width = 106
        piece.height = 106
        piece.depth = 6
    end

    ref.icon:LoadTexAsync(RW.IcoName(data.rw))
    if info.dat then
        ref.icon.luaBtn:SetClick( function(rw)
            RW.ShowPropTip(rw)
        end , data.rw)
    end

    if data.qty == 0 then
        ref.infos[2].text = L("剩余:已售罄")
        ref.infos[2].color = Color.red
    else
        ref.infos[2].text = L("剩余:") ..(data.qty > 0 and tostring(data.qty) or L("无限量"))
        ref.infos[2].color = Color.white
    end

    ref.infos[3].text = ts[data.rare] or ts.def

    ref.infos[3].color = ColorStyle.GetRareColor(data.rare + 1)
    ref.infos[4].text = data.nLv .. L("级国家开放")
    ref.infos[4].color = user.nat.lv < data.nLv and Color.red or Color.white
    if data.gold > 0 then
        ref.spPrice.spriteName = "sp_gold"
        ref.spPrice:ChildWidget("lab_proce").text = tostring(data.gold)
    elseif data.rmb > 0 then
        ref.spPrice.spriteName = "sp_diamon"
        ref.spPrice:ChildWidget("lab_proce").text = tostring(data.rmb)
    elseif data.token > 0 then
        ref.spPrice.spriteName = "sp_token"
        ref.spPrice:ChildWidget("lab_proce").text = tostring(data.token)
    end
end

ItemCountryOvGoods = _item