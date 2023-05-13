local DBInit = false

Citizen.CreateThread(function()
    while not ZMan.Database:Ready() do
        Citizen.Wait(1)
    end

    DBInit = true
end)

Utils.Logger.Info("ZimaN Framework, developed with ❤️")
Utils.Logger.Debug("❗ Debug mode is active! This will spam a lot in your server/client's console.")

Citizen.CreateThread(function()
    if Config.Queue and GetResourceState("hardcap") ~= "stopped" then
        StopResource("hardcap")
    end

    while not DBInit do
        Citizen.Wait(1)
    end

    for k, v in pairs(Config.Items) do
        ZMan.AddItem(k, {
            label = v.label,
            weight = v.weight,
            exclusive = v.exclusive
        })
    end
end)

local tempPlayers = {}
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
        def.done(
            ("There was an error getting your identifier (%s), please report this to the system administrator."):format(
                Config.Identifier))
    end

    def.update(("Checking %s's status..."):format(name))

    --local res = exports.oxmysql:single_async("SELECT * FROM users WHERE identifier = ?", {identifier})
    local res = ZMan.Database:FindOne("users", { identifier = identifier })
    if #res > 0 then
      if res.banned > 0 then
        def.done(("You have been banned from this server! (%s)"):format(name))
        return
      end
    else
        --exports.oxmysql:insert_async("INSERT INTO users (identifier, citizenid, inventory, identity, last_location, job, job_grade, `group`) VALUES(?, ?, ?, ?, ?, ?, ?, ?)", 
        --    { identifier, Utils.Management.GenCitizenId(), json.encode(Config.DefaultInventory), json.encode({}), json.encode({}), nil, 0, Config.DefaultGroup })
        
        ZMan.Database:InsertOne("users", { 
            identifier = identifier, citizen_id = Utils.Management.GenCitizenId(), inventory = json.encode(Config.DefaultInventory), 
            identity = json.encode({}), last_location = json.encode(Config.SpawnLocation), job = nil, job_grade = 0, group = Config.DefaultGroup
        })
        
        Utils.Logger.Debug(("Added ~green~%s~white~ to the database!"):format(name), true)
    end

    Utils.Logger.Info(("~green~%s~white~ is connecting to the server."):format(name))
    tempPlayers[source] = identifier

    def.done()
end)

AddEventHandler("playerDropped", function(reason)
    local Player = ZMan.Get(source)

    if Player then
        Player:SavePlayer()
        ZMan.Destroy(source)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.AutoSaveTime * 60000)
        
        local players = ZMan.GetPlayers()
        if players > 0 then
            for k, v in pairs(players) do
                -- Asynchronous
                Citizen.CreateThread(function()
                    ZMan.Get(k):SavePlayer()
                end)
            end
            Utils.Logger.Info(("Saved ~green~%s ~white~player(s)"):format(Utils.Misc.TableSize(players)))
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

            tempPlayers[source] = identifier
        end
    end

    local _source, characters = source, {}

    -- SetRoutingBucketEntityLockdownMode(1, "strict") -- Set lockdown mode as strict so no entities can be created on client-side
    -- SetEntityRoutingBucket(vehicle, 1) -- Set the routing bucket of this vehicle to the same bucket the player is in

    SetPlayerRoutingBucket(_source, 1) -- Set player's routing bucket same as everyone else
    SetRoutingBucketPopulationEnabled(1, Config.SpawnPeds)

    TriggerClientEvent("__zm:client:modules:load", _source, ZMan.Mods.List)

    --local row = exports.oxmysql:single_async("SELECT * FROM users WHERE identifier = ?", { tempPlayers[_source] })
    local res = ZMan.Database:FindOne("users", { identifier = tempPlayers[_source] })
    -- todo: mongodb wrapper
    if res then
        local Player = ZMan.Instantiate(_source, res.citizen_id, json.decode(res.inventory), json.decode(res.identity),
            json.decode(res.last_location), json.decode(res.customization), 0, res.group)

        Player:UpdatePlayer({
            last_location = json.decode(res.last_location),
            citizen_id = json.decode(res.citizen_id),
            group = json.decode(res.group)
        })

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
        ZMan.Database.fetchAll("SELECT citizenid FROM user_characters WHERE identifier = ?", {tempPlayers[_source]},
            function(res)
                if res then
                    if #res > 5 then
                        return
                    else
                        ZMan.Database.execute(
                            "INSERT INTO user_characters VALUES(@citizenid, @identifier, @identity, @last_location, @inventory, @customization, @job, @grade)",
                            {
                                ["@citizenid"] = Utils.Management.GenCitizenId(),
                                ["@identifier"] = tempPlayers[_source],
                                ["@identity"] = json.encode({
                                    first = data.firstName,
                                    last = data.lastName,
                                    dob = data.dateBirth,
                                    gender = data.charGender
                                }),
                                ["@last_location"] = json.encode({}),
                                ["@inventory"] = json.encode(Config.DefaultInventory),
                                ["@customization"] = json.encode({}), -- todo: show customization screen upon creating char
                                ["@job"] = json.encode(nil),
                                ["@grade"] = 0
                            })

                        tempPlayers[_source] = nil

                        -- TODO: Fix group
                        -- ZMan.Instantiate(_source, citizenId, Config.DefaultInventory, { first = data.firstName, last = data.lastName, dob = data.dateBirth, gender = data.charGender }, {}, nil, 0, "admin")
                    end
                end
            end)
    end
end)

ZMan.Ready = true
