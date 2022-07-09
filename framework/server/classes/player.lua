CPlayer = { }
CPlayer.__index = CPlayer

-- Status table
Status = { }
Status.Functions = { }

Status.Health = 1

-- Create our actual Player instance
function CPlayer.Create(src, citizenid, inventory, identity, last_location, job, grade, group)
  local self = setmetatable({ }, CPlayer)

  local playerInv = inventory

  for k, v in pairs(playerInv) do
    -- If an inventory item is invalid (has been removed from the config) we will remove the invalid item from player's inventory
    if Config.Items[k] == nil then
      Utils.Logger.Warn(("Player ~green~%s~white~ has an ~red~invalid~white~ item ~yellow~(%s)"):format(GetPlayerName(src), k))
      playerInv[k] = nil -- Remove the invalid item from Player's inventory
    end
  end

  self.src = src

  local identifier = tostring(GetPlayerIdentifier(self.src, 0)):sub(9)

  self.citizenid = citizenid
  self.identifier = identifier

  self.inv = playerInv
  
  self.firstname = identity.first
  self.lastname = identity.last
  self.dob = identity.dob
  self.gender = identity.gender

  self.spawn = last_location

  self.job = job
  self.grade = grade

  self.group = group

  self.tokens = { }
  local tokensNum = GetNumPlayerTokens(src)

  for i = 1, tokensNum, 1 do
    local token = GetPlayerToken(src, i)

    if token ~= nil then
      table.insert(self.tokens, token)
    end
  end

  -- Methods
  -- Apparently we have to define them this way instead of CPlayer:Method() or else it doesn't
  --  seem to work on other resources :|

  self.Get = function()
    return self
  end

  self.GetSource = function()
    return self.src
  end

  self.GetCitizenId = function()
    return self.citizenid
  end

  self.GetIdentifier = function()
    return self.identifier
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

  self.GetTokens = function()
    return self.tokens
  end

  self.GetPosition = function()
    return GetEntityCoords(GetPlayerPed(self.src))
  end

  self.GetJob = function()
    if self.job ~= nil then
      return ZMan.GetJob(self.job)
    end
  end

  -- Change this
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

  --[[
    => Send Player data to the client
    !CAREFUL HOW YOU USE IT
    @data :table => Table containing key:value of requested data
  ]]
  self.UpdatePlayer = function(data)
    TriggerClientEvent("__zm:updatePlayerData", self.src, data)
  end

  --[[
    => Trigger an event to the instantiated Player
    @event :string => Event name to be triggered
    @args :any => Arguments to be sent in the event
  ]]
  self.TriggerEvent = function(event, ...)
    TriggerClientEvent(tostring(event), self.src, ...)
  end

  --[[
    => Saves Player data to the database (ZMan already does this automatically, you shouldn't need to use this function)
  ]]
  self.SavePlayer = function()
    -- This is on player save
    Utils.Logger.Debug(("Saved ~green~%s"):format(self.GetBaseName()))

    local playerPos, playerIdentifier, playerInventory = self.GetPosition(), self.GetCitizenId(), self.GetInventory()
    local x, y, z, h = playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(GetPlayerPed(self.src))

    MySQL.Async.execute(
      "UPDATE user_characters SET last_location = @last_location, inventory = @inv, job = @job, grade = @grade, customization = @customization, identity = @identity WHERE citizenid = @citizenid",
      {
        ["@id"] = playerIdentifier,

        ["@last_location"] = json.encode({ x, y, z, h }),
        ["@inv"] = json.encode(playerInventory),
        ["@job"] = self.GetJob(),
        ["@grade"] = self.GetJobGrade(),
        ["@customization"] = json.encode(self.GetOutfit()),
        ["@identity"] = json.encode(self.GetName())
      },
      function() end
    )
  end

  --[[
    @first :string => Set first name of Player (identity)
    @last :string => Set last name of Player (identity)
  ]]
  self.SetName = function(first, last)
    self.firstname = first
    self.lastname = last
  end

  --[[
    => Set a Player's status effect (Ex. smokes a joint and gets extra HP)
    @status :enum => Player status to be modified (Enum available \@ https://zman.dev/docs/enums/#status)
    @value :number :@1 => Determines how much of said item should be removed
  ]]
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

  --[[
    => Execute the function associated with said item
    @item :string => The item to be used (name)
  ]]
  self.UseItem = function(item)
    local playerInventory = self.GetInventory()

    if type(item) ~= "string" then
      return
    end

    if playerInventory[item] ~= nil then
      if ZMan.Items[item] ~= nil then
        if ZMan.UsableItems[item] ~= nil then
          ZMan.UsableItems[item]()
          self.RemoveItem(item)
        end
      end
    end
  end

  --[[
    @item :string => The item to be added (name)
    @quantity :number :@1 => Determines how much of said item should be added
  ]]
  self.AddItem = function(item, quantity)
    local playerInventory, playerName = self.GetInventory(), self.GetBaseName()

    quantity = tonumber(quantity)

    if type(item) ~= "string" then
      return Utils.Logger.Warn(("Item (%s) needs to be a string!"):format(item))
    elseif type(quantity) ~= "number" then
      return Utils.Logger.Warn("Item quantity needs to be a number!")
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
      Utils.Logger.Warn(("%s tried to spawn an invalid item! (%s)"):format(playerName, item))
    end
  end

  --[[
    @item :string => The item to be removed (name)
    @quantity :number :@1 => Determines how much of said item should be removed
    @silent :boolean :@false => If `true` then no drop is created (used for admin actions)
    // ^ Param ^ Datatype ^ Default Value
  ]]
  self.RemoveItem = function(item, quantity, silent)
    local playerInventory, playerName = self.GetInventory(), self.GetBaseName()

    quantity = tonumber(quantity) or 1

    if type(item) ~= "string" then
      return Utils.Logger.Warn(("Item (%s) needs to be a string!"):format(item))
    elseif type(quantity) ~= "number" then
      return Utils.Logger.Warn("Item quantity needs to be a number!")
    end

    CreateDrop = function(item, quantity)
      local playerPos = self.GetPosition()

      if item and quantity and playerPos then
        local itemProps = { item = { name = item, label = ZMan.Items[item].label }, quantity = quantity, position = playerPos }

        Utils.Logger.Debug(("Created drop of ~green~%s (x%s)~white~ @ ~green~%s~white~"):format(item, quantity, playerPos))

        ZMan.Drops[#ZMan.Drops + 1] = itemProps
        TriggerClientEvent("__zm:internal:drop:create", -1, itemProps)
      end
    end

    if ZMan.Items[item] ~= nil then
      if playerInventory[item] ~= nil then
        playerInventory[item] = nil
        self.ShowNotification("success", "Inventory", ("Removed (x%s) %s"):format(quantity, ZMan.Items[item]))

        if not silent then
          CreateDrop(item, quantity)
        end
      end
    else
      self.ShowNotification("error", "Inventory", ("Item (%s) is invalid!"):format(item))
      Utils.Logger.Warn(("%s tried to remove an invalid item! (%s)"):format(playerName, item))
    end
  end

  self.SetJob = function(job)
    if job ~= nil and ZMan.Jobs[job] then
      self.job = job
    end
  end

  -- TODO: Test this
  self.SetGroup = function(group)
    if group ~= nil then
      if Config.Groups[group] then
        ExecuteCommand(("remove_principal identifier.license:%s zman.groups.%s"):format(self.GetIdentifier(), self.GetGroup())) -- Remove old group
        ExecuteCommand(("add_principal identifier.license:%s zman.groups.%s"):format(self.GetIdentifier(), group)) -- Add new group
        
        self.group = group
      end
    else
      Utils.Logger.Warn(("Group ~red~%s~white~ does not exist in ~lblue~Groups ~white~table! (Check ~yellow~%s/config.lua~white~)"):format(group, ZMan.Resource), true)
    end
  end

  -- Triggers
  self.Callback = function(callback, ...)
    -- Check ZMan.Callbacks table if callback is valid
    if callback ~= nil then
      if ZMan.Callbacks[callback] then
        TriggerClientEvent(callback, self.src, ...)
      else
        Utils.Logger.Warn(("Attempted to trigger an ~red~invalid~white~ callback! ~green~(%s) => (%s) %s"):format(callback, self.src, self.GetBaseName()))
      end
    end
  end

  return self
end

-- Beware of these functions, they do not check if source is valid etc...

--ZMan.GetCitizenId = function(source)
--  return ZMan.Players[source].GetCitizenId()
--end