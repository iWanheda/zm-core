Utils.Game.SpawnVehicle = function(hash, pos, cb)
  if not IsModelInCdimage(hash) then return end
  
  RequestModel(hash)

  while not HasModelLoaded(hash) do
    Citizen.Wait(1)
  end

  local vehicle = CreateVehicle(hash, pos, nil, true, false)
  SetModelAsNoLongerNeeded(hash)

  cb(vehicle)
end

Utils.Game.RayCastGameplayCamera = function(distance)
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

  local rayShape = StartShapeTestRay(
    cameraCoord.x, cameraCoord.y, cameraCoord.z,
    destination.x, destination.y, destination.z,
    1 | 2 | 16, 0, 4
  )

  local a, b, c, d, e = GetShapeTestResult(rayShape)

  return b, c, e
end