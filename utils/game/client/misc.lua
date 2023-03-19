local scaleForm = nil

Utils.Game.Misc =
{
  ScreenFade = function(cb, time)
    DoScreenFadeOut(time)

    while not IsScreenFadedOut() do
      Citizen.Wait(1)
    end

    cb()
    
    Citizen.Wait(1700)
    DoScreenFadeIn(time)
  end,

  ClosestVehicle = function(ped, dist)
    local vehicleTable, closestVeh, pedCoords = GetAllVehicles(), 99999999, GetEntityCoords(ped)

    for k, v in pairs(vehicleTable) do
      local vehDist = GetEntityCoords(v)

      if #(vehDist - pedCoords) < closestVeh then
        closestVeh = v
      end
    end

    return closestVeh
  end,

  -- This needs to be called in a Loop!
  ShowInstructionalButtons = function(buttons)
    if type(buttons) ~= "table" then return end

    if scaleForm == nil then
      scaleForm = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")

      while not HasScaleformMovieLoaded(scaleForm) do
        Citizen.Wait(0)
      end
    
      DrawScaleformMovieFullscreen(scaleForm, 255, 255, 255, 0, 0)
    end
  
    if IsHudHidden() then return end
  
    BeginScaleformMovieMethod(scaleForm, "CLEAR_ALL")
    EndScaleformMovieMethod()

    for i = 1, #buttons do
      local element = buttons[i]

      BeginScaleformMovieMethod(scaleForm, "SET_DATA_SLOT")
      ScaleformMovieMethodAddParamInt(#buttons - i)
      PushScaleformMovieMethodParameterString(element[1])
      PushScaleformMovieMethodParameterString(element[2])
      EndScaleformMovieMethod()
    end
    
    BeginScaleformMovieMethod(scaleForm, "DRAW_INSTRUCTIONAL_BUTTONS")
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()

    DrawScaleformMovieFullscreen(scaleForm, 255, 255, 255, 255, 0)
  end
}