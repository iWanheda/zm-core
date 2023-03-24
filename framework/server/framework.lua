ZMan = { }

GetMachineOS = function()
  local fh, err = assert(io.popen("uname -o 2>/dev/null", "r"))
  if fh then
    osname = fh:read()
  end

  return osname or "Windows"
end

-- Caches
ZMan.Resource = GetCurrentResourceName() -- Let's cache it! :]
ZMan.MachineOS = GetMachineOS()

ZMan.Players = { }
ZMan.Items = { }
ZMan.Jobs = { }
ZMan.Commands = { }
ZMan.Callbacks = { }
ZMan.Drops = { }

ZMan.Mods = { }

-- Modules
ZMan.Modules = { ["main"] = { } }
ZMan.Mods.Excluded = 0
ZMan.Mods.Fatal = 0

-- Player management

ZMan.Instantiate = function(src, cid, inv, ident, pos, job, grade, group)
  if ZMan.Players[src] == nil then
    -- Append new Player instance to player list
    local Player = CPlayer.Create(src, cid, inv, ident, pos, job, grade, group)
    ZMan.Players[src] = Player

    -- Not sure if I have to add principal everytime a player joins?
    --ExecuteCommand(("add_principal identifier.license:%s group.%s"):format(Player:GetIdentifier(), Player:GetGroup()))

    Utils.Logger.Debug(("New player instantiated ~green~(%s)~white~ => ~green~%s"):format(Player:GetBaseName(), src))

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

ZMan.GetPlayers = function(job)
  if job ~= nil then
    if ZMan.Jobs[job] ~= nil then
      local _Players = { }

      for k, v in pairs(ZMan.Players) do
        if v.GetJob() == job then
          table.insert(_Players, v)
        end
      end
    end

    return _Players
  end
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

	if options.label and options.weight and options.exclusive ~= nil then
    Utils.Logger.Debug(
      ("Adding ~green~%s (%s) ~white~to the item list!"):format(options.label, item)
    )

		ZMan.Items[item] = options
		-- Add to database
	else
		Utils.Logger.Error(("Cannot add item ~green~%s~white~ because it has invalid options! Label: ~green~%s~white~ Weight: ~green~%s~white~ Exclusive: ~green~%s"):format(
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
		Utils.Logger.Error(("Job ~green~(%s)~white~ is not a valid job! (Does not exist in Jobs table)"):format(job))
    return
  end

  return ZMan.Jobs[job]
end

ZMan.RegisterJob = function(job, data)
	if ZMan.Jobs[job] ~= nil then
		Utils.Logger.Error(("Job ~green~(%s)~white~ already exists in our Jobs table!"):format(job))
    return
  end

	if data and data.label and data.grades and #data.grades > 0 then
		ZMan.Jobs[job] = data
		Utils.Logger.Debug(("Added job ~green~(%s)~white~ to the Jobs list!"):format(job))
	else
		Utils.Logger.Error(("Cannot add job ~green~(%s)~white~ because it has invalid options! Label: ~green~%s~white~ Grades: ~green~%s"):format(job, data.label or "Not Defined", data.grades or "Not Defined"))
	end
end

-- Command Handler

ZMan.RegisterCommand = function(cmd, cb, console, group, suggestions)
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

    if suggestions and type(suggestions) == "table" then
      local cmdParams = { }

      for k, v in pairs(suggestions) do
        if v.name ~= nil and v.desc ~= nil then
          table.insert(cmdParams, { name = v.name, help = v.desc })
        end
      end

      TriggerEvent('chat:addSuggestion', ("/%s"):format(cmd), 
        suggestions.helpText ~= nil and suggestions.helpText or "", cmdParams)
    end

    if suggestions == nil then
      --TriggerEvent('chat:removeSuggestion', ("/%s"):format(cmd))
    end
  end
end

-- Module Management (huge thanks to ESX Development team for their idea, take the credits <3)
-- This is very W.I.P yet, do not use YET

local Module = ZMan.Modules["main"]
Module.Category = {
  ["default"] = json.decode(LoadResourceFile(ZMan.Resource, "modules/default/modules.json")),
  ["community"] = json.decode(LoadResourceFile(ZMan.Resource, "modules/community/modules.json"))
}

local cancer = { }
if ZMan.MachineOS == "Windows" then
  for dir in io.popen(("dir \"%s\\modules\\default\\staff\\server\" /b"):format(GetResourcePath(ZMan.Resource))):lines() do table.insert(cancer, dir) end
else
  for dir in io.popen([[ls -pa /home/user | grep -v /]]):lines() do print(dir) end
end

local totalModules = 0
ZMan.CreateEnvironments = function(hierarchy, cb)
  local envs = { }

  local resPath = GetResourcePath(ZMan.Resource)
  Citizen.CreateThread(function()
    while not ZMan.Ready do
      Citizen.Wait(1)
    end

    for k, mod in pairs(Module.Category[hierarchy]) do
      local env = { }

      local serverModules, sharedModules, clientModules = { }, { }, { }
      if ZMan.MachineOS == "Windows" then
        for dir in io.popen(("dir \"%s\\modules\\%s\\%s\\server\" /b"):format(resPath, hierarchy, mod)):lines() do table.insert(serverModules, dir) end
        for dir in io.popen(("dir \"%s\\modules\\%s\\%s\\client\" /b"):format(resPath, hierarchy, mod)):lines() do table.insert(clientModules, dir) end
        for dir in io.popen(("dir \"%s\\modules\\%s\\%s\\shared\" /b"):format(resPath, hierarchy, mod)):lines() do table.insert(sharedModules, dir) end
      else
        for dir in io.popen([[ls -pa /home/user | grep -v /]]):lines() do print(dir) end
      end

      env.name = mod
      env.hierarchy = hierarchy
      env.module = { name = mod, path = ("modules/%s/%s"):format(hierarchy, mod) }
      env.clientMods = clientModules or { }
      env.sharedMods = sharedModules or { }
      env.fn = function()
        -- Load shared first
        for _, shrdModule in pairs(sharedModules) do
          local sharedContent = LoadResourceFile(ZMan.Resource, 
            ("modules/%s/%s/shared/%s"):format(hierarchy, mod, shrdModule))

          local sharedCode, sharedErr = load(sharedContent ~= nil and sharedContent or "")

          if sharedErr then
            ZMan.Mods.Fatal = ZMan.Mods.Fatal + 1
  
            Utils.Logger.Error(
              ("An ~red~exception~white~ was thrown while loading ~red~%s/shared/%s~white~, stack trace: ~yellow~\n\t-> %s")
              :format(env.name, shrdModule, sharedErr)
            )
            
            goto continue
          end

          pcall(sharedCode)
        end

        for _, svModule in pairs(serverModules) do
          local serverContent = LoadResourceFile(ZMan.Resource, 
            ("modules/%s/%s/server/%s"):format(hierarchy, mod, svModule))
            
          local serverCode, serverErr = load(serverContent ~= nil and serverContent or "")

          if serverErr then
            ZMan.Mods.Fatal = ZMan.Mods.Fatal + 1
  
            Utils.Logger.Error(
              ("An ~red~exception~white~ was thrown while loading ~red~%s/server/%s~white~, stack trace: ~yellow~\n\t-> %s")
              :format(env.name, svModule, serverErr)
            )
            
            goto continue
          end

          pcall(serverCode)
        end

        totalModules = totalModules + 1
        Utils.Logger.Debug(("Creating environment for ~green~%s/%s~white~ module."):format(hierarchy, mod))

        ::continue::
      end

      if envs[mod] == nil then
        envs[mod] = env
      end

      ::continue::
    end

    cb(envs)
  end)
end

ZMan.CreateEnvironments("default", function(mods)
  ZMan.Mods.List = mods
  
  for k, mod in pairs(mods) do
    mod.fn() -- Run the module's code
  end

  if ZMan.Mods.Fatal > 0 then
    Utils.Logger.Info(
      ("Successfuly loaded ~green~%s~white~ modules => (~red~%i~white~ fatal)")
      :format(totalModules, ZMan.Mods.Fatal), true
    )
  else
    Utils.Logger.Info("Successfuly loaded ~green~all~white~ modules", true)
  end
end)

-- Callback Handler

ZMan.RegisterCallback = function(name, cb)
  if ZMan.Callbacks[name] ~= nil then
    Utils.Logger.Warn(("Replacing an existent callback ~green~(%s)~white~ from ~green~%s"):format(name, GetInvokingResource()))
  else
    Utils.Logger.Debug(("Registered a new server callback ~green~(%s)"):format(name), true)
  end

  ZMan.Callbacks[name] = cb
end

RegisterNetEvent("__zm:server:callback:trigger", function(name, id, ...)
  local _source = source

  if ZMan.Callbacks[name] ~= nil then
    ZMan.Callbacks[name](_source, ...)
    TriggerClientEvent("__zm:client:callback:return", _source, id, ...) 
    
    Utils.Logger.Debug(("~green~%s ~white~triggered a server callback ~green~(%s) [%s]"):format(source, name, json.encode(...))) -- Dump?
  else
    Utils.Logger.Warn(("Callback ~red~(%s)~white~ does not exist in ~lblue~Callback~white~ table!"):format(name))
  end
end)