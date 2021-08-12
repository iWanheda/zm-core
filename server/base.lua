local MySQLInit = false

MySQL.ready(
  function()
    MySQLInit = true
  end
)

Citizen.CreateThread(
  function()
    if Config.Queue and GetResourceState("hardcap") == "started" then
      StopResource("hardcap")
    end

    while not MySQLInit do
      Citizen.Wait(1)
    end

    Utils.Logger.Info("ZimaN Framework, developed with ❤️")
    Utils.Logger.Debug("❗ Debug mode is active! This will spam a lot in your server/client's console.")

    MySQL.Async.fetchAll(
      "SELECT * FROM items",
      {},
      function(res)
        if res ~= nil then
          for k, v in pairs(res) do
            ZMan.AddItem(v.name, { label = v.label, weight = 1.2, exclusive = true })
          end
        end
      end
    )
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
  AddEventHandler(
    "entityCreating",
    function(ent)
      if GetEntityPopulationType(ent) ~= 7 then
        CancelEvent()
      end
    end
  )
end

RegisterNetEvent("__zm:getLibrary")
AddEventHandler(
  "__zm:getLibrary",
  function(cb)
    ZMan.Utils = Utils

    cb(ZMan)
  end
)

AddEventHandler(
  "playerConnecting",
  function(name, kickReason, def)
    -- def.defer()
    Utils.Logger.Info(("%s is connecting to the server."):format(name))
  end
)

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

Citizen.CreateThread(
  function()
    while true do
      Citizen.Wait(Config.AutoSaveTime * 60000)

      for k, v in pairs(ZMan.GetPlayers()) do
        ZMan.Get(k):SavePlayer()
      end
    end
  end
)

-- This also prevents the table from getting empty upon a script restart
RegisterNetEvent("__zm:joined")
AddEventHandler(
  "__zm:joined",
  function()
    local _source = source

    MySQL.Async.fetchAll(
      "SELECT * FROM users WHERE identifier = @id",
      {
        ["@id"] = GetPlayerIdentifier(_source, 0):sub(9)
      },
      function(res)
        if res and res[1] ~= nil then
          local Player = ZMan.Instantiate(_source, res[1].inventory, res[1].last_location)

          Utils.Logger.Debug(("Great! We've got %s's info!"):format(Player:GetBaseName()))

          Player:UpdatePlayer(
            {
              last_location = res[1].last_location,
              inventory = res[1].inventory
            }
          )

          TriggerClientEvent("__zm:playerLoaded", _source)
        else
          local Player = ZMan.Instantiate(_source, {}, {})

          MySQL.Async.execute(
            "INSERT INTO users VALUES(@id, @identity, @customization, @job, @grade, @inv, @last_location)",
            {
              ["@id"] = Player:GetIdentifier(),
              ["@identity"] = json.encode(
                {
                  first_name = nil,
                  last_name = nil
                }
              ),
              ["@customization"] = json.encode({}),
              ["@job"] = nil,
              ["@grade"] = 0,
              ["@inv"] = json.encode(Config.DefaultInventory),
              ["@last_location"] = json.encode(Config.SpawnLocation)
            },
            function()
              Utils.Logger.Debug(("Added %s to the database!"):format(Player:GetBaseName()))
            end
          )
        end

        local Player = ZMan.Get(_source)
        Player:ShowNotification("success", Config.ServerName, "Welcome to the Server!")
      end
    )
  end
)

RegisterCommand(
  "coords",
  function(source)
    print(GetEntityCoords(GetPlayerPed(source)))
  end
)

RegisterCommand(
  "inv",
  function(source)
    local Player = ZMan.Get(source)

    print(Player:GetInventory())
  end
)

RegisterCommand(
  "giveitem",
  function(source, args)
    local Player, itemName, itemQuant = ZMan.Get(source), args[1], args[2]

    if itemName ~= nil and itemQuant ~= nil then
      Player:AddItem(itemName, itemQuant)
    else
      Utils.Logger.Error(("%s tried to give themself an item with wrong attributes. (Item Name: ^3%s^7, Item Quantity: ^3%s^7)")
        :format(Player:GetBaseName(), itemName or "Undefined", itemQuant or "Undefined")
      )
    end
  end
)

RegisterCommand(
  "revive",
  function(source, args)
    local Player = ZMan.Get(source)

    Player:SetStatus(Status.Health, 200)
  end
)
