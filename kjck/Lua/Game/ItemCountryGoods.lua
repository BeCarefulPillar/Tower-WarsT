local _item = { }

function _item.Init(ref, dat)
    local info = RW(dat.rw)
    ref.frame.spriteName = info.frame
    ref.infos[1].text = info.nm
    ref.infos[4].text = info.qty
    ItemGoods.SetEquipEvo(ref.icon.cachedGameObject, info.evo, info.rare)

    local piece = ref.icon:Child("piece")
    local isPiece = RW.IsPiece(dat.rw)
    if piece then
        piece:SetActive(isPiece)
    elseif isPiece then
        piece = ref.icon:AddWidget(typeof(UISprite), "piece")
        piece.atlas = AM.mainAtlas
        piece.spriteName = "sp_piece"
        piece.width = 80
        piece.height = 80
        piece.depth = 6
    end

    ref.icon:LoadTexAsync(RW.IcoName(dat.rw))
    ref.icon.color = Color.white
    ref.frame.color = Color.white
    ref.priceIcon.color = Color.white
    for i = 1, 5 do
        ref.infos[i].color = Color.white
    end
    if info.dat then
        ref.icon.luaBtn:SetClick( function(rw)
            RW.ShowPropTip(rw)
        end , dat.rw)
    end
    if dat.rmb > 0 then
        ref.priceIcon.spriteName = "sp_diamond"
        ref.infos[2].text = tostring(dat.rmb)
    elseif dat.token > 0 then
        ref.priceIcon.spriteName = "sp_token"
        ref.infos[2].text = tostring(dat.token)
    else
        ref.priceIcon.spriteName = "sp_gold"
        ref.infos[2].text = tostring(dat.gold)
    end
end

ItemCountryGoods = _item