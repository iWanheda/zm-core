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

   -- changeme banned
  local identifier = "license:123" --tostring(GetPlayerIdentifier(self.src, 0)):sub(9)

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

  return self
end

-- Beware of these functions, they do not check if source is valid etc...

--ZMan.GetCitizenId = function(source)
--  return ZMan.Players[source].GetCitizenId()
--end

function CPlayer:Get()
  return self
end

function CPlayer:GetSource()
  return self.src
end

function CPlayer:GetCitizenId()
  return self.citizenid
end

function CPlayer:GetIdentifier()
  return self.identifier
end

function CPlayer:GetName()
  return { first = self.firstname, last = self.lastname }
end

function CPlayer:GetAge()
  return self.age
end

function CPlayer:GetOutfit()
  return {}
end

function CPlayer:GetBaseName()
  return GetPlayerName(self.src)
end

function CPlayer:GetTokens()
  return self.tokens
end

function CPlayer:GetPosition()
  return GetEntityCoords(GetPlayerPed(self.src))
end

function CPlayer:GetJob()
  if self.job ~= nil then
    return ZMan.GetJob(self.job)
  end
end

-- Change this
function CPlayer:GetJobGrade()
  return self.grade
end

function CPlayer:GetGroup()
  return self.group
end

function CPlayer:GetInventory()
  return self.inv
end

function CPlayer:Kick(reason)
  return DropPlayer(self.src, reason)
end

function CPlayer:ShowNotification(type, cap, msg, time)
  return TriggerClientEvent("__zm:sendNotification", self.src, { t = type, c = cap, m = msg, ti = time })
end

--[[
  => Send Player data to the client
  !CAREFUL HOW YOU USE IT
  @data :table => Table containing key:value of requested data
]]
function CPlayer:UpdatePlayer(data)
  TriggerClientEvent("__zm:updatePlayerData", self.src, data)
end

--[[
  => Trigger an event to the instantiated Player
  @event :string => Event name to be triggered
  @args :any => Arguments to be sent in the event
]]
function CPlayer:TriggerEvent(event, ...)
  TriggerClientEvent(tostring(event), self.src, ...)
end

--[[
  => Saves Player data to the database (ZMan already does this automatically, you shouldn't need to use this function)
]]
function CPlayer:SavePlayer()
  -- This is on player save
  Utils.Logger.Debug(("Saved ~green~%s"):format(self:GetBaseName()))

  local playerPos, citizenId, playerInventory = self:GetPosition(), self:GetCitizenId(), self:GetInventory()
  local x, y, z, h = playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(GetPlayerPed(self.src))

  MySQL.Async.execute(
    "UPDATE users SET last_location = @last_location, inventory = @inv, job = @job, grade = @grade, customization = @customization, identity = @identity WHERE citizenid = @citizenid",
    {
      ["@citizenid"] = citizenId,

      ["@last_location"] = json.encode({ x, y, z, h }),
      ["@inv"] = json.encode(playerInventory),
      ["@job"] = self:GetJob(),
      ["@grade"] = self:GetJobGrade(),
      ["@customization"] = json.encode(self:GetOutfit()),
      ["@identity"] = json.encode(self:GetName())
    },
    function() end
  )
end

--[[
  @first :string => Set first name of Player (identity)
  @last :string => Set last name of Player (identity)
]]
function CPlayer:SetName(first, last)
  self.firstname = first
  self.lastname = last
end

function CPlayer:Teleport(coords)
  self:TriggerEvent("__zm:teleportPlayer", coords or GetEntityCoords(self.src))
end

--[[
  => Execute the function associated with said item
  @item :string => The item to be used (name)
]]
function CPlayer:UseItem(item)
  local playerInventory = self:GetInventory()

  if type(item) ~= "string" then
    return
  end

  if ZMan.Items[item] ~= nil and playerInventory[item] ~= nil then
    if ZMan.UsableItems[item] ~= nil then
      ZMan.UsableItems[item]()
      self:RemoveItem(item)
    end
  end
end

--[[
  @item :string => The item to be added (name)
  @quantity :number :@1 => Determines how much of said item should be added
]]
function CPlayer:AddItem(item, quantity)
  local playerInventory, playerName = self:GetInventory(), self:GetBaseName()

  quantity = tonumber(quantity)

  if type(item) ~= "string" then
    return Utils.Logger.Warn(("Item (%s) needs to be a string!"):format(item))
  elseif type(quantity) ~= "number" then
    return Utils.Logger.Warn("Item quantity needs to be a number!")
  end

  if ZMan.Items[item] ~= nil then
    self:ShowNotification("success", "Inventory", ("Added (x%s) %s"):format(quantity, ZMan.Items[item].label))

    if playerInventory[item] == nil then
      playerInventory[item] = quantity
    else
      playerInventory[item] = tonumber(playerInventory[item]) + quantity
    end
  else
    self:ShowNotification("error", "Inventory", ("Item (%s) is invalid!"):format(item))
    Utils.Logger.Warn(("%s tried to spawn an invalid item! (%s)"):format(playerName, item))
  end
end

--[[
  @item :string => The item to be removed (name)
  @quantity :number :@1 => Determines how much of said item should be removed
  @silent :boolean :@false => If `true` then no drop is created (used for admin actions)
  // ^ Param ^ Datatype ^ Default Value ^ Description
]]
function CPlayer:RemoveItem(item, quantity, silent)
  local playerInventory, playerName = self:GetInventory(), self:GetBaseName()

  quantity = tonumber(quantity) or 1
  silent = silent or true

  if type(item) ~= "string" then
    return Utils.Logger.Warn(("Item (%s) needs to be a string!"):format(item))
  elseif type(quantity) ~= "number" then
    return Utils.Logger.Warn("Item quantity needs to be a number!")
  end

  CreateDrop = function(item, quantity)
    local playerPos = self:GetPosition()

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
      self:ShowNotification("success", "Inventory", ("Removed (x%s) %s"):format(quantity, ZMan.Items[item]))

      if not silent then
        CreateDrop(item, quantity)
      end
    end
  else
    self:ShowNotification("error", "Inventory", ("Item (%s) is invalid!"):format(item))
    Utils.Logger.Warn(("%s tried to remove an invalid item! (%s)"):format(playerName, item))
  end
end

function CPlayer:SetJob(job)
  if job ~= nil and ZMan.Jobs[job] then
    self.job = job
  end
end

function CPlayer:PlayAnimation(dict, name)
  TriggerClientEvent("__zm:internal:load:dict_anim", self.src, dict, name)
end

-- TODO: Test this
function CPlayer:SetGroup(group)
  if group ~= nil then
    if Config.Groups[group] then
      ExecuteCommand(("remove_principal identifier.license:%s zman.groups.%s"):format(self:GetIdentifier(), self:GetGroup())) -- Remove old group
      ExecuteCommand(("add_principal identifier.license:%s zman.groups.%s"):format(self:GetIdentifier(), group)) -- Add new group
      
      self.group = group
    end
  else
    Utils.Logger.Warn(("Group ~red~%s~white~ does not exist in ~lblue~Groups ~white~table! (Check ~yellow~%s/config.lua~white~)"):format(group, ZMan.Resource), true)
  end
end

-- Triggers
function CPlayer:Callback(callback, ...)
  -- Check ZMan.Callbacks table if callback is valid
  if callback ~= nil then
    if ZMan.Callbacks[callback] then
      TriggerClientEvent(callback, self.src, ...)
    else
      Utils.Logger.Warn(("Attempted to trigger an ~red~invalid~white~ callback! ~green~(%s) => (%s) %s"):format(callback, self.src, self.GetBaseName()))
    end
  end
end