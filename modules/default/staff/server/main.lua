local staffModeUsers = { }

ZMan.RegisterCommand("admin", function(source)
  local Player = ZMan.Get(source)

  if staffModeUsers[source] ~= nil then
    staffModeUsers[source] = nil
  else
    staffModeUsers[source] = true
  end

  Player:TriggerEvent("__zm:client:staff:update", staffModeUsers[source] or false)
  print(Player:GetGroup())
end, false)

RegisterCommand("goto", function(source, args)
  local Player, Target = ZMan.Get(source), ZMan.Get(tonumber(args[1]))

  if Player and Target then
    Player:Teleport(Target:GetPosition(), 200)
  end
end)