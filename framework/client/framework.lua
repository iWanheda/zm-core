ZMan = { }

-- So that we can store local player's ped in a variable and avoid
--  calling it multiple times
local _playerPedId = PlayerPedId()
ZMan.Ped = _playerPedId

ZMan.Player = { }
ZMan.Player.Data = { }

-- Local Player

ZMan.Player.UpdateData = function(key, value)
  ZMan.Player.Data[tostring(key)] = json.decode(value)
end

ZMan.Player.Teleport = function(pos)
  DoScreenFadeIn(800)

  SetEntityCoords(
    PlayerPedId(),
    pos.x, pos.y, pos.z,
    true, true, false, false
  )
end

ZMan.Player.ShowNotification = function(type, cap, message, time)
  if type == "info" then
    exports.swt_notifications:Info(cap or "", message or "", "top", time or 2500, true)
  elseif type == "success" then
    exports.swt_notifications:Success(cap or "", message or "", "top", time or 2500, true)
  elseif type == "warn" then
    exports.swt_notifications:Warning(cap or "", message or "", "top", time or 2500, true)
  elseif type == "error" then
    exports.swt_notifications:Negative(cap or "", message or "", "top", time or 2500, true)
  end
end

ZMan.Player.ScreenFade = function(cb, time)
  DoScreenFadeOut(time)

  while not IsScreenFadedOut() do
    Citizen.Wait(1)
  end

  cb()

  DoScreenFadeIn(time)
end

RegisterNetEvent("__zm:sendNotification")
AddEventHandler(
  "__zm:sendNotification",
  function(data)
    ZMan.Player.ShowNotification(data.t, data.c, data.m, data.ti)
  end
)

RegisterNetEvent("__zm:updatePlayerData")
AddEventHandler(
  "__zm:updatePlayerData",
  function(data)
    for k, v in pairs(data) do
      Utils.Logger.Debug(("Updating ~green~%s => %s"):format(k, v))

      ZMan.Player.UpdateData(k, v)
    end
  end
)

RegisterNetEvent("__zm:revivePlayer")
AddEventHandler(
  "__zm:revivePlayer",
  function(health)
    SetEntityHealth(PlayerPedId(), health or GetEntityMaxHealth(PlayerPedId()))
    ClearPedBloodDamage(PlayerPedId())

    local playerPos, h = GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId())

    NetworkResurrectLocalPlayer(playerPos.x, playerPos.y, playerPos.z, h, false, false)
  end
)