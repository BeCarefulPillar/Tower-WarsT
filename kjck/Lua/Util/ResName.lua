
local _name = {
    --[Comment]
    --本地化文件
    Localization = "data_localization",
    --[Comment]
    --默认纹理
    DefaultTexture = "tex_default",
    --[Comment]
    --主纹理图集
    MainAtlas = "atlas_main",
    --[Comment]
    --默认字体
    DefaultFont = "font_default",
    --[Comment]
    --加载中动画纹理
    LoadingTexture = "tex_load_dot",
    --[Comment]
    --无项目图标
    NonItem = "p_n",
    --[Comment]
    --战场扩展
    TexBattle = "tex_battle",
    --[Comment]
    --登录特效和软著
    LoginEffect = "ef_login",

    --[Comment]
    --世界地图
    MainMap = "map_main",
    --[Comment]
    --国战地图
    MapNat = "map_nat",
    --[Comment]
    --主城地图节点数据
    NatAtlas = "atlas_nat",
    --[Comment]
    --主城地图节点数据
    MainCityData = "main_city_d",
}
--[Comment]
--类型和图标前缀的映射
local _typIcoPrefix = 
{
    [DB_Arm] = "so",
    [DB_Avatar] = "ava",
--    [DB_Beauty] = "b2",
    [DB_Buff] = "dh2",
--    [DB_Dehero] = "bb",
--    [DB_Dequip] = "de",
    [DB_Equip] = "e",
    [DB_Gem] = "g",
    [DB_Hero] = "h2",
    [DB_Lnp] = "lu",
    [DB_Props] = "p",
--    [DB_Sexcl] = "hs",
    [DB_SKC] = "skc",
--    [DB_SKD] = "skd",
    [DB_SKE] = "ske",
    [DB_SKP] = "skp",
--    [DB_SKS] = "sks",
    [DB_SKT] = "skt",
}
--_typIcoPrefix[PY_Dehero] = _typIcoPrefix[DB_Dehero]
--_typIcoPrefix[PY_Dequip] = _typIcoPrefix[DB_Dequip]
--_typIcoPrefix[PY_DequipSp] = _typIcoPrefix[DB_Dequip]
_typIcoPrefix[PY_Equip] = _typIcoPrefix[DB_Equip]
_typIcoPrefix[PY_EquipSp] = _typIcoPrefix[DB_Equip]
_typIcoPrefix[PY_Gem] = _typIcoPrefix[DB_Gem]
_typIcoPrefix[PY_Hero] = _typIcoPrefix[DB_Hero]
_typIcoPrefix[PY_Props] = _typIcoPrefix[DB_Props]
--_typIcoPrefix[PY_Sexcl] = _typIcoPrefix[DB_Sexcl]
_typIcoPrefix[PY_Soul] = _typIcoPrefix[DB_Hero]

--[Comment]
--获取Item图标(数据,数据类型(可为nil))
function _name.GetItemIco(d, typ)
    typ = typ or objt(d)
    if typ == nil then return "" end
    if typ == RW then return d.ico or "" end
--    if typ == PY_Dequip or typ == PY_DequipSp then return _typIcoPrefix[typ].."_"..d.img.."_"..d.rare end
--    if typ == DB_Dequip then return _typIcoPrefix[typ].."_"..d.img.."_1" end
    if typ == DB_SKP and d.sn == 0 then return ResName.NonItem end
    typ = _typIcoPrefix[typ]
    return typ and typ.."_"..(d.img or d.dbsn or d.sn) or ""
end

--[Comment]
--加载玩家角色图像{arg[number], return[string]}
function _name.PlayerRole(r) return "role_" .. r end
--[Comment]
--加载玩家图标{arg[number], return[string]}
function _name.PlayerIcon(a) return "ava_" .. a end
--[Comment]
--加载玩家主界面使用的图像{arg[number], return[string]}
function _name.PlayerIconMain(a) return "ava_" .. a .. "_m" end
--[Comment]
--加载称号图标（暂时只有一个通用图标）{arg[number], return[string]}
function _name.PlayerHtitleIcon(ht) return "htitle_common" end
--[Comment]
--武将图像{arg[number], return[string]}
function _name.HeroImage(i) return "h_" .. i end
--[Comment]
--武将图像2{arg[number], return[string]}
function _name.HeroIcon(i) return "h2_" .. i end
--[Comment]
--副将图像{arg[number], return[string]}
function _name.DeHeroImage(i) return "dh_" .. i end
--[Comment]
--副将图像{arg[number], return[string]}
function _name.DeheroIcon(i) return "dh2_" .. i end
--[Comment]
--军备图像{arg[number], return[string]}
function _name.DequipIcon(i, r) return "de_" .. i .. "_" .. r end
--[Comment]
--阵形图标{arg[number], return[string]}
function _name.LineupIcon(s) return "lu_" .. s end
--[Comment]
--阵形数据{arg[number], return[string]}
function _name.LineupData(s) return "lu_d_" .. s end
--[Comment]
--道具图标{arg[number], return[string]}
function _name.PropsIcon(i) return "p_" .. i end
--[Comment]
--装备图标{arg[number], return[string]}
function _name.EquipIcon(i) return "e_" .. i end
--[Comment]
--兵种图标{arg[number], return[string]}
function _name.SoldierIcon(s) return "so_" .. s end
--[Comment]
--战役图像{arg[number], return[string]}
function _name.WarImage(s) return "w_" .. s end
--[Comment]
--战役难度图像{arg[number], return[string]}
function _name.WarLvImage(s) return "w_l_" .. s end
--[Comment]
--名人堂图像{arg[number], return[string]}
function _name.FameImage(s) return "f_" .. s end
--[Comment]
--宝石图标{arg[number], return[string]}
function _name.GemIcon(s) return "g_" .. s end
--[Comment]
--天机专属图标{arg[number], return[string]}
function _name.SexclIcon(i) return "hs_" .. i end
--[Comment]
--活动积分图标{arg[number], return[string]}
function _name.ActScoreIcon(i) return "a_" .. i end
--[Comment]
--活动积分精灵名称{arg[number], return[string]}
function _name.ActScoreSprite(i) return "sp_act_" .. i end
--[Comment]
--战场BUFF图标{arg[number], return[string]}
function _name.BuffIcon(s) return "bb_" .. s end
--[Comment]
--日常功能图标{arg[number], return[string]}
function _name.DailyFuncIcon(s) return "df_" .. s end
--[Comment]
--日常特效{arg[number], return[string]}
function _name.DailyFuncEffect(s) return "ef_df_" .. s end
--[Comment]
--铜雀台美女图像{arg[number], return[string]}
function _name.BeautyImg(b) return "b_" .. b end
--[Comment]
--铜雀台美女图标{arg[number], return[string]}
function _name.BeautyIcon(b) return "b2_" .. b end
--[Comment]
--军阶突破图标 
function _name.HeroRankTornIcon(b) return "tex_hero_rank_" .. b end
--[Comment]
--关卡地图{arg[number], return[string]}
function _name.LevelMap(s) return "map_" .. s end
--[Comment]
--关卡地图节点数据{arg[number], return[string]}
function _name.LevelMapNode(s) return "map_d_" .. s end
--[Comment]
--PVP地图{arg[number], return[string]}
function _name.PvpMap(s) return "map_pvp_" .. s end
--[Comment]
--PVP地图节点数据{arg[number], return[string]}
function _name.PvpMapNode(s) return "map_pvp_d_" .. s end
--[Comment]
--战斗地图{arg[number], return[string]}
function _name.BattleMap(s) return "map_battle_" .. s end

--[Comment]
--武将技图标{arg[number], return[string]}
function _name.SkillIconC(s) return "skc_" .. s end
--[Comment]
--军师技图标{arg[number], return[string]}
function _name.SkillIconT(s) return "skt_" .. s end
--[Comment]
--觉醒技图标{arg[number], return[string]}
function _name.SkillIconE(s) return "ske_" .. s end
--[Comment]
--锦囊技图标{arg[number], return[string]}
function _name.SkillIconP(s) return "skp_" .. s end
--[Comment]
--副将技能图标{arg[number], return[string]}
function _name.SkillIconD(s) return "skd_" .. s end
--[Comment]
--天机技能图标{arg[number], return[string]}
function _name.SkillIconS(s) return "sks_" .. s end
--[Comment]
--武将技动画图集{arg[number], return[string]}
function _name.SkcAnim(sSN)
    if sSN == 1 or sSN == 7 or sSN == 17 or sSN == 20 or sSN == 26 then
    elseif sSN == 39 or sSN == 55 then
        sSN = 1
    elseif sSN == 8 or sSN == 12 or sSN == 47 or sSN == 49 then
        sSN = 7
    elseif sSN == 29 or sSN == 50 then
        sSN = 20
    else
        sSN = 0
    end
    return sSN > 0 and "skc_a_" .. sSN or ""
end
--[Comment]
--武将技特效预制件{arg[number], return[string]}
function _name.SkcEffect(sSN)
    if sSN == 50 then
        sSN = 29
    elseif sSN == 79 then
        sSN = 24
    end
    return "ef_skc_" .. sSN
end
--[Comment]
--副将技动画图集{arg[number], return[string]}
function _name.SkdAnim(sSN)
    if sSN ~= 7 then sSN = 0 end
    return sSN > 0 and "skc_a_" .. sSN or ""
end
--[Comment]
--副将技特效预制件{arg[number], return[string]}
function _name.SkdEffect(sSN)
    if sSN == 4 then
        return "ef_skc_48"
    elseif sSN == 10 then
        return "ef_skc_46"
    elseif sSN == 13 then
        return "ef_skc_35"
    elseif sSN == 18 then
        return "ef_skc_11"
    elseif sSN == 19 then
        sSN = 6
    elseif sSN == 24 then
        return "ef_skc_14"
    elseif sSN == 30 then
        sSN = 5
    end
    return "ef_skd_" .. sSN
end



--[Comment]
--资源名称
ResName = _name
