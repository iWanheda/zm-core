Utils.Game =
{
  DrawBlip = function(data)
    local mapBlip = AddBlipForCoord(data.Coords.x, data.Coords.y, data.Coords.z)

    SetBlipSprite(mapBlip, data.Sprite)
    SetBlipDisplay(mapBlip, 4)

    SetBlipScale(mapBlip, data.Scale or 0.8)
    SetBlipColour(mapBlip, data.Color)

    SetBlipAsShortRange(mapBlip, data.ShortRange or true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(data.Label)
    EndTextCommandSetBlipName(mapBlip)
  end,

  -- Thanks to whoever released this on the forums years ago.
  -- I just tweaked it a little bit to improve performance :]
  DrawWorldText = function(data)
    SetTextScale(data.Scale or 0.35, data.Scale or 0.35)
    SetTextFont(data.Font or 4)
    SetTextColour((data.Color and data.Color[1]) or 255, (data.Color and data.Color[2]) or 255, (data.Color and data.Color[3]) or 255, (data.Color and data.Color[4]) or 255)
    SetTextDropshadow(1, 1, 1, 1, (data.Color and data.Color[4]) or 255)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(data.Align or true)
    AddTextComponentSubstringPlayerName(data.Text or "")
    SetDrawOrigin(data.Coords.x, data.Coords.y, data.Coords.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)

    if data.Scale == nil then
      DrawRect(0.0, 0.0 + 0.0125, 0.009 + (string.len(data.Text)) / 370, 0.03, 0, 0, 0, (data.Color and data.Color[4]) or 75)
    end

    ClearDrawOrigin()
  end,

  HelpText = function(data)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(data[1])
    EndTextCommandDisplayHelp(0, false, data[2], -1) -- beep -> boolean
  end,

  SpawnVehicle = function(hash, pos, cb)
    if not IsModelInCdimage(hash) then return end
    
    RequestModel(hash)
  
    while not HasModelLoaded(hash) do
      Citizen.Wait(1)
    end
  
    local vehicle = CreateVehicle(hash, pos, nil, true, false)
    SetModelAsNoLongerNeeded(hash)
  
    cb(vehicle)
  end,

  RayCastGameplayCamera = function(distance)
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
  
    local rayShape = StartExpensiveSynchronousShapeTestLosProbe(
      cameraCoord.x, cameraCoord.y, cameraCoord.z,
      destination.x, destination.y, destination.z,
      1 | 2 | 16, 0, 4
    )
  
    local a, b, c, d, e = GetShapeTestResult(rayShape)
  
    if e then
      et = GetEntityType(e)
    end
  
    return b, c, e
  end
}