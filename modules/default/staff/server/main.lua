local staffModeUsers = { }

RegisterCommand("admin1", function(source)
  local Player = ZMan.Get(source)

  --if not Player:IsStaff() then return end

  if staffModeUsers[source] ~= nil then
    staffModeUsers[source] = nil
  else
    staffModeUsers[source] = true
  end

  Player:TriggerEvent("__zm:client:staff:update", staffModeUsers[source] or false)
end)