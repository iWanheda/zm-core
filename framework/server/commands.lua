ZMan.RegisterCommand(
  "coords",
  function(source)
    print(GetEntityCoords(GetPlayerPed(source)))
  end, false, { "admin" }
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

      if Target then
        if targetGroup then
          Target:SetGroup(targetGroup)
        end
      end
    end
  end, true
)