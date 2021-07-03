ZMan =
{
	Items = { },

	GetItems = function()
		return ZMan.Items
	end,

	AddItem = function(item, options)
		if ZMan.Items[item] ~= nil then
			return Utils.Logger.Debug(("Item (%s) already exists in our Item table!"):format(item))
		end

		if options.label and options.weight and options.exclusive then
			ZMan.Items[item] = options
			-- Add to database
		else
			Utils.Logger.Debug(('Cannot add item %s because it has invalid options! %s %s %s'):format(
				item, options.label, options.weight, options.exclusive
			))
		end
	end
}