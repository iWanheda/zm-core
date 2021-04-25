Utils.Logger = {
	Info = function ( log )
		if log ~= nil then
			print( ( '< %s > %s(INFO)%s - %s^7' ):format( Config.ServerName, Utils.Colors.DBlue, Utils.Colors.White, log ) )
		end
	end,

	Error = function ( log )
		if log ~= nil then
			print( ( '< %s > %s(ERROR)%s - %s^7' ):format( Config.ServerName, Utils.Colors.Red, Utils.Colors.White, log ) )
		end
	end,

	Warn = function ( log )
		if log ~= nil then
			print( ( '< %s > %s(WARNING)%s - %s^7' ):format( Config.ServerName, Utils.Colors.Yellow, Utils.Colors.White, log ) )
		end
	end,

	Debug = function ( log )
		if log ~= nil and Config.Debug == true then
			print( ( '< %s > %s(DEBUG)%s - %s^7' ):format( Config.ServerName, Utils.Colors.LBlue, Utils.Colors.White, log ) )
		end
	end
}