local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

RegisterCommand("statebag", function(source)
  local playerPedId = GetPlayerPed(source)
  local playerVeh = GetVehiclePedIsIn(playerPedId, false)

  if playerVeh ~= 0 then
    Entity(playerVeh).state:set('owner', GetPlayerIdentifier(source, 0), false)
    Entity(playerVeh).state:set('uuid', uuid(), false)
    local owner = Entity(playerVeh).state.owner
    print(owner)
    local uuid = Entity(playerVeh).state.uuid
    print(uuid)
  end
end)

local vehTable = {}

RegisterCommand("unpark", function(source)
  local playerPedId = GetPlayerPed(source)
  local playerIdentifier = GetPlayerIdentifier(source, 0)

  for k, v in pairs(vehTable) do
    print(json.encode(v))
    if v.owner == playerIdentifier then
      SetVehicleDoorsLocked(playerVeh, 0)
      FreezeEntityPosition(playerVeh, false)
      TaskEnterVehicle(playerPedId, playerVeh, 0)
    end
  end
end)

RegisterCommand("park", function(source)
  local playerPedId = GetPlayerPed(source)
  local playerVeh = GetVehiclePedIsIn(playerPedId, false)

  if playerVeh ~= 0 then
    local vehOwnerState = Entity(playerVeh).state.owner
    if vehOwnerState ~= nil then
      local playerIdentifier = GetPlayerIdentifier(source, 0)
      if vehOwnerState == playerIdentifier then
        local vehUuidState = Entity(playerVeh).state.uuid
        if vehUuidState == nil then print("invalid unique id") return end
        vehTable[vehUuidState] = { model = GetEntityModel(playerVeh), owner = vehOwnerState, mods = {}, position = GetEntityCoords(playerVeh, false) }
        print("parked!")
        TaskLeaveVehicle(playerPedId, playerVeh, 0)
        SetVehicleDoorsLocked(playerVeh, 2)
        FreezeEntityPosition(playerVeh, true)
      else
        print("you need to be the owner of the vehicle!")
      end
    else
      print("you need a valid vehicle, cannot be spawned!")
    end
  else
    print("you need to be in a vehicle!")
  end
end)