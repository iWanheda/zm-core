local bedCoords = vector3(154.443954, -1004.465942, -98.424927)
local isInBed, closestMotel = false, nil

Citizen.CreateThread(function()
  local waitMs = 1000

  for k, v in pairs(Config.Mods.Motels) do
    Utils.Game.DrawBlip({ Coords = v.outside, Sprite = 826, Color = 4, Label = "Motel" })
  end

  while true do
    Citizen.Wait(waitMs)

    local playerPos = GetEntityCoords(ZMan.Cache.Ped)

    for k, v in pairs(Config.Mods.Motels) do
      if #(playerPos - v.outside) < 1.5 and closestMotel == nil then
        waitMs = 1
        closestMotel = v
        break
      elseif closestMotel ~= nil and #(playerPos - closestMotel.outside) >= 1.5 then
        waitMs = 1000
        closestMotel = nil
      end
    end

    if closestMotel then
      DrawMarker(20, closestMotel.outside, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), vector3(0.5, 0.3, 0.3), 255, 255, 0,
        200, false, true, nil, false, nil, nil, false)

      Utils.Game.HelpText({ "Press ~INPUT_CONTEXT~ to enter to your Motel", true })
    end
  end
end)

local loopLayInBedScene, layBedScene, getOutBedScene, isCloseToBed = nil, nil, nil, false
local sCoord = bedCoords - vector3(0.1, 0.1, 1.2)
local sRot = vector3(0.0, 0.0, 180.0)

Utils.Game.Input.BindKey("E", "motelin", function()
  if not closestMotel then return end

  ZMan.Callback("modules:motels:getInMotel", nil, 1)
end)

Utils.Game.Input.BindKey("E", "sleep", function()
  if not isCloseToBed then return end

  if not isInBed then
    isInBed = true
    RequestAnimDict("anim@mp_bedmid@left_var_02")

    while not HasAnimDictLoaded("anim@mp_bedmid@left_var_02") do
      Citizen.Wait(1)
    end

    if not layBedScene then
      layBedScene = NetworkCreateSynchronisedScene(sCoord, sRot, 2, false, false, 1065353216, 0, 1065353216)
    end
    NetworkAddPedToSynchronisedScene(ZMan.Cache.Ped, layBedScene, "anim@mp_bedmid@left_var_02", "f_getin_l_bighouse", 1.5, -1.5, 13, 16, 1148846080, 0)
    NetworkStartSynchronisedScene(layBedScene)

    Citizen.Wait(8500)

    if not loopLayInBedScene then
      loopLayInBedScene = NetworkCreateSynchronisedScene(sCoord, sRot, 2, false, true, 1065353216, 0, 1065353216)
    end
    NetworkAddPedToSynchronisedScene(ZMan.Cache.Ped, loopLayInBedScene, "anim@mp_bedmid@left_var_02", "f_sleep_l_loop_bighouse", 1.5, -1.5, 13, 16, 1148846080, 0)
    NetworkStartSynchronisedScene(loopLayInBedScene)
  else
    NetworkStopSynchronisedScene(loopLayInBedScene)

    if not getOutBedScene then
      getOutBedScene = NetworkCreateSynchronisedScene(sCoord, sRot, 2, false, false, 1065353216, 0, 1065353216)
    end
    NetworkAddPedToSynchronisedScene(ZMan.Cache.Ped, getOutBedScene, "anim@mp_bedmid@left_var_02", "f_getout_l_bighouse", 1.5, -1.5, 13, 16, 1148846080, 0)
    NetworkStartSynchronisedScene(getOutBedScene)

    isInBed = false
    Citizen.Wait(5500)
  end
end)

Citizen.CreateThread(function()
  local waitMs = 200

  while true do
    Citizen.Wait(waitMs)

    local playerCoords = GetEntityCoords(ZMan.Cache.Ped)

    isCloseToBed = #(playerCoords - bedCoords) < 2.0
    if isCloseToBed then
      waitMs = 1
      Utils.Game.HelpText({ isInBed and "Press ~INPUT_CONTEXT~ to Wake Up" or "Press ~INPUT_CONTEXT~ to Sleep", true })
    else
      waitMs = 200
    end
  end
end)

local timeInBed = 0
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5000) -- 5 seconds

    if isInBed then
      timeInBed = timeInBed + 1

      local totalTime = timeInBed / 60

      if totalTime % 2 == 0 then
        SetEntityHealth(ZMan.Cache.Ped, 
          GetEntityHealth(ZMan.Cache.Ped) + 0.025 * GetEntityMaxHealth(ZMan.Cache.Ped))
      end
    end
  end
end)