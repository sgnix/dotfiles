local textbox = require("wibox.widget.textbox")
local io = { popen = io.popen }
local timer = timer
local fread = { mt = {} }

local function update(self)
    local s = io.popen(self.url)
    local res = ''
    for line in s:lines() do
        res = res .. line
    end

    if self.callback ~= nil then
        res = self.callback(res)
    end

    self.w:set_markup(
        '<span foreground="' .. self.fg
        .. '" background="' .. self.bg .. '">'
        .. res
        .. '</span>'
    )
end

function fread.new(args)

    local self = {
        url      = args.url,
        fg       = args.fg or "#aaaaaa",
        bg       = args.bg or "#000000",
        timeout  = args.timeout or 3600,
        callback = args.callback,
        w        = textbox()
    }

    self.w:connect_signal("mouse::enter", function() update(self) end)

    local timer = timer{ timeout = self.timeout }
    timer:connect_signal("timeout", function() update(self) end)
    timer:start()
    timer:emit_signal("timeout")
    return self
end

function fread.mt:__call(...)
    return fread.new(...)
end

return setmetatable(fread, fread.mt)
