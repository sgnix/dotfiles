
-- Vars
local homedir    = os.getenv("HOME") .. "/.config/awesome"
local terminal   = "/usr/bin/urxvtc"
local terminal2  = terminal .. " -fn 'xft:Dina:pixelsize=8' -fb 'xft:Dina:pixelsize=8'"
local editor     = "vim"
local editor_cmd = terminal .. " -e " .. editor
local modkey     = os.getenv("AWESOME_TEST") and "135" or "Mod4"

-- Standard awesome library
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")

-- Libs
local wibox      = require("wibox")
local naughty    = require("naughty")
local vicious    = require("vicious")
local beautiful  = require("beautiful")
local separator  = require("lib/separator")
local fread      = require("lib/fread")
local dmenu      = require("lib/dmenu")
local layoutchar = require("lib/layoutchar")

-- Layouts
awful.layout.suit.monocle = require("layout/monocle")

-- Theme handling library and local theme
beautiful.init(homedir .. "/theme.lua")

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

------------------------------------------------------------------------
-- Tags and layouts
------------------------------------------------------------------------

-- Define a tag table which hold all screen tags.
local tags = {
    names   = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
    layouts = {
        awful.layout.suit.tile,
        awful.layout.suit.tile,
        awful.layout.suit.monocle,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile,
        awful.layout.suit.tile,
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        awful.layout.suit.floating,
    }
}

-- Each screen has its own tag table.
for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layouts)
end

-- Configure some tags
awful.tag.setmwfact(0.65, tags[1][1])  -- Browser and inspector
awful.tag.setmwfact(0.7, tags[1][4])   -- gvim + 2 terms

----------------------------------------------------------------
-- Widget table
----------------------------------------------------------------

local widget = {

    -- DMenu
    dmenu = (function()
        local function to_tag( tag, app, class )
            awful.tag.viewonly(tags[1][tag])
            awful.client.run_or_raise(app, function(c)
                return awful.rules.match(c, {class = class})
            end)
        end

        return dmenu({
            chromium   = "chromium",
            dwb        = "dwb",
            gvim       = function() to_tag( 4, "gvim", "Gvim" ) end,
            vifm       = terminal .. " -e vifm",
            music      = terminal .. " -e vifm " .. os.getenv("HOME") .. "/mus",
            down       = terminal .. " -e vifm " .. os.getenv("HOME") .. "/down",
            pidgin     = function() to_tag( 6, "pidgin", "Pidgin") end,
            firefox    = function() to_tag( 5, "firefox", "Firefox" ) end,
            virtualbox = function() to_tag( 9, "virtualbox", "VirtualBox" ) end,
            suspend    = function()
                vicious.suspend()
                awful.util.spawn("systemctl suspend")
                vicious.activate()
            end,
        })
    end)(),

    -- Clock
    clock = awful.widget.textclock('%a %b %d, <span foreground="' .. beautiful.clock_fg .. '">%I:%M</span> %p'),

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

    -- Wifi
    wifi = (function()
        local obj = fread{ url = homedir .. "/bin/wifi.sh wlp3s0" }
        return obj.w
    end)(),

    -- Weather
    weather = (function()
        local obj = fread{
            url     = homedir .. "/bin/weather.sh 97223",
            timeout = 20 * 60
        }
        return obj.w
    end)(),

    -- IP ADDRESS
    ipaddr = (function()
        local obj = fread{ url = "curl -s http://icanhazip.com" }
        return obj.w
    end)()
}

---------------------------------------------------------------------------
-- Chrome table
---------------------------------------------------------------------------
local chrome = {
    wibox     = {},
    promptbox = {},
    layoutbox = {},
    taglist   = {},
    tcount    = {}
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

    -- Create an imagebox widget which contains an icon indicating which layout we're using.
    chrome.layoutbox[s] = layoutchar(s)

    -- Create a taglist widget
    chrome.taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, chrome.taglist.buttons)

    -- Client count
    local client_count = (function()
        local w = wibox.widget.textbox()
        local function update()
            w:set_text(" " .. #(awful.client.visible()))
        end
        update()
        client.connect_signal("tagged", update)
        client.connect_signal("untagged", update)
        return w
    end)()

    -- Create the wibox
    chrome.wibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(chrome.taglist[s])
    left_layout:add(widget.separator)
    left_layout:add(chrome.layoutbox[s])
    left_layout:add(client_count)
    left_layout:add(widget.separator)
    left_layout:add(chrome.promptbox[s])
    if s == 1 then
        left_layout:add(widget.dmenu.textbox)
    end

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        right_layout:add(wibox.widget.systray())
        right_layout:add(widget.separator)
    end

    for _, w in ipairs({"weather", "wifi", "ipaddr", "battery", "cpu", "clock"}) do
        right_layout:add(widget[w])
        right_layout:add(widget.separator)
    end

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
        awful.util.spawn("/home/sge/sbin/switch-screens", false)
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

    -- Move all left or right
    --[[
    awful.key({ modkey, "Shift"   }, ",", function () move_all_clients(1, 2, tags) end),
    awful.key({ modkey, "Shift"   }, ".", function () move_all_clients(2, 1, tags) end),
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
        widget.dmenu:show()
	end),

    ---------------------------------------------------
    -- LAYOUTS
    ---------------------------------------------------

    -- Monocle
    awful.key({ modkey }, "m", function()
        awful.layout.set( awful.layout.suit.monocle )
    end),

    -- Floating
    awful.key({ modkey }, "f", function()
        awful.layout.set( awful.layout.suit.floating )
    end),

    -- Tile
    awful.key({ modkey }, "t", function()
        if awful.layout.get().name == "tile" then
            awful.layout.set( awful.layout.suit.tile.bottom )
        else
            awful.layout.set( awful.layout.suit.tile )
        end
    end)
)

-------------------------------------------------------------------------------
-- Client keys
-------------------------------------------------------------------------------
clientkeys = awful.util.table.join(

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

-------------------------------------------------------------
-- Signals
-------------------------------------------------------------

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
    c.border_color = beautiful.border_high;

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

