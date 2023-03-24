ZMan.RegisterCommand(
  "coords",
  function(source)
    print(("%s => %s"):format(GetEntityCoords(GetPlayerPed(source)), GetEntityHeading(GetPlayerPed(source))))
    Utils.Logger.Info(("%s => %s"):format(GetEntityCoords(GetPlayerPed(source)), GetEntityHeading(GetPlayerPed(source))))
  end, false
)

ZMan.RegisterCommand(
  "info",
  function(source, args)
    local Player = ZMan.Get(source)

    print(("Job: %s | Grade: %s | Group: %s | Identity: %s %s | Citizen ID: %s"):format(
      Player:GetJob(), Player:GetJobGrade(), Player:GetGroup(), Player:GetName().first, Player:GetName().last, Player:GetCitizenId()
    ))

    Player:Callback("test", function(success) print(tostring(success)) end, 213, "np")
  end, false
)

ZMan.RegisterCommand(
  "setgroup",
  function(source, args)
    local targetSource, targetGroup = tonumber(args[1]), args[2]

    if type(targetSource) == "number" then
      local Target = ZMan.Get(targetSource)

      if Target and targetGroup then
        if Config.Groups[targetGroup] ~= nil then
          Target:SetGroup(targetGroup)
        end
      end
    end
  end, true, { "admin" }
)

ZMan.RegisterCommand(
  "showinv",
  function(source, args)
    local Player = ZMan.Get(source)

    print(json.encode(Player:GetInventory()))
  end, false
)

ZMan.RegisterCommand(
  "removeitem",
  function(source, args)
    local Player = ZMan.Get(source)

    Player:RemoveItem(args[1], 1)
  end, false
)

ZMan.RegisterCommand(
  "giveitem",
  function(source, args)
    local Player, itemName, itemQuant = ZMan.Get(source), args[1], args[2]

    if itemName ~= nil and itemQuant ~= nil then
      Player:AddItem(itemName, itemQuant)
    else
      Utils.Logger.Error(("%s tried to give themselves an item with wrong attributes. (Item Name: ~green~%s~white~, Item Quantity: ~green~%s~white~)")
        :format(Player:GetBaseName(), itemName or "Undefined", itemQuant or "Undefined")
      )
    end
  end, false, nil, {helpText="Roof!", {name="paramName1", desc="param description 1"},
  {name="paramName1", desc="param description 2"}}
)

ZMan.RegisterCommand(
  "revive",
  function(source, args)
    local Player = ZMan.Get(source)

    Player:TriggerEvent("__zm:revivePlayer", 200)
  end, false
)