ZMan.Callbacks = { }

ZMan.RegisterCallback = function(event, cb)
  if event ~= nil and tostring(event) ~= "" then
    if ZMan.Callbacks[event] ~= nil then
      return Utils.Logger.Error(("Callback ~lblue~(%s)~white~ already exists in our table!"):format(event), true)
    end
  
    ZMan.Callbacks[event] = cb
    
    Utils.Logger.Debug(("Successfuly registered a new callback ~green~(%s)"):format(event), true)  
  else
    Utils.Logger.Error(("Cannot register an ~red~%s ~white~callback"):format(event ~= nil and "empty" or "undefined"), true)
  end
end