ZMan = { }

ZMan.Resource = GetCurrentResourceName() -- Let's cache it! :]

ZMan.Players = { }
ZMan.Items = { }
ZMan.Jobs = { }
ZMan.Commands = { }
ZMan.Callbacks = { }

ZMan.Mods = { }

-- To test
ZMan.Modules = { ["main"] = { } }
ZMan.Mods.Excluded = 0

-- Player management

ZMan.Instantiate = function(src, inv, ident, pos, job, grade, group)
  if ZMan.Players[src] == nil then
    -- Append new Player instance to player list
    local Player = CPlayer.Create(src, inv, ident, pos, job, grade, group)
    ZMan.Players[src] = Player

    -- Not sure if I have to add principal everytime a player joins?
    --ExecuteCommand(('add_principal identifier.license:%s group.%s'):format(Player.GetIdentifier(), Player.GetGroup()))

    Utils.Logger.Info(("New player instantiated ~green~(%s)~white~ => ~green~%s"):format(Player.GetBaseName(), src))

    return Player
  end

  Utils.Logger.Debug(
    ("Error instantiating a new Player object! ~green~(%s)~white~ already exists in the table!"):format(GetPlayerName(src))
  )
end

ZMan.Destroy = function(src)
  if ZMan.Players[src] ~= nil then
    ZMan.Players[src] = nil

    return
  end

  Utils.Logger.Debug(
    ("Error destroying a Player object! ~green~(%s)~white~ doesn't exist in our table!"):format(GetPlayerName(src))
  )
end

ZMan.Get = function(src)
  if ZMan.Players[src] ~= nil then
    return ZMan.Players[src]
  end

  Utils.Logger.Debug(("Cannot get ~green~%s's~white~ object! Doesn't exist on ~lblue~Players~white~ table!"):format(src))
end

ZMan.GetPlayers = function()
  return ZMan.Players
end

-- Item Management

ZMan.GetItems = function()
	return ZMan.Items
end

ZMan.AddItem = function(item, options)
	if ZMan.Items[item] ~= nil then
		return Utils.Logger.Error(("Item ~green~(%s)~white~ already exists in our Item table!"):format(item))
	end

	if options.label and options.weight and options.exclusive then
    Utils.Logger.Debug(
      ("Adding ~green~%s (%s) ~white~to the item list!"):format(options.label, item)
    )

		ZMan.Items[item] = options
		-- Add to database
	else
		Utils.Logger.Error(('Cannot add item ~green~%s~white~ because it has invalid options! Label: ~green~%s~white~ Weight: ~green~%s~white~ Exclusive: ~green~%s'):format(
			item, options.label or "Not Defined", options.weight or "Not Defined", options.exclusive or "Not Defined"
		))
	end
end

-- Job Management

ZMan.GetJobs = function()
	return ZMan.Jobs
end

ZMan.GetJob = function(job)
	if ZMan.Jobs[job] == nil then
		return Utils.Logger.Error(("Job ~green~(%s)~white~ is not a valid job! (Does not exist in Jobs table)"):format(job))
	end

  return ZMan.Jobs[job]
end

ZMan.RegisterJob = function(job, data)
	if ZMan.Jobs[job] ~= nil then
		return Utils.Logger.Error(("Job ~green~(%s)~white~ already exists in our Jobs table!"):format(job))
	end

	if data and data.label and data.grades and #data.grades > 0 then
		ZMan.Jobs[job] = data
		Utils.Logger.Debug(("Added job ~green~(%s)~white~ to the Jobs list!"):format(job))
	else
		Utils.Logger.Error(('Cannot add job ~green~(%s)~white~ because it has invalid options! Label: ~green~%s~white~ Grades: ~green~%s'):format(job, data.label or "Not Defined", data.grades or "Not Defined"))
	end
end

-- Command Handler

ZMan.RegisterCommand = function(cmd, cb, console, group)
  if cmd ~= nil and cmd ~= "" then
    if type(group) == "table" then
      for k, v in pairs(group) do
        ExecuteCommand(("add_ace zman.groups.%s zman.cmds.%s allow"):format(v, cmd))
      end
    end

    Utils.Logger.Debug(("Registered ~green~(%s)~white~ as an executable command."):format(cmd))

    ZMan.Commands[cmd] = { cb, console, group }

    RegisterCommand(cmd, function(source, args)
      -- Sanity checks
  
      if not console and source == 0 then
        return Utils.Logger.Warn(("Cannot execute ~green~%s~white~ from ~red~server's~white~ console"):format(cmd))
      end

      cb(source, args)
    end, (type(group) == "table"))
  end
end

-- Module Management (huge thanks to ESX Development team for their idea, take the credits <3)
-- This is very W.I.P yet, do not use YET

local Module = ZMan.Modules["main"]
Module.Category = { }

local moduleList = json.decode(LoadResourceFile(ZMan.Resource, "modules/modules.list.json"))

for k, v in pairs(moduleList) do
  if v ~= nil and v ~= "" and type(v) ~= string then
    Module.Category[v] = json.decode(LoadResourceFile(ZMan.Resource, ("modules/%s/modules.json"):format(v)))
  else
    Utils.Logger.Warn(
      ("File ~green~modules/modules.list.json~white~ contains an ~red~invalid~white~ module => ~lblue~(%s)")
      :format(v ~= nil and "Unnamed" or "Not Defined")
    )
  end
end

ZMan.CreateEnvironments = function(hierarchy, cb)
  local envs = { }

  -- Re-do this, wtf
  for k, v in pairs(Module.Category[hierarchy]) do
    -- There's no need for us to keep going if the Module is excluded
    if v:find("^exc.") then
      ZMan.Mods.Excluded = ZMan.Mods.Excluded + 1
      goto continue -- Weirdly Lua doesn't have a continue statement, so we use goto as a way to go around it
    end

    local env = { }

    env.name = v
    env.hierarchy = hierarchy
    env.module = { name = v, path = ("modules/%s/%s"):format(hierarchy, v) }
    env.fn = function()
      --[[ Load Module here ]]
    end

    if envs[v] == nil then
      envs[v] = env
    end

    Utils.Logger.Info(("Creating environment for ~green~%s/%s~white~ module."):format(hierarchy, v))
  
    ::continue::
  end

  cb(envs)
end

ZMan.CreateEnvironments("party", function(mods)
  ZMan.Mods.List = mods
  
  for k, v in pairs(mods) do
    v.fn()
  end

  Utils.Logger.Info(
    ("Successfuly loaded ~green~all~white~ modules => (~red~%i~white~ excluded)")
    :format(ZMan.Mods.Excluded), true
  )
end)

ZMan.LoadMod = function(mod, hierarchy)
  local error, modConfig = false, LoadResourceFile(ZMan.Resource, ("%s/%s/config.module.lua"):format(hierarchy, mod))

  if modConfig then
    if error then
      return Utils.Logger.Error(("There was an error loading ~lblue~(%s/%s)~white~ => ~red~https://pastebin.com/xy6H5fg"):format(hierarchy or "boot", mod), true)
    end

    Utils.Logger.Info(("Loaded ~lblue~(%s/%s)~white~ with success!"):format(hierarchy or "party", mod), true)
  end
end

ZMan.Mods.Stop = function(mod)
  if ZMan.Mods.List[mod] ~= nil then
    -- Stop module
    ZMan.Mods.List[mod] = nil

    Utils.Logger.Info(("Successfuly ~red~stopped~white~ a module => ~green~(%s)"):format(mod), true)
  end
end

ZMan.Database = MySQL.Async

Mod = ZMan.LoadMod

-- Maybe use "." as the separator for path? NaMeSpAcEs
-- This is used so we can use mod's functions in other modules
Mod("ems")
Mod("police")

-- In case you want to stop a module in real time, not sure if it's possible yet, but should be.
-- All we need is to unload the file from memory
ZMan.Mods.Stop("police")

-- Callback Handler

ZMan.RegisterCallback = function(name, cb)
  if ZMan.Callbacks[name] ~= nil then
    Utils.Logger.Warn(("There already exists a server callback named ~green~(%s)"):format(name))
    return
  else
    ZMan.Callbacks[name] = cb
    Utils.Logger.Debug(("Registered a new server callback ~green~(%s)"):format(name), true)
  end
end

RegisterNetEvent("__zm:server:callback:trigger")
AddEventHandler("__zm:server:callback:trigger", function(name, id, ...)
  local _source = source

  if ZMan.Callbacks[name] ~= nil then
    ZMan.Callbacks[name](_source, function(...)
      TriggerClientEvent('__zm:client:callback:return', _source, id, ...)
    end, ...)
    
    Utils.Logger.Debug(("%s triggered a server callback (%s) [%s]"):format(source, name, json.encode(...))) -- Dump?
  else
    Utils.Logger.Warn(("Callback ~red~(%s)~white~ does not exist in ~lblue~Callback~white~ table!"):format(name))
  end
end)