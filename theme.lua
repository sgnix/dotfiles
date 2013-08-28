local theme = {}
local dir = "/home/sge/.config/awesome/"

theme.font          = "terminus 12"

theme.bg_normal     = "#000000"
theme.bg_focus      = "#44aa44"
theme.bg_urgent     = "#d02e54"
theme.bg_minimize   = "#444444"

theme.fg_normal     = "#cccccc"
theme.fg_focus      = "#000000"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = "1"
theme.border_normal = "#222222"
theme.border_focus  = "#009900"
theme.border_marked = "#91231c"
theme.border_high   = "#00ff00"

theme.clock_fg = "#ffffcc"

-- Display the taglist squares
theme.taglist_squares_sel    = dir .. "img/squarefw.png"
theme.taglist_squares_unsel  = dir .. "img/squarew.png"
theme.tasklist_floating_icon = dir .. "img/butterfly.png"

theme.layout_tile       = "[=]"
theme.layout_tilebottom = "[|]"
theme.layout_fullscreen = "[O]"
theme.layout_floating   = "[.]"
theme.layout_monocle    = "[M]"

return theme
