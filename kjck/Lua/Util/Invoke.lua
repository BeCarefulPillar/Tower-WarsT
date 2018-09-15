local Time = Time
local _Invoke = { }

local mt = { __index = _Invoke }

local function Update(f)
    if f.tm > (f.unscaled and Time.realtimeSinceStartup or Time.time) then return end
    if f.handle then UpdateBeat:RemoveListener(f.handle) end
    f.func(unpack(f.arg))
end

function _Invoke:Reset(f, delay, unscaled, ...)
    self.func = f or self.func
    self.delay = delay or self.delay
    self.unscaled = unscaled == nil or self.unscaled and unscaled
    self.arg = f and { ... } or self.arg
    if self.delay > 0 then
        if not self.handle then self.handle = UpdateBeat:CreateListener(self.Update, self) end
        self.tm = (self.unscaled and Time.realtimeSinceStartup or Time.time) + self.delay
        UpdateBeat:AddListener(self.handle)
    else
        if self.handle then UpdateBeat:RemoveListener(self.handle) end
        self.tm = 0
        self.func(unpack(self.arg))
    end
end

function _Invoke:Stop()
    if self.handle then UpdateBeat:RemoveListener(self.handle) end
    self.tm = 0
end

function _Invoke:isRunning() return self.tm > (self.unscaled and Time.realtimeSinceStartup or Time.time) end

--[Comment]
--延迟调用
function Invoke(f, delay, unscaled, ...)
    if f == nil then return end
    f = setmetatable({ func = f, arg = {...}, delay = delay or 0, unscaled = unscaled or false and true }, mt)
    if delay > 0 then
        f.tm =(f.unscaled and Time.realtimeSinceStartup or Time.time) + delay
        f.handle = UpdateBeat:CreateListener(Update, f)
        UpdateBeat:AddListener(f.handle)
    else
        f.tm = 0
        f.func(...)
    end
    return f
end
