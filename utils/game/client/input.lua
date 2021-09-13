Utils.Game.Input =
{
  Keys =
  {
    A = 34,
    B = 29,
    C = 26,
    D = 30,
    E = 51,
    F = 23,
    G = 47,
    H = 74,
    I = 00,
    J = 00,
    K = 311
  },

  Binds = { },

  BindKey = function(key, command, fn, desc, inputtype)
    Utils.Game.Input.Binds[command] = fn

    RegisterCommand(
      ("%s"):format(command),
      function()
        fn()
      end,
      false
    )

    RegisterKeyMapping(("%s"):format(command), desc or "", inputtype or "keyboard", key)
  end,

  GetBindFn = function(command)
    return Utils.Game.Input.Binds[command]
  end
}