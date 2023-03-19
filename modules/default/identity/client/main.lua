local identityGender = nil
local maleModel = `mp_m_freemode_01`
local femaleModel = `mp_f_freemode_01`

RegisterNetEvent("__zm:client:modules:indentity:register")
AddEventHandler("__zm:client:modules:indentity:register", function()
  local bedCoords = vector3(154.443954, -1004.465942, -98.424927)
  local sCoord, sRot = bedCoords - vector3(0.1, 0.1, 1.2), vector3(0.0, 0.0, 180.0)

  DoScreenFadeOut(0)

  RequestAnimDict("anim@mp_bedmid@left_var_02")
  while not HasAnimDictLoaded("anim@mp_bedmid@left_var_02") do
    Citizen.Wait(1)
  end

  local loopLayInBedScene = NetworkCreateSynchronisedScene(sCoord, sRot, 2, false, true, 1065353216, 0, 1065353216)
	NetworkAddPedToSynchronisedScene(PlayerPedId(), loopLayInBedScene, "anim@mp_bedmid@left_var_02", "f_sleep_l_loop_bighouse", 1.5, -1, 13, 16, 1148846080, 0)

  Citizen.Wait(500)
  DoScreenFadeIn(1000)
  TriggerScreenblurFadeIn()

  SendReactMessage("identity", { show = true }, true)

  local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
  SetCamCoord(cam, 153.6131, -1005.8809, -99.445)
  SetCamRot(cam, 15.0, 0.0, 00.0)
  SetCamFov(cam, 90.0)
  RenderScriptCams(true, false, 0, 1, 0)
  SetCamActive(cam, true)

  NetworkStartSynchronisedScene(loopLayInBedScene)

  --while not IsScreenFadedOut() do Citizen.Wait(1) end
  while not identityGender do Citizen.Wait(1) end

  if identityGender == "male" then
    RequestModel(maleModel)
    while not HasModelLoaded(maleModel) do
      Citizen.Wait(1)
    end
  
    SetPlayerModel(PlayerId(), maleModel)
  elseif identityGender == "female" then
    RequestModel(femaleModel)
    while not HasModelLoaded(femaleModel) do
      Citizen.Wait(1)
    end
  
    SetPlayerModel(PlayerId(), femaleModel)
  end

  SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
  
  DisableAllControlActions(0)

  local getOutBedScene = NetworkCreateSynchronisedScene(sCoord, sRot, 2, false, false, 1065353216, 0, 1065353216)
  NetworkAddPedToSynchronisedScene(PlayerPedId(), getOutBedScene, "anim@mp_bedmid@left_var_02", "f_getout_l_bighouse", 0, -1.5, 13, 16, 1148846080, 0)

  NetworkStopSynchronisedScene(loopLayInBedScene)
  Citizen.Wait(1000)
  NetworkStartSynchronisedScene(getOutBedScene)
  DoScreenFadeIn(4200)

  while not IsScreenFadedIn() do Citizen.Wait(1) end

  Citizen.Wait(600)
  NetworkStopSynchronisedScene(getOutBedScene)
  ShowCharCreation()
  
  local data = { first = "Fernando", last = "Peidolas", dob = 975456000000 }
  TriggerServerEvent("__zm:server:modules:indentity:data", data)
end)

-- I PINUS I GOOD
RegisterReactCallback("identityGender", function(data)
  if data and data == "male" or data == "female" then
    DoScreenFadeOut(1000)

    while not IsScreenFadedOut() do
      Citizen.Wait(1)
    end

    identityGender = data
    Citizen.Wait(500)
    
    RenderScriptCams(false, false, 0, false, false)
    TriggerScreenblurFadeOut(0)
    SendReactMessage("identity", { show = false }, false)

    Citizen.Wait(500)
    DoScreenFadeIn(3000)
  end
end)

ShowCharCreation = function()

end