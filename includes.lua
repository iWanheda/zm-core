TriggerEvent('__zm:getLibrary', function(lib) ZMan = lib end)

-- Probably can't be defined in a shared script, I guess it'll use zm-core's config?
L = function(str)
  if Config.Locale ~= nil then
    return Locales[Config.Locale][str]
  else
    return Utils.Logger.Error("~red~Config.Locale ~white~is null!")
  end
end