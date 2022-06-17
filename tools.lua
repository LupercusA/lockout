
lockout.tools = {}
local tools = lockout.tools

-- Returns a table of the string split by the given seperation string
tools.split = function (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end
