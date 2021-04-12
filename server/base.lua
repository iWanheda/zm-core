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

AddEventHandler( 'entityCreating', function()
	CancelEvent()
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
	local Player = ZMan.Get( source )

	if Player then
		Player:SavePlayer()
	end

	ZMan.Destroy( source )
end )

Citizen.CreateThread( function()
	while true do
		Citizen.Wait( Config.AutoSaveTime * 60000 ) 

		for k, v in pairs( ZMan.GetPlayers() ) do
			ZMan.Get( k ):SavePlayer()
		end
	end
end )

-- This also prevents the table from getting empty upon a script restart
RegisterNetEvent( '__zm:joined' )
AddEventHandler( '__zm:joined', function()
	ZMan.Instantiate( source )
	
	local _source = source
	local Player = ZMan.Get( source )

	MySQL.Async.fetchAll( 'SELECT * FROM users WHERE identifier = @id',
	{
		['@id'] = Player:GetIdentifier()
	}, function( res )
		if res[1] ~= nil then
			Utils.Logger.Debug( ( 'Great! We\'ve got %s\'s info!' ):format( Player:GetBaseName() ) )

			Player:UpdatePlayer(
				{
					last_location = res[1].last_location
				}
			)

			TriggerClientEvent( '__zm:playerLoaded', _source )
		else
			MySQL.Async.execute( 'INSERT INTO users VALUES( @id, @identity, @customization, @last_location )',
			{
				['@id'] = Player:GetIdentifier(),
				['@identity'] = '{ first_name = \'Zé\', last_name = \'Tomates\' }',
				['@customization'] = '{ }',
				['@last_location'] = '{ 12.94945, 12.63297, 70.62927 }'
			}, function()
				Utils.Logger.Debug( ( 'Added %s to the database!' ):format( Player:GetIdentifier() ) )
			end )
		end
	end )

	Player:ShowNotification( 'success', Config.ServerName, 'Welcome to the Server!' )
end )

RegisterCommand( 'coords', function( source )
	print( GetEntityCoords( GetPlayerPed( source ) ) )
end )