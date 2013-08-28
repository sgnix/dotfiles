local textbox = require("wibox.widget.textbox")
local io = { popen = io.popen }
local timer = timer
local fread = { mt = {} }

function fread.new(url, timeout, fg, bg)
    local timeout = timeout or 3600
    local fg = fg or "#aaaaaa"
    local bg = bg or "#000000"

    local w = textbox()
    local timer = timer{ timeout = timeout }
    timer:connect_signal("timeout", function()
        local s = io.popen(url)
        local res = ''
        for line in s:lines() do
            res = res .. line
        end
        w:set_markup('<span foreground="' .. fg .. '" background="' .. bg .. '">' .. res .. '</span>')
    end)
    timer:start()
    timer:emit_signal("timeout")
    return w
end

function fread.mt:__call(...)
    return fread.new(...)
end

return setmetatable(fread, fread.mt)
