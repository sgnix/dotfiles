local awful = require("awful")
local util = require("lib/util")

local output = "Done"

-- Start code

do
    exec = 'urxvtc -e urxvtc -pe tabbedex -name sail -e ssh sail -t tmux -u attach'
    awful.client.run_or_raise(exec, function (c)
        return awful.rules.match(c, {class = 'sail'})
    end)
end

-- End code

return(output)

