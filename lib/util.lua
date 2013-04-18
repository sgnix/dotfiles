
local util = {}

-- Dump a table
function util.dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) == 'number' then k = '"'..k..'"' end
            if type(k) == 'function' then k = "function" end
            s = s .. '['..k..'] = ' .. util.dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

return util
