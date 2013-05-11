-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")

local homedir = os.getenv("HOME") .. "/.config/awesome"

-- Theme handling library and local theme
local beautiful = require("beautiful")
beautiful.init(homedir .. "/themes/nice-and-clean-theme/theme.lua")

-- Notification library
local naughty = require("naughty")

-- Vicious
local vicious = require("vicious")

-- Local
local separator = require("lib/separator")
local dmenu = require("lib/dmenu")

-- Add vim style nav keys to menus
awful.menu.menu_keys = {
     up    = { "Up", "k" },
     down  = { "Down", "j" },
     exec  = { "Return", "Right", "l" },
     back  = { "Left", "h" },
     close = { "Escape" }
}

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title  = "Oops, there were errors during startup!",
        text   = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "Oops, an error ocurred!",
            text   = err
        })

        in_error = false
    end)
end

------------------------------------------------------------------------
-- Local funcs
------------------------------------------------------------------------

-- Copy all properties of one tag to another, except the screen
-- This is used when we want to move all clients from one screen
-- to another.
local function copy_tag( src, dst )
    local all = {"nmaster", "ncol", "mwfact", "windowfact", "layout"}
    for _, prop in ipairs(all) do
        awful.tag.setproperty( dst, prop, awful.tag.getproperty(src, prop) )
    end
end

-- Move all clients from one screen to another. Preserve tags, ratios etc.
local function move_all_clients( a, b, tags )
    for _, c in pairs(client.get(a)) do
        local src = c:tags()[1]
        local dst = tags[b][awful.tag.getidx(src)]
        copy_tag( src, dst )
        awful.client.movetotag(dst, c)
    end
    awful.screen.focus(b)
end


-- Default apps
local terminal = "/usr/bin/urxvtc -fn 'xft:Consolas-9' -fb 'xft:Consolas-9' -letsp -1 -pe tabbedex -depth 33"
local terminal2 = "urxvtc -pe tabbedex"
local terminal3 = "urxvtc -fn 'xft:erusfont-10' -fb 'xft:erusfont-10' -pe tabbedex"
local terminal4 = "urxvtc -fn 'xft:cure-9' -fb 'xft:cure-9' -pe tabbedex"
local editor = "vim"
local editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
}

-- Define a tag table which hold all screen tags.
local tags = {
    names   = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
    layouts = {
        layouts[2],
        layouts[1],
        layouts[1],
        layouts[3],
        layouts[2],
        layouts[1],
        layouts[1],
        layouts[1],
        layouts[10]
    }
}

-- Each screen has its own tag table.
for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layouts)
end

-- Configure some tags
awful.tag.setmwfact(0.65, tags[1][1])  -- Browser and inspector
awful.tag.setmwfact(0.7, tags[1][3])   -- Sparkpay work
awful.tag.setmwfact(0.7, tags[1][4])   -- gvim + 2 terms

--
-- Widget table
--
local widget = {

    -- Clock
    clock = awful.widget.textclock('%a %b %d, <span foreground="white">%I:%M</span> %p'),

    -- Separator
    separator = separator(),

    -- CPU
    cpu = (function()
        local cpu = wibox.widget.textbox()
        vicious.register(cpu, vicious.widgets.cpu, "CPU:$1%")
        return cpu
    end)(),

    -- Battery
    battery = (function()
        local notified = false
        local min = 7
        local battery = wibox.widget.textbox()
        vicious.register(battery, vicious.widgets.bat, function(w, args)
            local status, percent = args[1], args[2]
            if status ~= "+" and status ~= "-" then
                status = ""
            end
            if percent <= min and status == "-" and not notified then
                naughty.notify({
                    preset = naughty.config.presets.critical,
                    title  = "Battery Low!",
                    text   = "The battery is at " .. min .. "%!"
                })
                notified = true
            end
            if status ~= "-" then notified = false end
            return string.format("BAT:%s%s%%", status, percent)
        end, 60, "BAT0")
        return battery
    end)(),

    -- WIFI
    wifi = (function()
        local wifi = wibox.widget.textbox()
        vicious.register(wifi, vicious.widgets.wifi, function(w, args)
            return args["{ssid}"]
        end, 120, "wlp3s0")
        return wifi
    end)(),
}

mydmenu = dmenu({
    ["1)chromium"] = "chromium",
    ["2)dwb"] = "dwb",
    ["3)gvim"] = "gvim",
    ["4)vifm"] = terminal .. " -e vifm",
    ["41)vifm/mus"] = terminal .. " -e vifm " .. os.getenv("HOME") .. "/mus",
    ["42)vifm/down"] = terminal .. " -e vifm " .. os.getenv("HOME") .. "/down",
    ["43)vifm/torrent"] = terminal .. " -e vifm " .. os.getenv("HOME") .. "/Torrent",
    ["5)leafpad"] = "leafpad",
    ["6)firefox"] = function()
        awful.tag.viewonly(tags[1][5])
        awful.client.run_or_raise("firefox", function(c)
            return awful.rules.match(c, {class = 'Firefox'})
        end)
    end,
    ["7)rox"] = "rox",
    ["81)suspend"] = function()
        vicious.suspend()
        awful.util.spawn("systemctl suspend")
        vicious.activate()
    end,
    ["82)reboot"] = "systemctl reboot",
    ["83)poweroff"] = "systemctl poweroff",
    --[[
    sail = function()
        awful.tag.viewonly(tags[1][3])
        local exec = terminal2 .. ' -name sail -e ssh sail -t tmux -u attach'
        awful.client.run_or_raise(exec, function (c)
            return awful.rules.match(c, {instance = 'sail'})
        end)
    end
    --]]
})

---------------------------------------------------------------------------
-- Chrome table
---------------------------------------------------------------------------
local chrome = {
    wibox     = {},
    promptbox = {},
    layoutbox = {},
    taglist   = {},
}

---------------------------------------------------------------------------
-- Tag mouse bindings
---------------------------------------------------------------------------
chrome.taglist.buttons = awful.util.table.join(
    awful.button({ },        1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ },        3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ },        4, awful.tag.viewprev),
    awful.button({ },        5, awful.tag.viewnext)
)

---------------------------------------------------------------------------
-- Initialize all screen chromes
---------------------------------------------------------------------------
for s = 1, screen.count() do

    -- Create a promptbox for each screen
    chrome.promptbox[s] = awful.widget.prompt()

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    chrome.layoutbox[s] = awful.widget.layoutbox(s)

    -- Create a taglist widget
    chrome.taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, chrome.taglist.buttons)

    -- Create the wibox
    chrome.wibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(chrome.taglist[s])
    left_layout:add(widget.separator)
    left_layout:add(chrome.promptbox[s])
    if s == 1 then
        left_layout:add(mydmenu.textbox)
    end

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        right_layout:add(wibox.widget.systray())
        right_layout:add(widget.separator)
    end

    for _, w in ipairs({"wifi", "battery", "cpu", "clock"}) do
        right_layout:add(widget[w])
        right_layout:add(widget.separator)
    end
    right_layout:add(chrome.layoutbox[s])

    -- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    --layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    chrome.wibox[s]:set_widget(layout)
end

---------------------------------------------------------------------------
-- Global key bindings
---------------------------------------------------------------------------
local globalkeys = awful.util.table.join(
    awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

    -- Moving around
    awful.key({ modkey }, "j",
        function ()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function ()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function ()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function ()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "n",
        function ()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end),

    -- Swapping
    awful.key({ modkey, "Shift" }, "j",
        function ()
            awful.client.swap.bydirection("down")
        end),
    awful.key({ modkey, "Shift" }, "k",
        function ()
            awful.client.swap.bydirection("up")
        end),
    awful.key({ modkey, "Shift" }, "h",
        function ()
            awful.client.swap.bydirection("left")
        end),
    awful.key({ modkey, "Shift" }, "l",
        function ()
            awful.client.swap.bydirection("right")
        end),
    awful.key({ modkey, "Shift"   }, "n",
        function ()
            awful.client.swap.byidx(1)
        end),

    -- Exec terminals, quit and restart
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(terminal2) end),
    --awful.key({ modkey, "Control" }, "Return", function () awful.util.spawn(terminal3) end),
    --awful.key({ modkey, "Shift", "Control" }, "Return", function () awful.util.spawn(terminal4) end),
    -- Too dangerous to restart with the keyboard
    -- awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- Screen saver lock
    awful.key({ modkey }, "q", function ()
        awful.util.spawn("/usr/bin/xscreensaver-command -lock")
    end),

    -- Layout manipulation
    awful.key({ modkey }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Move to the next screen
    --awful.key({ modkey }, "s", function () awful.screen.focus_relative(1) end),
    awful.key({ modkey }, "s", function ()
        awful.util.spawn("/home/sge/sbin/dell-dock", false)
    end),

    -- Increase/decrease master window width
    awful.key({ modkey }, "]", function () awful.tag.incmwfact(0.05) end),
    awful.key({ modkey }, "[", function () awful.tag.incmwfact(-0.05) end),

    -- Increase/decrease the number of master windows
    awful.key({ modkey, "Shift" }, "]", function () awful.tag.incnmaster( 1) end),
    awful.key({ modkey, "Shift" }, "[", function () awful.tag.incnmaster(-1) end),

    -- Increase/decrease the number of column windows
    awful.key({ modkey, "Shift", "Control" }, "]", function () awful.tag.incncol( 1) end),
    awful.key({ modkey, "Shift", "Control" }, "[", function () awful.tag.incncol(-1) end),

    -- Switch layouts
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Move all left or right
    --[[
    awful.key({ modkey, "Shift"   }, ",", function () move_all_clients(1, 2, tags) end),
    awful.key({ modkey, "Shift"   }, ".", function () move_all_clients(2, 1, tags) end),
    --]]

    -- Backtick shows a menu with all open windows
    --[[
    awful.key({ modkey }, "`", function ()
        awful.menu.clients({ width = 400 }, { keygrabber = true })
    end),
    --]]

    -- Sound
    awful.key({ }, "XF86AudioRaiseVolume", function ()
        awful.util.spawn("amixer -c 0 set Master 2dB+", false)
    end),

    awful.key({ }, "XF86AudioLowerVolume", function ()
        awful.util.spawn("amixer -c 0 set Master 2dB-", false)
    end),

    awful.key({ }, "XF86AudioMute", function ()
        awful.util.spawn("amixer -c 0 set Master toggle", false)
    end),

    -- Run a program
    awful.key({ modkey }, "x", function () chrome.promptbox[mouse.screen]:run() end),

    -- Invert screen
    awful.key({ modkey }, "i", function ()
        awful.util.spawn("xcalib -i -a", false)
    end),

    -- Run lua code
    awful.key({ modkey, "Shift" }, "x",
      function ()
          awful.prompt.run({ prompt = "Run Lua code: " },
          chrome.promptbox[mouse.screen].widget,
          awful.util.eval, nil,
          awful.util.getdir("cache") .. "/history_eval")
      end),

    -- Execute a Lua script
    awful.key({ modkey, "Control" }, "x", function ()
        local read_file = function(filename)
            local code = ""
            for line in io.lines(filename) do code = code .. line .. "\n" end
            result = awful.util.eval(code)
            if result then
                naughty.notify({
                    preset = naughty.config.presets.normal,
                    title  = "Output",
                    text   = result
                })
            end
        end

        awful.prompt.run(
            { prompt = "Run Lua script: " }, chrome.promptbox[mouse.screen].widget,
            read_file, nil, awful.util.getdir("cache") .. "/history_exec"
        )
    end),

    awful.key({modkey}, ';', function()
        local matcher = function (c)
            return awful.rules.match(c, {class = 'URxvt'})
        end
        awful.client.run_or_raise(terminal, matcher)
    end),

    -- Execute
	awful.key({ modkey }, "e", function ()
        mydmenu:show()
	end)

)

-------------------------------------------------------------------------------
-- Client keys
-------------------------------------------------------------------------------
clientkeys = awful.util.table.join(

    -- Fullscreen
    awful.key({ modkey }, "f", function(c) c.fullscreen = not c.fullscreen end),

    -- Close window
    awful.key({ modkey }, "w", function(c) c:kill() end),

    -- Toggle floating
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle ),

    -- Set as master
    awful.key({ modkey, "Control" }, "Return", function(c)
        c:swap(awful.client.getmaster())
    end),

    -- Redraw
    awful.key({ modkey, "Shift" }, "r", function(c) c:redraw() end),

    -- Set on top
    awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end),

    -- Maximize
    awful.key({ modkey }, "m", function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end),

    -- Set sticky (stays on all tags)
    awful.key({ modkey, "Shift" }, "/", function(c) c.sticky = not c.sticky end)
)

------------------------------------------------------------------------------
-- Mouse buttons bound to each new client window
------------------------------------------------------------------------------
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize),
    awful.button({ modkey }, 4, awful.tag.viewprev),
    awful.button({ modkey }, 5, awful.tag.viewnext)
)


-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

-- Set keys
root.keys(globalkeys)

---------------------------------------------------------------------------
-- Client rules
---------------------------------------------------------------------------
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = true,
            keys = clientkeys,
            buttons = clientbuttons
        },
        callback = awful.client.setslave
    },

    {
        rule = { role = "browser" },
        properties = { floating = false }
    },

    {
        rule = { class = "Pidgin" },
        except = { role = "conversation" },
        properties = { floating = true }
    },

    -- Set Firefox to always map on tags number 5 of screen 1.
    --[[
    {
        rule = { class = "Firefox" },
        properties = { tag = tags[1][5] }
    },
    --]]
}

-- Put all classes you need floating here
local floaters = {
    "MPlayer", "feh", "Avidemux2_gtk", "gimp", "ADT",
    "emulator64-arm", "Gpick", "Skype", "VirtualBox",
    "Bitcoin-qt", "Wireshark"
}

for _, name in ipairs(floaters) do
    table.insert(awful.rules.rules, {
        rule = { class = name },
        properties = { floating = true }
    })
end

-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
            -- awful.client.floating.set(c, true);
        end
    end
end)

-- Focused client gets a shiny border
client.connect_signal("focus", function(c)
    c.border_color = "#00ff00"

    if focus_timer then focus_timer:stop() end
    focus_timer = timer({timeout = 3})

    focus_timer:connect_signal("timeout", function()
        if c == client.focus then
            c.border_color = beautiful.border_focus
        end
    end)

    focus_timer:start();
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

