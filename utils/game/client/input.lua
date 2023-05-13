Utils.Game.Input =
{
  Binds = { },

  -- TODO: Implement the supported hold system instead of only toggle :)
  BindKey = function(key, command, fn, desc, inputtype)
    Utils.Game.Input.Binds[command] = fn

    RegisterCommand(
      ("~%s"):format(command),
      function()
        fn()
      end,
      false
    )

    RegisterKeyMapping(("%s"):format(("~%s"):format(command)), desc or "", inputtype or "keyboard", key)
  end,

  GetBindFn = function(command)
    return Utils.Game.Input.Binds[command]
  end
}