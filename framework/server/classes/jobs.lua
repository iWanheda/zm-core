ZMan.Jobs = {}

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
		return Utils.Logger.Error(("Job %s(%s)^7 already exists in our Jobs table!"):format(Utils.Colors.Green, job))
	end

	if data and data.label and data.grades and #data.grades > 0 then
		ZMan.Jobs[job] = data
		Utils.Logger.Debug(("Added job %s(%s)^7 to the Jobs list!"):format(Utils.Colors.Green, job))
		-- Add to database
	else
		Utils.Logger.Error(('Cannot add job %s because it has invalid options!'):format(job))
	end
end