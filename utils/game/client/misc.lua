Utils.Game.Misc = {
  ScreenFade = function(cb, time)
    DoScreenFadeOut(time)

    while not IsScreenFadedOut() do
      Citizen.Wait(1)
    end

    cb()

    DoScreenFadeIn(time)
  end,

  ClosestVehicle = function(ped, dist)
    local vehicleTable, closestVeh, pedCoords = GetAllVehicles(), 999999, GetEntityCoords(ped)

    for k, v in pairs(vehicleTable) do
      local vehDist = GetEntityCoords(v)

      if #(vehDist - pedCoords) < closestVeh then
        closestVeh = v
      end
    end

    return closestVeh
  end
}