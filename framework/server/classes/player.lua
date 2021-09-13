CPlayer = { }
CPlayer.__index = CPlayer

-- Status table
Status = { }
Status.Functions = { }

Status.Health = 1

-- Create our actual Player instance
function CPlayer.Create(src, inventory, identity, last_location, job, grade, group)
  local self = setmetatable({ }, CPlayer)

  local playerInv = json.decode(inventory)

  for k, v in pairs(playerInv) do
    if Config.Items[k] == nil then
      Utils.Logger.Warn(("Player ~green~%s~white~ has an ~red~invalid~white~ item ~yellow~(%s)"):format(GetPlayerName(src), k))
      playerInv[k] = nil -- Remove the invalid item from Player's inventory
    end
  end

  self.src = src

  self.inv = playerInv
  
  self.firstname = identity.first
  self.lastname = identity.last

  self.spawn = json.decode(last_location)

  self.job = job
  self.grade = grade

  self.group = group

  -- Methods
  -- Apparently we have to defined them this way instead of CPlayer.Method() or else it doesn't
  --  seem to work on other resources :|

  self.Get = function()
    return self
  end

  self.GetSource = function()
    return self.src
  end

  self.GetIdentifier = function()
    local identifier = tostring(GetPlayerIdentifier(self.src, 0)):sub(9)

    if not identifier then
      return self.Kick(
        (
          "There was an error getting your identifier (%s), please report this to the system administrator."
        ):format(Config.Identifier)
      )
    end

    return identifier
  end

  self.GetName = function()
    return { first = self.firstname, last = self.lastname }
  end

  self.GetAge = function()
    return self.age
  end

  self.GetOutfit = function()
    return {}
  end

  self.GetBaseName = function()
    return GetPlayerName(self.src)
  end

  self.GetPosition = function()
    return GetEntityCoords(GetPlayerPed(self.src))
  end

  self.GetJob = function()
    if self.job ~= nil then
      return ZMan.GetJob(self.job)
    end
  end

  -- change this
  self.GetJobGrade = function()
    return self.grade
  end

  self.GetGroup = function()
    return self.group
  end

  self.GetInventory = function()
    return self.inv
  end

  self.Kick = function(reason)
    return DropPlayer(self.src, reason)
  end

  self.ShowNotification = function(type, cap, msg, time)
    return TriggerClientEvent("__zm:sendNotification", self.src, { t = type, c = cap, m = msg, ti = time })
  end

  self.UpdatePlayer = function(data)
    TriggerClientEvent("__zm:updatePlayerData", self.src, data)
  end

  self.TriggerEvent = function(event, args)
    TriggerClientEvent(tostring(event), self.src, args)
  end

  -- TODO: Add job and such...
  self.SavePlayer = function()
    -- This is on player save
    Utils.Logger.Debug(("Saved ~green~%s"):format(self.GetBaseName()))

    local playerPos, playerIdentifier, playerInventory = self.GetPosition(), self.GetIdentifier(), self.GetInventory()
    local x, y, z, h = playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(GetPlayerPed(self.src))

    MySQL.Async.execute(
      "UPDATE users SET last_location = @last_location, inventory = @inv, job = @job, grade = @grade, `group` = @group, customization = @customization, identity = @identity WHERE identifier = @id",
      {
        ["@id"] = playerIdentifier,

        ["@last_location"] = json.encode({ x, y, z, h }),
        ["@inv"] = json.encode(playerInventory),
        ["@job"] = self.GetJob(),
        ["@grade"] = self.GetJobGrade(),
        ["@group"] = self.GetGroup(),
        ["@customization"] = json.encode(self.GetOutfit()),
        ["@identity"] = json.encode(self.GetName())
      },
      function() end
    )
  end

  self.SetName = function(first, last)
    self.firstname = first
    self.lastname = last
  end

  self.SetStatus = function(status, value)
    -- We do this method so we can use methods from our CPlayer class
    if Utils.Misc.TableSize(Status.Functions) == 0 then
      Status.Functions =
      {
        [1] = function(health)
          self.TriggerEvent("__zm:revivePlayer", health)
        end
      }
    end

    if Status.Functions[status] ~= nil then
      Status.Functions[status](value)
    end
  end

  self.AddItem = function(item, quantity)
    local playerInventory, playerName = self.GetInventory(), self.GetBaseName()

    quantity = tonumber(quantity)

    if type(item) ~= "string" then
      return Utils.Logger.Error(("Item (%s) needs to be a string!"):format(item))
    elseif type(quantity) ~= "number" then
      return Utils.Logger.Error("Item quantity needs to be a number!")
    end

    if ZMan.Items[item] ~= nil then
      self.ShowNotification("success", "Inventory", ("Added (x%s) %s"):format(quantity, ZMan.Items[item].label))

      if playerInventory[item] == nil then
        playerInventory[item] = quantity
      else
        playerInventory[item] = tonumber(playerInventory[item]) + quantity
      end
    else
      self.ShowNotification("error", "Inventory", ("Item (%s) is invalid!"):format(item))
      Utils.Logger.Error(("%s tried to spawn an invalid item! (%s)"):format(playerName, item))
    end
  end

  self.RemoveItem = function(item, quantity)
    local playerIdentifier, playerInventory, playerName = self.GetIdentifier(), self.GetInventory(), self.GetBaseName()

    quantity = tonumber(quantity)

    if type(item) ~= "string" then
      return Utils.Logger.Error(("Item (%s) needs to be a string!"):format(item))
    elseif type(quantity) ~= "number" then
      return Utils.Logger.Error("Item quantity needs to be a number!")
    end

    CreateDrop = function(item, options)
      print("dropped")
    end

    if ZMan.Items[item] ~= nil then
      if playerInventory[item] ~= nil then
        playerInventory[item] = nil
        self.ShowNotification("success", "Inventory", ("Removed (x%s) %s"):format(quantity, ZMan.Items[item]))

        CreateDrop(item, { quantity = quantity })
      end
    else
      self.ShowNotification("error", "Inventory", ("Item (%s) is invalid!"):format(item))
      Utils.Logger.Error(("%s tried to remove an invalid item! (%s)"):format(playerName, item))
    end
  end

  self.SetJob = function(job)
    if job ~= nil and ZMan.Jobs[job] then
      self.job = job
    end
  end

  -- TODO: Test this
  self.SetGroup = function(group)
    if group ~= nil and Config.Groups[group] then
      ExecuteCommand(("remove_principal identifier.license:%s zman.groups.%s"):format(self.GetIdentifier(), self.GetGroup())) -- Remove old group
      ExecuteCommand(("add_principal identifier.license:%s zman.groups.%s"):format(self.GetIdentifier(), group)) -- Add new group
      self.group = group
    else
      Utils.Logger.Error(("Group ~red~%s~white~ does not exist in ~lblue~Groups ~white~table! (Check ~yellow~%s/config.lua~white~)"):format(group, GetCurrentResourceName()), true)
    end
  end

  return self
end