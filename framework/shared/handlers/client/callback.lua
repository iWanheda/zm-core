ZMan.Callback = function(event, cb, args)
  if event ~= nil and tostring(event) ~= "" then
    if ZMan.Callbacks[event] ~= nil then
      TriggerEvent(tostring(event), args)
    else
      Utils.Logger.Error(("Callback ~lblue~(%s)~white~ does ~red~not ~white~exist in our table"):format(event), true)
    end
  else
    Utils.Logger.Error(("Cannot trigger an ~red~%s ~white~callback"):format(event ~= nil and "empty" or "undefined"), true)
  end
end