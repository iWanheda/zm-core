local CPlayer = { }
CPlayer.__index = CPlayer

-- Create our actual Player instance
function CPlayer.Create(src, inventory, last_location)
    local self = setmetatable({ }, CPlayer)

    self.src = src
    self.inv = json.decode(inventory)
    self.spawn = json.decode(last_location)

    return self
end

-- Get player's source
function CPlayer:GetSource()
    return self.src
end

-- Get player's rockstar identifier
function CPlayer:GetIdentifier()
    local identifier = tostring(GetPlayerIdentifier(self.src, 0)):sub(9)

    if not identifier then
        return self:Kick(
            (
                "There was an error getting your identifier (%s), please report this to the system administrator."
            ):format(Config.Identifier)
        )
    end

    return identifier
end

-- Get player's name
function CPlayer:GetName()
    return { first = self.firstname, last = self.lastname }
end

-- Get player's age
function CPlayer:GetAge()
    return self.age
end

-- Get player's base name (FiveM, Steam)
function CPlayer:GetBaseName()
    return GetPlayerName(self.src)
end

-- Get player's coords
function CPlayer:GetPosition()
    return GetEntityCoords(GetPlayerPed(self.src))
end

function CPlayer:Kick(reason)
    return DropPlayer(self.src, reason)
end

-- Get player's base name (FiveM, Steam)
function CPlayer:ShowNotification(type, cap, msg, time)
    return TriggerClientEvent("__zm:sendNotification", self.src, { t = type, c = cap, m = msg, ti = time })
end

function CPlayer:UpdatePlayer(data)
    TriggerClientEvent("__zm:updatePlayerData", self.src, data)
end

function CPlayer:SavePlayer()
    Utils.Logger.Info(("Saved %i player(s)"):format(Utils.Misc.TableSize(ZMan.GetPlayers())))
    Utils.Logger.Debug(("Saved %s"):format(self:GetBaseName()))

    local playerPos, playerIdentifier, playerInventory = self:GetPosition(), self:GetIdentifier(), self:GetInventory()
    local x, y, z = playerPos.x, playerPos.y, playerPos.z

    MySQL.Async.execute(
        "UPDATE users SET last_location = @last_location, inventory = @inv WHERE identifier = @id",
        {
            ["@last_location"] = json.encode({ x, y, z }),
            ["@inv"] = json.encode(playerInventory),
            ["@id"] = tostring(playerIdentifier)
        },
        function()
        end
    )
end

-- Change this, on join save player inv to table, modify player inv on table and upon leaving/auto save send info back to DB

function CPlayer:GetInventory()
    local playerIdentifier, playerName = self:GetIdentifier(), self:GetBaseName()

    return self.inv
end

function CPlayer:AddItem(item, quantity)
    local playerIdentifier, playerInventory, playerName = self:GetIdentifier(), self:GetInventory(), self:GetBaseName()

    quantity = tonumber(quantity)

    if type(item) ~= "string" then
        return Utils.Logger.Error(("Item (%s) needs to be a string!"):format(item))
    elseif type(quantity) ~= "number" then
        return Utils.Logger.Error("Item quantity needs to be a number!")
    end

    if ZMan.Items[item] ~= nil then
        self:ShowNotification("success", "Inventory", ("Added (x%s) %s"):format(quantity, ZMan.Items[item]))

        if playerInventory[item] == nil then
            playerInventory[item] = quantity
        else
            playerInventory[item] = tonumber(playerInventory[item]) + quantity
        end
    else
        self:ShowNotification("error", "Inventory", ("Item (%s) is invalid!"):format(item))
        Utils.Logger.Error(("%s tried to spawn an invalid item! (%s)"):format(playerName, item))
    end
end

function CPlayer:RemoveItem(item, quantity)
    local playerIdentifier, playerInventory, playerName = self:GetIdentifier(), self:GetInventory(), self:GetBaseName()

    quantity = tonumber(quantity)

    if type(item) ~= "string" then
        return Utils.Logger.Error(("Item (%s) needs to be a string!"):format(item))
    elseif type(quantity) ~= "number" then
        return Utils.Logger.Error("Item quantity needs to be a number!")
    end

    if ZMan.Items[item] ~= nil then
        self:ShowNotification("success", "Inventory", ("Added (x%s) %s"):format(quantity, ZMan.Items[item]))

        if playerInventory[item] ~= nil then
            playerInventory[item] = nil
        end
    else
        self:ShowNotification("error", "Inventory", ("Item (%s) is invalid!"):format(item))
        Utils.Logger.Error(("%s tried to remove an invalid item! (%s)"):format(playerName, item))
    end
end

-- Player management
ZMan =
{
    Players = { },

    Instantiate = function(src, inv, pos)
        if ZMan.Players[src] == nil then
            Utils.Logger.Info(("New player instantiated (%s)"):format(src))
            -- Append new Player instance to player list
            ZMan.Players[src] = CPlayer.Create(src, inv, pos)

            return
        end

        Utils.Logger.Debug(
            ("Error instantiating a new Player object! (%s) already exists in the table!"):format(GetPlayerName(src))
        )
    end,

    Destroy = function(src)
        if ZMan.Players[src] ~= nil then
            ZMan.Players[src] = nil

            return
        end

        Utils.Logger.Debug(
            ("Error destroying a Player object! (%s) doesn't exist in our table!"):format(GetPlayerName(src))
        )
    end,

    Get = function(src)
        if ZMan.Players[src] ~= nil then
            return ZMan.Players[src]
        end

        Utils.Logger.Debug(("Cannot get %s's object! Doesn't exist on Players table!"):format(GetPlayerName(src)))
    end,

    GetPlayers = function()
        return ZMan.Players
    end
}
