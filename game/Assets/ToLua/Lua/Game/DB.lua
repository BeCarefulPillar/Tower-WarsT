local _db = {
    cfg =
    {
        plant = "DB_Plant",
    },
    dat =
    {
    },
}

function _db.Load()
    local d
    for nm, fnm in pairs(_db.cfg) do
        d = require("Game/" .. fnm)
        for _, v in ipairs(d._dat) do
            setmetatable(v, d)
        end
        _db.dat[nm] = d._dat
    end
end

DB = _db