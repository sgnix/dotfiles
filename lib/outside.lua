---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2014, Stefan G. <stefanguen@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local io = io
local os = os
local setmetatable = setmetatable
-- }}}

local outside = {}

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- {{{ IP widget type
local function worker(callback, filename)
    if not filename or not file_exists(filename) then
        return ""
    end

    local code = ""
    local line
    for line in io.lines(filename) do
        code = code .. line .. "\n"
    end

    os.remove(filename)
    callback(code)

    return ""
end
-- }}}

return setmetatable(outside, { __call = function(_, ...) return worker(...) end })
