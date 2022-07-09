local MySQLInit = false

MySQL.ready(
  function()
    MySQLInit = true
  end
)

Utils.Logger.Info("ZimaN Framework, developed with ❤️")
Utils.Logger.Debug("❗ Debug mode is active! This will spam a lot in your server/client's console.")

Citizen.CreateThread(
  function()
    if Config.Queue and GetResourceState("hardcap") == "started" then
      StopResource("hardcap")
    end

    while not MySQLInit do
      Citizen.Wait(1)
    end
    
    for k, v in pairs(Config.Items) do
      ZMan.AddItem(k, { label = v.label, weight = v.weight, exclusive = v.exclusive })
    end
  end
)

RegisterNetEvent("__zm:test")
AddEventHandler(
  "__zm:test",
  function()
    local Player = ZMan.Get(source)

    print(Utils.Misc.DumpTable(Player))
  end
)

if Config.SpawnPeds == false then
  -- todo: onesync_population false ?
  AddEventHandler(
    "populationPedCreating",
    function()
      CancelEvent()
    end
  )
end

RegisterNetEvent("__zm:getLibrary")
AddEventHandler(
  "__zm:getLibrary",
  function(cb)
    ZMan.Utils = Utils
    ZMan.CPlayer = CPlayer

    cb(ZMan)
  end
)

local tempPlayers = { }

AddEventHandler("playerConnecting", function(name, kickReason, def)
  local source = source
  local identifier, identifiers = nil, GetPlayerIdentifiers(source)

  def.defer()
  Wait(0)

  for _, v in pairs(identifiers) do
    if string.find(v, Config.Identifier or "license") then
      identifier = v:sub(9)
      break
    end
  end

  if not identifier then
    def.done((
      "There was an error getting your identifier (%s), please report this to the system administrator."
    ):format(Config.Identifier))
  end

  def.update(("Checking %s's status..."):format(name))

  MySQL.Async.fetchAll(
    "SELECT * FROM users WHERE identifier = @id",
    {
      ["@id"] = identifier
    },
    function(res)
      Utils.Logger.Info(("~green~%s~white~ is connecting to the server."):format(name))
      if res and res[1] ~= nil then
        if res[1].banned ~= false then
          def.done(("You have been banned from this server! (%s)"):format(name))
          return
        end
      else
        MySQL.Async.execute(
          "INSERT INTO users VALUES(@id, @group, false)",
          {
            ["@id"] = identifier,
            ["@group"] = Config.DefaultGroup,
          },
          function()
            Utils.Logger.Debug(("Added ~green~%s~white~ to the database!"):format(name), true)
          end
        )
      end
      tempPlayers[source] = identifier
      def.done()
    end
  )
end)

AddEventHandler(
  "playerDropped",
  function(reason)
    local Player = ZMan.Get(source)

    if Player then
      Player.SavePlayer()
      ZMan.Destroy(source)
    end
  end
)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(Config.AutoSaveTime * 60000)
    
    for k, v in pairs(ZMan.GetPlayers()) do
      -- Asynchronous
      Citizen.CreateThread(function()
        ZMan.Get(k):SavePlayer()
      end)
    end
  end
end)

-- TODO: REMOVE CHOICE OF MULTI CHARACTER, IT'S FORCED TO BE TRUE!
-- FIX: Remove all this shit changes and apply the multi character system! :]

-- This also prevents the table from getting empty upon a script restart

-- TODO: UpdatePlayer everytime we instantiate a new Player, fix some bugs and improve this overall!
RegisterNetEvent("__zm:joined")
AddEventHandler("__zm:joined", function()
  -- Because we reload the script a lot of times :')
  if Config.Debug then
    if tempPlayers[source] == nil then
      local identifier, identifiers = nil, GetPlayerIdentifiers(source)
  
      for _, v in pairs(identifiers) do
        if string.find(v, Config.Identifier or "license") then
          identifier = v:sub(9) -- Sanitize the license, delete the <license:>
          break
        end
      end
      tempPlayers[source] = identifier
    end
  end

  if ZMan.Players[source] ~= nil then
    return -- Use this to avoid event spammers (with cheats)
  end

  local _source, characters = source, { }

  -- Send NUI to player (5 characters to choose from)
end)

-- THIS IS W.I.P FOR THE CHARACTERS!
RegisterNetEvent("__zm:internal:chars:choose")
AddEventHandler("__zm:internal:chars:choose", function(data)
  local _source = source

  if data and data.citizenId ~= nil then
    print("citizen id")
  elseif data and data.firstName and data.lastName and data.dateBirth and data.charGender then
    ZMan.Database.fetchAll("SELECT citizenid FROM user_characters WHERE identifier = @id",
      {
        ["@id"] = tempPlayers[_source]
      }, function(res)
      if res then 
        if #res > 5 then
          return
        else
          ZMan.Database.execute("INSERT INTO user_characters VALUES(@citizenid, @identifier, @identity, @last_location, @inventory, @customization, @job, @grade)",
          {
            ["@citizenid"] = Utils.Management.GenCitizenId(),
            ["@identifier"] = tempPlayers[_source],
            ["@identity"] = json.encode({ first = data.firstName, last = data.lastName, dob = data.dateBirth, gender = data.charGender }),
            ["@last_location"] = json.encode({}),
            ["@inventory"] = json.encode(Config.DefaultInventory),
            ["@customization"] = json.encode({}), -- todo: show customization screen upon creating char
            ["@job"] = json.encode(nil),
            ["@grade"] = 0
          })

          tempPlayers[_source] = nil

          -- TODO: Fix group
          ZMan.Instantiate(_source, citizenId, Config.DefaultInventory, { first = data.firstName, last = data.lastName, dob = data.dateBirth, gender = data.charGender }, {}, nil, 0, "admin")
        end
      end
    end)
  end
end)

ZMan.RegisterCommand(
  "giveitem",
  function(source, args)
    local Player, itemName, itemQuant = ZMan.Get(source), args[1], args[2]

    if itemName ~= nil and itemQuant ~= nil then
      Player.AddItem(itemName, itemQuant)
    else
      Utils.Logger.Error(("%s tried to give themselves an item with wrong attributes. (Item Name: ~green~%s~white~, Item Quantity: ~green~%s~white~)")
        :format(Player.GetBaseName(), itemName or "Undefined", itemQuant or "Undefined")
      )
    end
  end, false
)

ZMan.RegisterCommand(
  "revive",
  function(source, args)
    local Player = ZMan.Get(source)

    Player.SetStatus(Status.Health, 200)
  end, false
)