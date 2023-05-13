CreateNonPlayableCharacter = function(name, entityHash, customization, position, options)
  local callback = promise:new()

  Citizen.CreateThread(function()
    RequestModel(entityHash)

    while not HasModelLoaded(entityHash) do
      Citizen.Wait(1)
    end

    RequestAnimDict("mini@strip_club@idles@bouncer@base")
    while not HasAnimDictLoaded("mini@strip_club@idles@bouncer@base") do
      Wait(1)
    end

    local ped = CreatePed(10, entityHash, position, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskPlayAnim(ped, "mini@strip_club@idles@bouncer@base", "base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    
    callback:resolve(ped)
  end)

  return Citizen.Await(callback)
end

local npc = CreateNonPlayableCharacter("Mr. T", `a_m_m_business_01`, {}, 
  vector4(-410.663, 1168.6680, 325.8535 - 1.0, 0.0), {})

TriggerEvent("addEntityKek", npc, {{name = "rent_car", label = "Rent a Car"}})