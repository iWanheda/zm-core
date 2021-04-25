Utils.Game.Input =
{
	Keys = 
	{
		A = 34,
		B = 29,
		C = 26,
		D = 30,
		E = 51,
		F = 23,
		G = 47,
		H = 74,
		I = 00,
		J = 00,
		K = 311
	},

	Binds = { },

	Pressed = function( key )
		return IsControlJustPressed( 0, key )
	end,

	Released = function( key )
		return IsControlJustReleased( 0, key )
	end,

	BindKey = function( key, command, desc )
		Utils.Game.Input.Binds[command] = false

		RegisterCommand( ( '+%s' ):format( command ), function()
			Utils.Game.Input.Binds[command] = true
		end, false )

		RegisterCommand( ( '-%s' ):format( command ), function()
			Utils.Game.Input.Binds[command] = false
		end, false )

		RegisterKeyMapping( ( '+%s' ):format( command ), desc or '', 'keyboard', key )
	end,

	GetBindStatus = function( command )
		return Utils.Game.Input.Binds[command]
	end
}

-- TODO:
-- Pass the function automatically so we don't have to fucking check it manually.
-- Hello future me you lazy fuck, do this and stop laying down 24/7 you moron.
-- WTF is this keymap system am I stupid?? Re-do this.

Utils.Game.Input.BindKey( 'f1', 'test', 'Cona' )

Citizen.CreateThread( function()
	while true do
		Citizen.Wait( 100 )

		if Utils.Game.Input.GetBindStatus( 'test' ) then
			print('cona')
		end
	end
end )