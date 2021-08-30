Utils.Game =
{
  DrawBlip = function(data)
    local mapBlip = AddBlipForCoord(data.Coords.x, data.Coords.y, data.Coords.z)

    SetBlipSprite(mapBlip, data.Sprite)
    SetBlipDisplay(mapBlip, 4)

    SetBlipScale(mapBlip, data.Scale)
    SetBlipColour(mapBlip, data.Color)

    SetBlipAsShortRange(mapBlip, data.ShortRange)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.Label)
    EndTextCommandSetBlipName(mapBlip)
  end,

  -- Thanks to whoever released this on the forums years ago.
  DrawWorldText = function(data)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(pX, pY, pZ, data.Coords.x, data.Coords.y, data.Coords.z, 1)
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = ((1 / dist) * 20) * fov

    SetTextScale(0.1 * scale, 0.1 * scale)
    SetTextFont(data.Font or 1)
    SetTextProportional(1)
    SetTextColour(data.Color[1] or 255, data.Color[2] or 255, data.Color[3] or 255, data.Color[4] or 255)
    SetTextDropshadow(1, 1, 1, 1, data.Color[4] or 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(data.Text or "")
    SetDrawOrigin(data.Coords.x, data.Coords.y, data.Coords.z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
  end,

  HelpText = function(data)
    SetTextComponentFormat("STRING")
    AddTextComponentString(data.text)
    DisplayHelpTextFromStringLabel(0, 0, data.beep, -1)
  end
}
