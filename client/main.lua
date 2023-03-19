if Config.EnablePvP then
  NetworkSetFriendlyFireOption(true)
  SetCanAttackFriendly(PlayerPedId(), true, false)
end

-- Set default Ped model
local pedModel = `mp_m_freemode_01`

RegisterNetEvent("__zm:player:loaded")
AddEventHandler("__zm:player:loaded", function()
  SetEntityCoords(
    PlayerPedId(),
    ZMan.Player.Data.last_location[1],
    ZMan.Player.Data.last_location[2],
    ZMan.Player.Data.last_location[3],
    false, false, false, false
  )

  TriggerServerEvent("__zm:player:loaded")
end)

RegisterNetEvent("__zm:internal:load:dict_anim")
AddEventHandler("__zm:internal:load:dict_anim", function(dict, anim)
  RequestAnimDict(dict)

  -- https://docs.fivem.net/natives/?_0xF66A602F829E2A06
  while not HasAnimDictLoaded(dict) do
    Citizen.Wait(1)
  end

  ClearPedTasks(PlayerPedId())
  TaskPlayAnim(GetPlayerPed(-1), dict, anim, 8.0, 8.0, -1, 0, 0, false, false, false)
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(2000)

    local _playerPedId = PlayerPedId()

    if ZMan.Cache.Ped ~= nil and ZMan.Cache.Ped ~= _playerPedId then
      ZMan.Cache.Ped = _playerPedId
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(20)

    if IsPedInAnyVehicle(ZMan.Cache.Ped, false) then
      SetVehicleRadioEnabled(GetVehiclePedIsIn(ZMan.Cache.Ped, false), false)
    end
  end
end)

Citizen.CreateThread(function()
  Utils.Logger.Debug(("Changing Player's ped to: ~green~%s (hash)"):format(pedModel))

  TriggerServerEvent("__zm:joined")

  -- remake
  SendNuiMessage(
    json.encode( { type = "ZMan/closeLoading" } )
  )
  Citizen.Wait(2000)
  ShutdownLoadingScreenNui()

  if GetEntityModel(PlayerPedId()) ~= pedModel then
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
      Citizen.Wait(1)
    end
  
    SetPlayerModel(PlayerId(), pedModel)
    SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
  end

  ZMan.Cache.Ped = PlayerPedId()

  exports.spawnmanager:setAutoSpawn(false)

  local kvp = GetResourceKvpString("KireSefid")
	if kvp == nil or kvp == "" then
		SetResourceKvp("KireSefid", "pixota")
    print("new kvp")
  else
    print(kvp)
  end

  -- If Data still hasn't been loaded into memory, let's wait.
  while Utils.Misc.TableSize(ZMan.Player.Data) == 0 do
    Citizen.Wait(1)
  end

  local playerPos = ZMan.Player.Data.last_location

  if playerPos ~= nil then
    exports.spawnmanager:spawnPlayer(
    {
      x = playerPos[1],
      y = playerPos[2],
      z = playerPos[3],
      heading = playerPos[4],
      skipFade = false
    })
  end

  SetPedDefaultComponentVariation(GetPlayerPed())

  -- Let's setup our Hud, hide default GTA health component
  local minimap = RequestScaleformMovie("minimap")
  SetBigmapActive(true, false)

  Citizen.Wait(0)
  SetBigmapActive(false, false)
  Citizen.Wait(100)

  BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
  ScaleformMovieMethodAddParamInt(3)
  EndScaleformMovieMethod()
end)

Citizen.CreateThread(function()
  DisplayRadar(false)
  
  while true do
    InvalidateIdleCam()
    InvalidateVehicleIdleCam()

    Citizen.Wait(15000)
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1500)
    SendNuiMessage(
      json.encode(
        {
          type = "ZMan/updateUi",
          health = GetEntityHealth(PlayerPedId()),
          maxHealth = GetEntityMaxHealth(PlayerPedId()),
          armor = GetPedArmour(PlayerPedId()),
          cash = 12834,
          bankMon = 7377223,
          dirtyMon = 1255,
          userId = GetPlayerServerId(PlayerId())
        }
      )
    )
  end
end)

RegisterCommand("tpc", function(source, args, raw)
  --if raw:find(",") then
  --  args = args.join(" ")
  --  local t = { }
  --  for word in string.gmatch(raw, '([^,]+)') do
  --    t[]
  --  end
  --end
  SetEntityCoords(PlayerPedId(), tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), true, true, true, false)
end)