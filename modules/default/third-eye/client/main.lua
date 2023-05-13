local thirdEyeEnabled = false
local validEntities = { }

Citizen.CreateThread(function()
  while not HasStreamedTextureDictLoaded("shared") do RequestStreamedTextureDict("shared", false) Wait(1) end
end)

RegisterCommand('+thirdeye', function()
  if thirdEyeEnabled then return end

  RunThirdEye()
  SendReactMessage("third", { show = true }, false)
end, false)

RegisterCommand('-thirdeye', function()
  thirdEyeEnabled = false

  SendReactMessage("third", { show = false }, false)
end, false)

RegisterKeyMapping('+thirdeye', '', 'keyboard', 'lmenu')

local closePoints = { }
local isDrawing = false

local pe = { vector3(0.0, 0.0, 71.0) }

RunDrawPoints = function()
  if not isDrawing then
    local width = 0.01
    local height = width * GetAspectRatio()

    Citizen.CreateThread(function()
      while thirdEyeEnabled do
        Citizen.Wait(1)

        for k, v in pairs(closePoints) do
          SetDrawOrigin(v)
          DrawSprite("shared", "emptydot_32", 0, 0, width, height, 0, 255, 255, 255, 255)
        end
      end

      isDrawing = false
    end)

    isDrawing = true
  end
end

RunThirdEye = function()
  thirdEyeEnabled = true

  local isAimingAtPoint, showingOptions = false, false
  Citizen.CreateThread(function()
    while thirdEyeEnabled do
      Citizen.Wait(1)
      local playerCoords = GetEntityCoords(ZMan.Cache.Ped)
  
      local hit, entityHit, endCoords = Utils.Game.Misc.RaycastFromCamera(511)

      if hit == 1 then
        if showingOptions then break end

        if IsEntityAPed(entityHit) and validEntities[entityHit] ~= nil then
          if not isAimingAtPoint then
            isAimingAtPoint = true
            SendReactMessage("third", { show = true, isAimingAtPoint = true }, false)
          end

          if IsControlPressed(0, 51) and not showingOptions then
            showingOptions = true
            SendReactMessage("third", { show = true, isAimingAtPoint = false, options = validEntities[entityHit].options }, true)
          end
        end
      else
        isAimingAtPoint = false
        showingOptions = false
        SendReactMessage("third", { show = true, isAimingAtPoint = false }, false)
      end
    end

    SendReactMessage("third", { show = false }, false)
  end)
end

RegisterNetEvent("addEntityKek", function(entityId, options)
  if not entityId or not options then return end

  Utils.Logger.Debug(("Adding ~green~'%s'~white~ as a valid third eye entity with options: ~green~%s"):format(entityId, json.encode(options)))

  validEntities[entityId] = { options = options }
end)

ZMan.Mods.ThirdEye = { }
ZMan.Mods.ThirdEye.AddEntity = function(entityId, options)
  if not entityId or not options then return end

  Utils.Logger.Debug(("Adding '%s' as a valid third eye entity with options: %s"):format(entityId, json.encode(options)))

  validEntities[entityId] = { options = options }
end