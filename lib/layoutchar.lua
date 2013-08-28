local setmetatable = setmetatable
local layout = require("awful.layout")
local tag = require("awful.tag")
local beautiful = require("beautiful")
local textbox = require("wibox.widget.textbox")

--- Layoutbox widget.
-- awful.widget.layoutchar
local layoutchar = { mt = {} }

local function update(w, screen)
    local layout = layout.getname(layout.get(screen))
    w:set_text(layout and beautiful["layout_" .. layout])
end

--- Create a layoutchar widget. It draws a picture with the current layout
-- symbol of the current tag.
-- @param screen The screen number that the layout will be represented for.
-- @return An imagebox widget configured as a layoutchar.
function layoutchar.new(screen)
    local screen = screen or 1
    local w = textbox()
    update(w, screen)

    local function update_on_tag_selection(t)
        return update(w, tag.getscreen(t))
    end

    tag.attached_connect_signal(screen, "property::selected", update_on_tag_selection)
    tag.attached_connect_signal(screen, "property::layout", update_on_tag_selection)

    return w
end

function layoutchar.mt:__call(...)
    return layoutchar.new(...)
end

return setmetatable(layoutchar, layoutchar.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
