local MySQLInit = false

Citizen.CreateThread(function()
  Citizen.Wait(10000)
  if not MySQLInit then
    Utils.Logger.Error("Could not establish a connection to MySQL Server! ~lblue~https://zman.dev/faq#mysql-error")
  end
end)

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

    Utils.Misc.DumpTable(Player)
  end
)

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
   -- changeme banned
  --local identifier, identifiers = nil, GetPlayerIdentifiers(source)

  def.defer()
  Wait(0)

   -- changeme banned
  --for _, v in pairs(identifiers) do
  --  if string.find(v, Config.Identifier or "license") then
  --    identifier = v:sub(9)
  --    break
  --  end
  --end

  --if not identifier then
  --  def.done((
  --    "There was an error getting your identifier (%s), please report this to the system administrator."
  --  ):format(Config.Identifier))
  --end

  def.update(("Checking %s's status..."):format(name))
  -- changeme banned
  --MySQL.Async.fetchAll(
  --  "SELECT * FROM users WHERE identifier = @id",
  --  {
  --    ["@id"] = identifier
  --  },
  --  function(res)
  --    Utils.Logger.Info(("~green~%s~white~ is connecting to the server."):format(name))
  --    if res and res[1] ~= nil then
  --      if res[1].banned ~= false then
  --        def.done(("You have been banned from this server! (%s)"):format(name))
  --        return
  --      end
  --    else
  --      MySQL.Async.execute(
  --        "INSERT INTO users VALUES(@id, @group, false)",
  --        {
  --          ["@id"] = identifier,
  --          ["@group"] = Config.DefaultGroup,
  --        },
  --        function()
  --          Utils.Logger.Debug(("Added ~green~%s~white~ to the database!"):format(name), true)
  --        end
  --      )
  --    end
  --    tempPlayers[source] = identifier
  --    def.done()
  --  end
  --)

  -- changeme banned
  tempPlayers[source] = "license:123" --identifier
  def.done()
end)

AddEventHandler(
  "playerDropped",
  function(reason)
    local Player = ZMan.Get(source)

    if Player then
      Player:SavePlayer()
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

-- This also prevents the table from getting empty upon a script restart
-- TODO: UpdatePlayer everytime we instantiate a new Player, fix some bugs and improve this overall!
RegisterNetEvent("__zm:joined")
AddEventHandler("__zm:joined", function()
  if ZMan.Players[source] ~= nil then
    return -- Use this to avoid event spammers (with cheats)
  end

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
       -- changeme banned
      tempPlayers[source] = "license:123" --identifier
    end
  end

  local _source, characters = source, { }

  --SetRoutingBucketEntityLockdownMode(1, "strict") -- Set lockdown mode as strict so no entities can be created on client-side
  --SetEntityRoutingBucket(vehicle, 1) -- Set the routing bucket of this vehicle to the same bucket the player is in

  SetPlayerRoutingBucket(_source, 1) -- Set player's routing bucket same as everyone else
  SetRoutingBucketPopulationEnabled(1, Config.SpawnPeds)

  TriggerClientEvent("__zm:client:modules:load", _source, ZMan.Mods.List)

  local row = exports.oxmysql:single_async("SELECT * FROM users WHERE identifier = ?", { tempPlayers[_source] })
  if row then
    local Player = ZMan.Instantiate(_source, 
      row.citizenid, json.decode(row.inventory), 
      json.decode(row.identity), json.decode(row.last_location), 
      json.decode(row.customization), 0, row.group)
  
    Player:UpdatePlayer({ last_location = json.decode(row.last_location), 
      group = json.decode(row.group) })
  else
    ZMan.Instantiate(_source, 
      Utils.Management.GenCitizenId(), Config.DefaultInventory, {}, {}, nil, 0, Config.DefaultGroup)

    TriggerEvent("__zm:server:modules:indentity:register", _source)
  end

  tempPlayers[_source] = nil
end)

-- THIS IS W.I.P FOR THE CHARACTERS!
RegisterNetEvent("__zm:internal:chars:choose")
AddEventHandler("__zm:internal:chars:choose", function(data)
  local _source = source

  if data and data.citizenId ~= nil then
    print("citizen id")
  elseif data and data.firstName and data.lastName and data.dateBirth and data.charGender then
    ZMan.Database.fetchAll("SELECT citizenid FROM user_characters WHERE identifier = ?",
      {
        tempPlayers[_source]
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
          --ZMan.Instantiate(_source, citizenId, Config.DefaultInventory, { first = data.firstName, last = data.lastName, dob = data.dateBirth, gender = data.charGender }, {}, nil, 0, "admin")
        end
      end
    end)
  end
end)

ZMan.Ready = true