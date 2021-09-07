TriggerServerEvent("__zm:joined")

RegisterNetEvent("__zm:getLibrary")
AddEventHandler(
  "__zm:getLibrary",
  function(cb)
    ZMan.Utils = Utils -- Do not send server Utils
    
    cb(ZMan)
  end
)

-- Set default Ped model
local pedModel = `mp_m_freemode_01`

RegisterNetEvent("__zm:playerLoaded")
AddEventHandler(
  "__zm:playerLoaded",
  function()
    SetEntityCoords(
      PlayerPedId(),
      ZMan.Player.Data.last_location[1],
      ZMan.Player.Data.last_location[2],
      ZMan.Player.Data.last_location[3],
      false,
      false,
      false,
      false
    )
  end
)

Citizen.CreateThread(function()
  Utils.Logger.Debug(("Changing Player's ped to: %s"):format(pedModel))

  -- If Data still hasn't been loaded into memory, let's wait.
  while Utils.Misc.TableSize(ZMan.Player.Data) == 0 do
    Citizen.Wait(1)
  end
  
  RequestModel(pedModel)
  while not HasModelLoaded(pedModel) do
    RequestModel(pedModel)
    Citizen.Wait(1)
  end

  SetPlayerModel(PlayerId(), pedModel)
  SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)

  exports.spawnmanager:setAutoSpawn(false)

  local playerPos = ZMan.Player.Data.last_location

  exports.spawnmanager:spawnPlayer(
    {
      x = playerPos[1] or Config.SpawnLocation.x,
      y = playerPos[2] or Config.SpawnLocation.y,
      z = playerPos[3] or Config.SpawnLocation.z,
      heading = playerPos[4],
      skipFade = false
    }
  )

  SendNuiMessage(
    json.encode(
      {
        type = "ZMan/closeLoading"
      }
    )
  )
  Citizen.Wait(2000)
  ShutdownLoadingScreenNui()

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

RegisterNUICallback(
  "ui/close",
  function(data, cb)
    SetNuiFocus(false, false)
  end
)

RegisterCommand("tpc", function(source, args, raw)
  SetEntityCoords(PlayerPedId(), tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), true, true, true, false)
end)