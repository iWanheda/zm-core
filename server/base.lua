Citizen.CreateThread( function()
	if GetResourceState( 'hardcap' ) == 'started' then
		StopResource( 'hardcap' )
	end

	Utils.Logger.Info( 'ZimaN Framework, developed with ❤️' )
	Utils.Logger.Debug( '❗ Debug mode is active! This will spam a lot in your server/client\'s console.' )
end )

RegisterNetEvent( '__zm:test' )
AddEventHandler( '__zm:test', function()
	local Player = ZMan.Get( source )

	print(Utils.Misc.DumpTable(Player))
end )

--[[
	TODO:
	 Make Utils also apart of the ZMan object
	 Connect to database and deal with user, etc...
	 HTML >:[

	FIXME:
	 Apparently we're trying to delete Player instances everytime a player leaves the server, and that spams the console
	  if they haven't fully joined, I know the fix for it but meh
]]

RegisterNetEvent( '__zm:getLibrary' )
AddEventHandler( '__zm:getLibrary', function( lib )
	lib = ZMan
end )

AddEventHandler( 'playerConnecting', function( name, kickReason, def )
	--def.defer()
	Utils.Logger.Info( GetPlayerName( source ) .. ' is joining the server.' )
end )

AddEventHandler( 'playerDropped', function( reason )
	ZMan.Destroy( source )
end )

-- This also prevents the table from getting empty upon a script restart
RegisterNetEvent( '__zm:joined' )
AddEventHandler( '__zm:joined', function()
	ZMan.Instantiate( source )

	local Player = ZMan.Get( source )

	MySQL.Async.fetchAll( 'SELECT * FROM users WHERE identifier = @id',
	{
		['@id'] = Player:GetIdentifier()
	}, function( res )
		if res[1] ~= nil then
			Utils.Logger.Debug( ( 'Great! We\'ve got %s\'s info!' ):format( Player:GetBaseName() ) )
		else
			MySQL.Async.execute( 'INSERT INTO users VALUES( @id, @identity, @customization, @last_location )',
			{
				['@id'] = Player:GetIdentifier(),
				['@identity'] = '{ first_name = \'Zé\', last_name = \'Tomates\' }',
				['@customization'] = '{ }',
				['@last_location'] = '{ 123, 123, 123 }'
			}, function()
				Utils.Logger.Debug( ( 'Added %s to the database!' ):format( Player:GetIdentifier() ) )
			end )
		end
	end )

	ZMan.UpdatePlayer( source )

	Player:ShowNotification( 'success', Config.ServerName, 'Welcome to the Server!' )
end )