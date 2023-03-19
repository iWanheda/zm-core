RegisterNetEvent("__zm:server:modules:indentity:register")
AddEventHandler("__zm:server:modules:indentity:register", function(source)
  -- If player isn't registered yet (doesn't have a character) let's get one for 'em
  TriggerClientEvent("__zm:client:modules:indentity:register", source)

  local identityBucket = source + 1
  SetPlayerRoutingBucket(source, identityBucket)
  SetRoutingBucketPopulationEnabled(identityBucket, false)
end)

RegisterNetEvent("__zm:server:modules:indentity:data")
AddEventHandler("__zm:server:modules:indentity:data", function(source)

end)

ZMan.RegisterCallback("modules:identity:appearance", function(source, appearance)
  print(json.encode(appearance))
end)