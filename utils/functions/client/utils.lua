SendReactMessage = function(action, data, focus)
  TriggerEvent("__zm:ui:sendMessage", action, data, focus)
end

RegisterReactCallback = function(eventNui, cb)
  TriggerEvent("__zm:ui:registerCallback", eventNui, cb)
end