
local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")

local separator = { mt = {} }

function separator.new(text, color)
    local text = text or ' | '
    local color = color or "green"

    local w = textbox()
    w:set_markup('<span foreground="' .. color .. '">' .. text .. '</span>');
    return w
end

function separator.mt:__call(...)
    return separator.new(...)
end

return setmetatable(separator, separator.mt)
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
