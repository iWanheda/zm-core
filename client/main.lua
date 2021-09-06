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

Citizen.CreateThread(
  function()
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
        x = playerPos[1],
        y = playerPos[2],
        z = playerPos[3],
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
  end
)

Citizen.CreateThread(
  function()
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
  end
)

RegisterNUICallback(
  "ui/close",
  function(data, cb)
    SetNuiFocus(false, false)
  end
)

function RayCastGameplayCamera(distance)
  local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()

  local adjustedRotation = 
	{ 
		x = math.pi / 180 * cameraRotation.x, 
		y = math.pi / 180 * cameraRotation.y, 
		z = math.pi / 180 * cameraRotation.z 
	}

	local direction =
  {
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}

	local destination = 
	{ 
		x = cameraCoord.x + direction.x * distance, 
		y = cameraCoord.y + direction.y * distance, 
		z = cameraCoord.z + direction.z * distance 
	}

	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 4))
	return b, c
end

local spellCast = nil

RegisterCommand("nigga", function() spellCast = not spellCast end, false)

Citizen.CreateThread(function()
  local waitMs = 800

	while true do
		Citizen.Wait(waitMs)

    if spellCast then -- If we're casting a spell
      waitMs = 3
      local hit, coords = RayCastGameplayCamera(40.0)

      if hit and coords ~= vector3(0.0, 0.0, 0.0) then
        DrawMarker(0, coords.x, coords.y, coords.z + 1.7, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 0.4, 0, 255, 0, 150, true, false, false, true, nil, nil, false)
        DrawMarker(27, coords.x, coords.y, coords.z + 0.05, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 0, 255, 0, 150, false, false, false, true, nil, nil, false)
      
        if IsControlJustReleased(0, 51) then
          ZMan.Player.ScreenFade(function()
            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z + 0.05, GetEntityHeading(PlayerPedId()), false)
            spellCast = nil
          end, 400)
        end
      end
    else
      waitMs = 800
    end
	end
end)

RegisterCommand("tpc", function(source, args, raw)
  SetEntityCoords(PlayerPedId(), tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), true, true, true, false)
end)

-- Put this into a new resource (zm-addons) ?
Citizen.CreateThread(function()
  local waitMs = 800

  while true do
    Citizen.Wait(waitMs)

    if #(GetEntityCoords(PlayerPedId()) - Config.DefaultHabitat) < 2.0 then
      waitMs = 3

      -- Change the design? Maybe a circle around the key and the rest in a rect or something ??
      Utils.Game.DrawWorldText(
      {
        Coords = Config.DefaultHabitat,
        Text = "~g~E~w~ - Exit Apartment" --L("_EXIT_APARTMENT")
      })
    else
      waitMs = 800
    end
  end
end)