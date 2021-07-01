Utils.Misc =
{
    -- https://stackoverflow.com/a/27028488/10781841
    DumpTable = function(o)
        if type(o) == "table" then
            local s = "{ "
            for k, v in pairs(o) do
                if type(k) ~= "number" then
                    k = '"' .. k .. '"'
                end
                s = s .. "[" .. k .. "] = " .. Utils.Misc.DumpTable(v) .. ","
            end
            return s .. "} "
        else
            return tostring(o)
        end
    end,
    TableSize = function(table)
        local count = 0

        for _, __ in pairs(table) do
            count = count + 1
        end

        return count
    end
}
