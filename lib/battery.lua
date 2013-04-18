local io = io
local string = string
local math = math
local naughty = naughty
local textbox = require("wibox.widget.textbox")
local capi = { timer = timer }

local tonumber = tonumber
local setmetatable = setmetatable

local battery = { mt = {} }

-- Battery reading func. Change BAT1 to whatever if needed
local function battery_read (name, command)
    local path = ("/sys/class/power_supply/" .. name .. "/" .. command)
    local fh = io.open( path, "r" )
    if fh == nil then return(nil) end
    local result = fh:read()
    fh:close()
    return result
end

local function color_val(val, colors)
    if not #colors then return(nil) end
    local chunk = math.floor(100 / #colors)
    local idx = math.floor(val / chunk)
    return colors[idx + 1]
end

local function show(w, val, fg )
    local fg = fg or "#aaaaaa"
    w:set_markup('<span foreground="' .. fg .. '">' .. val .. '</span>')
end

-- Function for updating battery
local function update (tbw, name)

    -- Battery present and reporting?
    local present = battery_read(name, "present")
    local status = battery_read(name, "status")
    if present == nil or tonumber(present) < 1 or status == nil then
        show(tbw, "n/a", "#444444")
        return(nil)
    end

    -- Get the full charge value
    local full_charge = tonumber(battery_read(name, "charge_full_design"))
    local curr_charge = tonumber(battery_read(name, "charge_now"))

    if full_charge == nil or curr_charge == nil then
        show(tbw, "???", "#444444")
        return(nil)
    end

    local percent = (curr_charge / full_charge) * 100

    -- Setup an alert for low battery
    if percent <= 10 and status == "Discharging" then
        if not lo_battery then
            lo_battery = true
            naughty.notify({
                preset = naughty.config.presets.critical,
                text   = "Battery low!"
            })
        end
    else
        lo_battery = false
    end

    show( tbw, string.format("%s:%02d%%", string.sub(status, 1, 1), percent) )
end

function battery.new ( name, timeout )
    local name = name or "BAT0"
    local timeout = timeout or 10

    local w = textbox()
    local timer = capi.timer { timeout = timeout }
    timer:connect_signal("timeout", function() update(w, name) end)
    timer:start()
    timer:emit_signal("timeout")
    return w
end

function battery.mt:__call(...)
    return battery.new(...)
end

return setmetatable(battery, battery.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
