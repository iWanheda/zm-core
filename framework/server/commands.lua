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