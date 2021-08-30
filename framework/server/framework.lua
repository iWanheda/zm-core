ZMan = { }

ZMan.Players = { }
ZMan.Items = { }
ZMan.Jobs = { }
ZMan.Commands = { }

-- Player management

ZMan.Instantiate = function(src, inv, pos)
  if ZMan.Players[src] == nil then
    -- Append new Player instance to player list
    local Player = CPlayer.Create(src, inv, pos, group)
    ZMan.Players[src] = Player

    ExecuteCommand(('add_principal identifier.license:%s group.%s'):format(Player:GetIdentifier(), Player:GetGroup()))

    Utils.Logger.Info(("New player instantiated ~green~(%s)~white~ with ID ~green~%s"):format(Player:GetBaseName(), src))

    return Player
  end

  Utils.Logger.Debug(
    ("Error instantiating a new Player object! (%s) already exists in the table!"):format(GetPlayerName(src))
  )
end

ZMan.Destroy = function(src)
  if ZMan.Players[src] ~= nil then
    ZMan.Players[src] = nil

    return
  end

  Utils.Logger.Debug(
    ("Error destroying a Player object! (%s) doesn't exist in our table!"):format(GetPlayerName(src))
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
		return Utils.Logger.Error(("Item (%s) already exists in our Item table!"):format(item))
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
		return Utils.Logger.Error(("Job (%s) is not a valid job! (Does not exist in Jobs table)"):format(job))
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
		Utils.Logger.Error(('Cannot add job %s because it has invalid options! Label: ~green~%s~white~ Grades: ~green~%s'):format(job, data.label or "Not Defined", data.grades or "Not Defined"))
	end
end

-- Command Handler

ZMan.RegisterCommand = function(cmd, cb, console, group)
  if cmd ~= nil and cmd ~= "" then
    if type(group) == "table" then
      for k, v in pairs(group) do
        ExecuteCommand(("add_ace zman.groups.%s zman.cmds.%s allow"):format(v or "regular", cmd))
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