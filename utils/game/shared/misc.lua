Utils.Misc =
{
  -- https://stackoverflow.com/a/27028488/10781841
  DumpTable = function(table)
    if type(table) == "table" then
      local s = "{ "
      for k, v in pairs(table) do
        if type(k) ~= "number" then
          k = ("\"%s\""):format(k)
        end
        s = ("%s[%s] = %s,"):format(s, k, Utils.Misc.DumpTable(v))
      end
      return ("%s} "):format(s)
    else
      return tostring(table)
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