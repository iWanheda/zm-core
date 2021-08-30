local customFormattingTable = {
  ["~red~"] = "^1",
  ["~green~"] = "^2",
  ["~yellow~"] = "^3",
  ["~dblue~"] = "^4",
  ["~lblue~"] = "^5",
  ["~violet~"] = "^6",
  ["~white~"] = "^7",
  ["~fuchsia~"] = "^8",

  ["~bold~"] = "^*",
  ["~underline~"] = "^_",
  ["~sthrough~"] = "^~"
}

Utils.Logger =
{
  Info = function(log, a)
    if log ~= nil then
      for k, v in pairs(customFormattingTable) do log = log:gsub(k, v) end

      print(("< %s > ^4(INFO)^7 - %s%s^7"):format(Config.ServerName, (a and "✔️ | " or ""), log))
    end
  end,

  Error = function(log, a)
    if log ~= nil then
      for k, v in pairs(customFormattingTable) do log = log:gsub(k, v) end

      print(("< %s > ^1(ERROR)^7 - %s%s^7"):format(Config.ServerName, (a and "❌ | " or ""), log))
    end
  end,

  Warn = function(log)
    if log ~= nil then
      for k, v in pairs(customFormattingTable) do log = log:gsub(k, v) end

      print(("< %s > ^3(WARNING)^7 - %s^7"):format(Config.ServerName, log))
    end
  end,

  Debug = function(log)
    if log ~= nil and Config.Debug == true then
      for k, v in pairs(customFormattingTable) do log = log:gsub(k, v) end

      print(("< %s > ^5(DEBUG)^7 - %s^7"):format(Config.ServerName, log))
    end
  end
}
