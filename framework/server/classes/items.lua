ZMan.Items = {}

ZMan.GetItems = function()
	return ZMan.Items
end

ZMan.AddItem = function(item, options)
	if ZMan.Items[item] ~= nil then
		return Utils.Logger.Error(("Item (%s) already exists in our Item table!"):format(item))
	end

	if options.label and options.weight and options.exclusive then
    Utils.Logger.Debug(
      ("Adding %s%s (%s) ^7to the item list!"):format(Utils.Colors.Green, options.label, item)
    )

		ZMan.Items[item] = options
		-- Add to database
	else
		Utils.Logger.Error(('Cannot add item %s because it has invalid options! Label: ^3%s^7 Weight: ^3%s^7 Exclusive: ^3%s^7'):format(
			item, options.label or "Not Defined", options.weight or "Not Defined", options.exclusive or "Not Defined"
		))
	end
end