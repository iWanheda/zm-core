ZMan.RegisterCommand(
  "coords",
  function(source)
    Utils.Logger.Info(("%s => %s"):format(GetEntityCoords(GetPlayerPed(source)), GetEntityHeading(GetPlayerPed(source))))
  end, false
)

ZMan.RegisterCommand(
  "admin",
  function(source)
    -- Trigger UI for admin menu
  end, false, { "admin" }
)

ZMan.RegisterCommand(
  "info",
  function(source, args)
    local Player = ZMan.Get(source)

    print(("Job: %s | Grade: %s | Group: %s | Identity: %s %s"):format(
      Player.GetJob(), Player.GetJobGrade(), Player.GetGroup(), Player.GetName().first, Player.GetName().last
    ))
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

    print(json.encode(Player.GetInventory()))
  end, false
)

ZMan.RegisterCommand(
  "additem",
  function(source, args)
    local Player = ZMan.Get(source)

    Player.AddItem(args[1], args[2])
  end, false
)

ZMan.RegisterCommand(
  "removeitem",
  function(source, args)
    local Player = ZMan.Get(source)

    Player.RemoveItem(args[1], 1)
  end, false
)