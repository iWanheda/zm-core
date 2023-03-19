ZMan = { }

ZMan.Callbacks = { }
ZMan.RegisteredCallbacks = { }

-- So that we can store local player's ped in a variable and avoid
--  calling it multiple times
ZMan.Cache = { }
ZMan.Cache.Ped = nil

ZMan.Player = { }
ZMan.Player.Data = { }
ZMan.Items = Config.Items

-- Local Player

ZMan.Player.UpdateData = function(key, value)
  ZMan.Player.Data[tostring(key)] = json.decode(value)
end

ZMan.Player.GetData = function(key)
  if ZMan.Player.Data[tostring(key)] ~= nil then
    return ZMan.Player.Data[tostring(key)]
  end
end

ZMan.Player.Position = function()
  return GetEntityCoords(PlayerPedId())
end

ZMan.Player.Teleport = function(pos, delay)
  Utils.Game.Misc.ScreenFade(function()
    SetEntityCoords(
      PlayerPedId(),
      pos.x, pos.y, pos.z - 0.3,
      true, true, false, false
    )
  end, delay or 800)
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

-- So the server can call this

RegisterNetEvent("__zm:teleportPlayer", function(coords, delay)
  ZMan.Player.Teleport(coords, delay)
end)

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

    NetworkResurrectLocalPlayer(playerPos, h, false, false)
  end
)

-- Callback Handler
ZMan.CallbackID = 0

-- Server callback only
ZMan.Callback = function(name, cb, ...)
  ZMan.Callbacks[ZMan.CallbackID] = cb
  TriggerServerEvent("__zm:server:callback:trigger", name, ZMan.CallbackID, ...)

  ZMan.CallbackID = ZMan.CallbackID + 1
end

RegisterNetEvent("__zm:client:callback:return")
AddEventHandler("__zm:client:callback:return", function(id, ...)
  if ZMan.Callbacks[id] ~= nil then
	  ZMan.Callbacks[id](...)
	  ZMan.Callbacks[id] = nil
  end
end)

-- Modules

RegisterNetEvent("__zm:client:modules:load", function(mods)
  local resName = GetCurrentResourceName()
  for _, mod in pairs(mods) do
    for _, sharedModule in pairs(mod.sharedMods) do
      local sharedContent = LoadResourceFile(resName, 
        ("modules/%s/%s/shared/%s"):format(mod.hierarchy, mod.name, sharedModule))
  
      local sharedCode, sharedErr = load(sharedContent ~= nil and sharedContent or "")
  
      if sharedErr then
        Utils.Logger.Error(
          ("An ~red~exception~white~ was thrown while loading ~red~%s/shared/%s~white~, stack trace: ~yellow~\n\t-> %s")
          :format(env.name, sharedModule, sharedErr)
        )
        
        goto continue
      end
  
      pcall(sharedCode)
    end

    for _, clientModule in pairs(mod.clientMods) do
      local clientContent = LoadResourceFile(resName, 
        ("modules/%s/%s/client/%s"):format(mod.hierarchy, mod.name, clientModule))
  
      local clientCode, clientErr = load(clientContent ~= nil and clientContent or "")
  
      if clientErr then
        Utils.Logger.Error(
          ("An ~red~exception~white~ was thrown while loading ~red~%s/client/%s~white~, stack trace: ~yellow~\n\t-> %s")
          :format(env.name, clientModule, clientErr)
        )
        
        goto continue
      end
  
      pcall(clientCode)
    end
  end

  ::continue::
end)

--ZMan.Menu.Create = function(title, data, cb)
--  local menu = CMenu.Create(title)
--  
--  if menu then
--    return menu
--  end
--end

--local Menu = ZMan.Menu.Create("Example", menuData, function(opt)
--  if s.option == 1 then
--    print(1)
--  end
--end, true)

local dropTable = { }

RegisterNetEvent("__zm:internal:drop:create")
AddEventHandler("__zm:internal:drop:create", function(props)
  Citizen.CreateThread(function()
    -- To test
    local drop = table.insert(dropTable, props)

    Citizen.Wait(Config.DropRemoval * 1000)
    table.remove(dropTable, drop)
  end)
end)

--Citizen.CreateThread(function()
--  local waitMs = 500
--
--  while true do
--    Citizen.Wait(waitMs)
--    local playerPos = ZMan.Player.Position()
--
--    -- Check if we're near any drops
--    for k, v in pairs(dropTable) do
--      local dropCoords = vector3(v.position.x, v.position.y, v.position.z - 0.98)
--
--      if #(playerPos - dropCoords) < 10.0 then
--        local markerAlpha = math.floor(-50.1 * (#(playerPos - dropCoords)) + 255)
--        waitMs = 0
--
--        DrawMarker(
--          25, dropCoords,
--          0.0, 0.0, 0.0,
--          0.0, 0.0, 0.0,
--          0.2, 0.2, 0.2,
--          255, 180, 0, markerAlpha >= 0 and markerAlpha or 0,
--          false, false, false, false, nil, nil, false
--        )
--        DrawMarker(
--          25, dropCoords,
--          0.0, 0.0, 0.0,
--          0.0, 0.0, 0.0,
--          0.3, 0.3, 0.3,
--          110, 0, 255, markerAlpha >= 0 and markerAlpha or 0,
--          false, false, false, false, nil, nil, false
--        )
--      else
--        waitMs = 500
--      end
--    end
--  end
--end)