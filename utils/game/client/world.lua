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