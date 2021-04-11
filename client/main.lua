TriggerServerEvent( '__zm:joined' )

RegisterNetEvent( '__zm:getLibrary' )
AddEventHandler( '__zm:getLibrary', function( cb )
	cb( ZMan )
end )

-- Set default Ped model

local pedModel = `mp_m_freemode_01`

Citizen.CreateThread( function()
	Utils.Logger.Debug( ('Changing Player\'s ped to: %s'):format( pedModel ) )

	RequestModel( pedModel )
	while not HasModelLoaded( pedModel ) do
		RequestModel( pedModel )
		Citizen.Wait( 1 )
	end

	SetPedDefaultComponentVariation( GetPlayerPed() )
end )

Citizen.CreateThread( function()
	while true do
		Citizen.Wait( 4 )
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
				armor = GetPedArmour( PlayerPedId() )
			} )
		)
	end
end )

RegisterNUICallback( 'ui/close', function( data, cb )
	SetNuiFocus( false, false )
end )