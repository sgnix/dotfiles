---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2014, Stefan G. <stefanguen@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}

local ipaddr = {}

-- {{{ IP widget type
local function worker()
    local canhaz = "http://ifnx.com/ip"
    local f = io.popen("curl --connect-timeout 1 -fsm 3 " .. canhaz)
    local ws = f:read("*all")
    f:close()

    return ws or 'n/a'
end
-- }}}

return setmetatable(ipaddr, { __call = function(_, ...) return worker(...) end })
