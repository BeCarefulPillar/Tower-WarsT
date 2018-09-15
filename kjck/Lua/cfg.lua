local _cfg =
{
    --[Comment]
    --保存的上次登录账号
    acc = nil,
    --[Comment]
    --保持的上次登录密码
    pwd = nil,
    --[Comment]
    -- umeng 主步骤
    umStep = nil,

    __index = _cfg,
}

cfg = _cfg

local _path = AM.rootPath .. "/cfg"

function CfgSave()
    if cfg then File.WriteCETextCRC(_path, json.encode(cfg)) end
end

function CfgLoad()
    local data = File.ReadCETextCRC(_path)
    if data then
        data = json.decode(data)
        if data then cfg = setmetatable(data, _cfg) end
    end
end

CfgLoad()