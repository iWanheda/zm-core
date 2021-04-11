Utils.Logger = {
	Info = function ( log )
		if log ~= nil then
			print( '< ' .. Config.ServerName .. ' > ' .. Utils.Colors.DBlue .. '(INFO)' .. Utils.Colors.White .. ' - ' .. log )
		end
	end,

	Error = function ( log )
		if log ~= nil then
			print( '< ' .. Config.ServerName .. ' > ' .. Utils.Colors.Red .. '(ERROR)' .. Utils.Colors.White .. ' - ' .. log )
		end
	end,

	Warn = function ( log )
		if log ~= nil then
			print( ( '< %s > %s(WARNING)%s - %s' ):format( Config.ServerName, Utils.Colors.Yellow, Utils.Colors.White, log ) )
		end
	end,

	Debug = function ( log )
		if log ~= nil and Config.Debug == true then
			print( ( '< %s > %s(DEBUG)%s - %s' ):format( Config.ServerName, Utils.Colors.LBlue, Utils.Colors.White, log ) )
		end
	end
}