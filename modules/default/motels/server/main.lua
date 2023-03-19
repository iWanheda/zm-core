ZMan.RegisterCallback("modules:motels:getInMotel", function(source, motelId)
  if Config.Mods.Motels[motelId] == nil then return end
  
  local Player = ZMan.Get(source)

  Player:PlayAnimation("amb@code_human_in_car_mp_actions@dance@std@rps@base", "enter")
  TriggerClientEvent('InteractSound_CL:PlayOnOne', source, "door_open_close", 1.0)
  Player:Teleport(Config.Mods.Motels[motelId].inside)

  local newBucket = source + 1
  SetPlayerRoutingBucket(source, newBucket)
  SetRoutingBucketPopulationEnabled(newBucket, true)
end)

ZMan.RegisterCallback("modules:motels:leaveMotel", function(source, motelId)
  if Config.Mods.Motels[motelId] == nil then return end
  
  local Player = ZMan.Get(source)

  Player:PlayAnimation("amb@code_human_in_car_mp_actions@dance@std@rps@base", "enter")
  TriggerClientEvent('InteractSound_CL:PlayOnOne', source, "door_open_close", 1.0)
  Player:Teleport(Config.Mods.Motels[motelId].outside)

  SetPlayerRoutingBucket(source, 1)

  print(Player:GetBaseName())
end)