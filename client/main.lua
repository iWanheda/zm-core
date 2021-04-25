TriggerServerEvent( '__zm:joined' )

RegisterNetEvent( '__zm:getLibrary' )
AddEventHandler( '__zm:getLibrary', function( cb )
	cb( ZMan )
end )

-- Set default Ped model

local pedModel = `mp_m_freemode_01`

RegisterNetEvent( '__zm:playerLoaded' )
AddEventHandler( '__zm:playerLoaded', function()
	SetEntityCoords( PlayerPedId(), 
		ZMan.Player.Data.last_location[1],
		ZMan.Player.Data.last_location[2], 
		ZMan.Player.Data.last_location[3],
		false, false, false, false
	)
end )

Citizen.CreateThread( function()
	Utils.Logger.Debug( ('Changing Player\'s ped to: %s'):format( pedModel ) )

	-- If Data still hasn't been loaded into memory, let's wait.
	while Utils.Misc.TableSize( ZMan.Player.Data ) == 0 do
		Citizen.Wait( 1 )
	end

	RequestModel( pedModel )
	while not HasModelLoaded( pedModel ) do
		RequestModel( pedModel )
		Citizen.Wait( 1 )
	end

	exports.spawnmanager:setAutoSpawn( false )

	local playerPos = ZMan.Player.Data.last_location

	exports.spawnmanager:spawnPlayer(
	{
		x = playerPos[1],
		y = playerPos[2],
		z = playerPos[3],
		heading = 0.0,
		--model = 'mp_m_freemode_01',
		skipFade = false
	} )

	SendNuiMessage( json.encode
		( { 
			type = 'ZMan/closeLoading'
		} )
	)
	Citizen.Wait( 2 )
	ShutdownLoadingScreenNui()

	SetPedDefaultComponentVariation( GetPlayerPed() )

	-- Let's setup our Hud, hide default GTA health component
	local minimap = RequestScaleformMovie( 'minimap' )
	SetRadarBigmapEnabled( true, false )

	Wait( 0 )

	SetRadarBigmapEnabled(false, false)

	Wait( 100 )

	BeginScaleformMovieMethod( minimap, 'SETUP_HEALTH_ARMOUR' )
	ScaleformMovieMethodAddParamInt( 3 )
	EndScaleformMovieMethod()
end )

Citizen.CreateThread( function()
	while true do
		Citizen.Wait( 4 )
		SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)

		if Utils.Game.Input.Pressed( Utils.Game.Input.Keys.K ) then
			SetNuiFocus( true, true )
		end
	end
end )

Citizen.CreateThread( function()
	while true do
		Citizen.Wait( 1500 )
		SendNuiMessage( json.encode
			( { 
				type = 'ZMan/updateUi', 
				health = GetEntityHealth( PlayerPedId() ),
				maxHealth = GetEntityMaxHealth( PlayerPedId() ),
				armor = GetPedArmour( PlayerPedId() ),
				cash = 12834,
				bankMon = 7377223,
				dirtyMon = GetPlayerServerId( PlayerId() )
			} )
		)
	end
end )

RegisterNUICallback( 'ui/close', function( data, cb )
	SetNuiFocus( false, false )
end )

RegisterCommand( 'sethealth', function( source, args )
	SetEntityHealth( PlayerPedId(), tonumber( args[1] * 2 ) ) -- Aparently GTA's health system is retarded.
end, false )