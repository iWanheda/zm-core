local coordsBackup = nil

RegisterCommand(
  "tpm",
  function(source, args)
    local waypointHandle = GetFirstBlipInfoId(8)

    if DoesBlipExist(waypointHandle) then
      local waypointCoords = GetBlipInfoIdCoord(waypointHandle)
      coordsBackup = GetEntityCoords(PlayerPedId())

      for height = 1, 1000 do
        SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, height + 0.0)

        local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, height + 0.0)

        if foundGround then
          SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.x, height + 0.0)
          break
        end

        Citizen.Wait(5)
      end
    end
  end
)

RegisterCommand(
  "back",
  function(source, args)
    if coordsBackup ~= nil then
      SetPedCoordsKeepVehicle(
        PlayerPedId(),
        coordsBackup.x,
        coordsBackup.y,
        coordsBackup.z + 0.7,
        false,
        false,
        false,
        false
      )
    end

    coordsBackup = nil
  end
)
