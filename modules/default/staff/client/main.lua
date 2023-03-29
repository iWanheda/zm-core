local mapperCam, isInStaff, isInMapper, specTarget, specCoords = nil, false, false, nil, nil

-- TODO: Add player to gamerTags everytime it goes into scope and remove it otherwise
local gamerTags = { }
RegisterNetEvent("__zm:client:staff:update", function(staffMode)
  isInStaff = staffMode

  if isInStaff == true then
    for _, player in pairs(GetActivePlayers()) do
      local ped = GetPlayerPed(player)
      local tag = CreateFakeMpGamerTag(ped, GetPlayerName(player), false, false, "", 0)
  
      table.insert(gamerTags, tag)
    end
    
    Citizen.CreateThread(function()
      while isInStaff do
        Citizen.Wait(1)
  
        if not isInMapper then
          Utils.Game.Misc.ShowInstructionalButtons({{ "~INPUT_MULTIPLAYER_INFO~", "Mapper" }, { "~INPUT_VEH_FLY_ATTACK_CAMERA~", "Admin Menu" }})
        end
      end
  
      for k, v in pairs(gamerTags) do
        RemoveMpGamerTag(v)
      end
    end)
  end
end)

RegisterCommand(
  "mapper",
  function(source, args)
    if not isInStaff then return end

    local playerPed = ZMan.Cache.Ped
    
    if isInMapper then
      SetCamActive(mapperCam, false)
      RenderScriptCams(false)

      SetEntityCollision(playerPed, true, true)
      SetEntityVisible(playerPed, true)

      local camCoords = GetCamCoord(mapperCam)
      SetEntityCoords(playerPed, camCoords.x, camCoords.y, camCoords.z + 0.1)

      local camRot = GetCamRot(mapperCam)
      SetGameplayCamRelativeRotation(camRot)
    else
      -- Create camera if it doesn't exist already
      if not DoesCamExist(mapperCam) then
        mapperCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
      end

      -- Set camera as active (use it to navigate)
      SetCamActive(mapperCam, true)
      RenderScriptCams(true, false, 0, true, true)

      local coords = GetEntityCoords(playerPed)
      SetCamCoord(mapperCam, coords)

      local originalCamRot = GetGameplayCamRot(0)
      SetCamRot(mapperCam, originalCamRot)

      -- Disable collisions with player and make it invisible
      SetEntityCollision(playerPed, false, false)
      SetEntityVisible(playerPed, false)

      -- Our thread to handle camera movement
      Citizen.CreateThread(function()
        while isInMapper do
          Citizen.Wait(1)

          local camCoords, speedMultiplier = GetCamCoord(mapperCam), 1
	        local right, forward, up, at = GetCamMatrix(mapperCam)

          SetEntityCoords(playerPed, camCoords)

          if IsControlPressed(0, 21) then -- LSHIFT
            speedMultiplier = 5
          elseif IsControlPressed(0, 19) then -- LALT
            speedMultiplier = 0.3
          else
            speedMultiplier = 1
          end

          local wishDir = vector3(0, 0, 0)

          if IsControlPressed(0, 32) then -- W
            wishDir = forward * speedMultiplier
          elseif IsControlPressed(0, 33) then -- S
            wishDir = forward * -speedMultiplier
          elseif IsControlPressed(0, 34) then -- A
            wishDir = right * -speedMultiplier
          elseif IsControlPressed(0, 35) then -- D
            wishDir = right * speedMultiplier
          end

          SetCamCoord(mapperCam, camCoords + wishDir)

          local xMagnitude = GetDisabledControlNormal(0, 1);
	        local yMagnitude = GetDisabledControlNormal(0, 2);
	        local camRot = GetCamRot(mapperCam)

	        local x = camRot.x - yMagnitude * 10
	        local y = camRot.y
	        local z = camRot.z - xMagnitude * 10

          x = math.clamp(x, -75.0, 100.0)
        
	        SetCamRot(mapperCam, x, y, z)

          Utils.Game.Misc.ShowInstructionalButtons({{ "~INPUT_SPRINT~", "Go Faster" }, { "~INPUT_CHARACTER_WHEEL~", "Go Slower" }})
        end
      end)
    end

    isInMapper = not isInMapper
  end
)

Utils.Game.Input.BindKey("X", "quitspec", function()
  if specTarget ~= nil then
    QuitSpectatorMode()
  end
end)

local targetCamera = CreateCam(`DEFAULT_SCRIPTED_CAMERA`, true)
RegisterCommand("spectate", function(source, args)
  if not isInStaff then return end

  local targetId = tonumber(args[1])

  if targetId then
    StartSpectatorMode(targetId)
  end
end)

StartSpectatorMode = function(targetId)
  local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
  if ZMan.Cache.Ped == targetPed then return end

  specCoords = GetEntityCoords(ZMan.Cache.Ped)

  --SetEntityCollision(ZMan.Cache.Ped, false, false)
  --SetEntityVisible(ZMan.Cache.Ped, false)

  Citizen.CreateThread(function()
    while specTarget == targetId do
      Citizen.Wait(1)

      --local targetCoords = GetEntityCoords(targetPed)
      --SetEntityCoords(ZMan.Cache.Ped, targetCoords)
      SetGameplayCamFollowPedThisUpdate(targetPed)
      Utils.Game.Misc.ShowInstructionalButtons({{ "~INPUT_VEH_DUCK~", "Quit Spectating" }})
    end
  end)

  specTarget = targetId
end

QuitSpectatorMode = function()
  specTarget = nil

  SetCamActive(targetCamera, false)
  DestroyCam(targetCamera, false)
  RenderScriptCams(false, true, 200, false, false)

  SetEntityCollision(ZMan.Cache.Ped, true, true)
  SetEntityVisible(ZMan.Cache.Ped, true)

  SetEntityCoords(ZMan.Cache.Ped, specCoords)
  specCoords = nil
end