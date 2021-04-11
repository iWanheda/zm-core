local coordsBackup = nil

RegisterCommand( 'test', function( args )
	print(ZMan.Player.Data.Job)

	--Utils.Game.DrawBlip(
	--	{
	--		Coords = vector3( 123, 123, 123 ),
	--		Label = 'My First Blip!',
	--		Sprite = 303,
	--		Scale = 0.6,
	--		Color = 7,
	--		ShortRange = true
	--	}
	--)
--
	--print(GetEntityCoords( PlayerPedId() ))
--
	--while true do
	--	Citizen.Wait( 1 )
	--	Utils.Game.DrawWorldText(
	--		{
	--			Coords = GetEntityCoords( PlayerPedId() ),
	--			Font = 1,
	--			Color = { 255, 255, 255, 255 },
	--			Text = 'Fox é Gay'
	--		}
	--	)
	--end

	TriggerServerEvent( '__zm:test' )
end, false)

RegisterCommand( 'tpm', function( args )
	local waypointHandle = GetFirstBlipInfoId( 8 )

	if DoesBlipExist( waypointHandle ) then
		local waypointCoords = GetBlipInfoIdCoord( waypointHandle )
		coordsBackup = GetEntityCoords( PlayerPedId() )

		for height = 1, 1000 do
			SetPedCoordsKeepVehicle( PlayerPedId(), waypointCoords.x, waypointCoords.y, height + 0.0 )

			local foundGround, zPos = GetGroundZFor_3dCoord( waypointCoords.x, waypointCoords.y, height + 0.0 )

			if foundGround then
				SetPedCoordsKeepVehicle( PlayerPedId(), waypointCoords.x, waypointCoords.x, height + 0.0 )
				break
			end
			
			Citizen.Wait( 5 )
		end
	end
end )

RegisterCommand( 'back', function( args )
	if coordsBackup ~= nil then
		SetPedCoordsKeepVehicle( PlayerPedId(), coordsBackup.x, coordsBackup.y, coordsBackup.z + 0.7, false, false, false, false )
	end

	coordsBackup = nil
end )