local awful = require("awful")
local textbox = require("wibox.widget.textbox")
local io = { popen = io.popen }
local capi = { timer = timer }
local ipaddr = { mt = {} }

local function update(w)
    local s = io.popen("curl http://icanhazip.com")
    local myip = ''
    for line in s:lines() do
        myip = myip .. line
    end
    w:set_markup('<span foreground="#aaaaaa">' .. myip .. '</span>')
end

function ipaddr.new(timeout)
    local timeout = timeout or 3600
    local w = textbox()
    local timer = capi.timer{ timeout = timeout }
    -- update(w)
    timer:connect_signal("timeout", function()
        update(w)
    end)
    timer:start()
    timer:emit_signal("timeout")

    return w
end

function ipaddr.mt:__call(...)
    return ipaddr.new(...)
end

return setmetatable(ipaddr, ipaddr.mt)
