-- Load the qw chunk with a recording _ENV and print every global it defines.
local path = arg[1]
local defined = {}
local function proxy()
    return setmetatable({}, { __index = function() return proxy() end,
        __call = function() return proxy() end })
end
local env = setmetatable({}, {
    __newindex = function(t, k, v) defined[k] = true; rawset(t, k, v) end,
    __index = function(t, k)
        if _G[k] ~= nil then return _G[k] end
        return proxy()
    end,
})
local chunk = assert(loadfile(path, "t", env))
local ok, err = pcall(chunk)
if not ok then io.stderr:write("top-level error: ", tostring(err), "\n") end
for k in pairs(defined) do print(k) end
