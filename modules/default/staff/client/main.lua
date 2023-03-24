local mapperCam, isInStaff, isInMapper = nil, false, false

RegisterNetEvent("__zm:client:staff:update", function(staffMode)
  isInStaff = staffMode

  Citizen.CreateThread(function()
    while isInStaff do
      Citizen.Wait(1)

      if not isInMapper then
        Utils.Game.Misc.ShowInstructionalButtons({{ "~INPUT_MULTIPLAYER_INFO~", "Mapper" }, { "~INPUT_VEH_FLY_ATTACK_CAMERA~", "Admin Menu" }})
      end
    end
  end)
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