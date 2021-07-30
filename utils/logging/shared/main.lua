Utils.Logger =
{
  Info = function(log)
    if log ~= nil then
      print(("< %s > %s(INFO)^7 - %s^7"):format(Config.ServerName, Utils.Colors.DBlue, log))
    end
  end,

  Error = function(log)
    if log ~= nil then
      print(("< %s > %s(ERROR)^7 - %s^7"):format(Config.ServerName, Utils.Colors.Red, log))
    end
  end,

  Warn = function(log)
    if log ~= nil then
      print(("< %s > %s(WARNING)^7 - %s^7"):format(Config.ServerName, Utils.Colors.Yellow, log))
    end
  end,

  Debug = function(log)
    if log ~= nil and Config.Debug == true then
      print(("< %s > %s(DEBUG)^7 - %s^7"):format(Config.ServerName, Utils.Colors.LBlue, log))
    end
  end
}
