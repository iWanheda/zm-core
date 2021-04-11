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

	Pressed = function( key )
		return IsControlJustPressed( 0, key )
	end,

	Released = function( key )
		return IsControlJustReleased( 0, key )
	end
}