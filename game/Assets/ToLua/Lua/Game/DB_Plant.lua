---- [Comment]
---- 攻击
---- [伤害，间隔，次数]
--    att=nil,

--    --[Comment]
--    --防御


--    --[Comment]
--    --生产阳光
--    --[产量，间隔，次数]
--    cre_sun=nil,

--    --[Comment]
--    --生产金币
--    --[产量，间隔，次数]
--    cre_gold=nil,

DB_Plant = {
    sn = nil,
    nm = nil,
    price = nil,
    cd = nil,
}

DB_Plant._dat = {
    { sn = 1, nm = "豌豆射手", price = 100, cd = 7.5, i = "每次攻击射出一发豌豆" },
    { sn = 2, nm = "向日葵", price = 50, cd = 7.5, i = "每24秒生产一个中型阳光（25阳光值）" },
    { sn = 3, nm = "樱桃炸弹", price = 150, cd = 30, i = "杀伤范围内大杀伤力爆破" },
    { sn = 4, nm = "坚果墙", price = 50, cd = 30, i = "以高耐久阻挡僵尸前行" },
}

return DB_Plant