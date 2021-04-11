local CPlayer = { }
CPlayer.__index = CPlayer

-- Create our actual Player instance
function CPlayer.Create( src, firstname, lastname, age )
	local self = setmetatable( { }, CPlayer )

	self.source = src
	self.firstname = firstname
	self.lastname = lastname
	self.age = age

	return self
end

-- Get player's source
function CPlayer:GetSource()
	return self.source
end

-- Get player's rockstar identifier
function CPlayer:GetIdentifier()
	return tostring( GetPlayerIdentifier( self.source, 0 ) ):sub( 9 )
end

-- Get player's name
function CPlayer:GetName()
	return { first = self.firstname, last = self.lastname }
end

-- Get player's age
function CPlayer:GetAge()
	return self.age
end

-- Get player's base name (FiveM, Steam)
function CPlayer:GetBaseName()
	return GetPlayerName( self.source )
end

-- Get player's base name (FiveM, Steam)
function CPlayer:ShowNotification( type, cap, msg, time )
	return TriggerClientEvent( '__zm:sendNotification', self.source, { t = type, c = cap, m = msg, ti = time } )
end

-- Player management

ZMan = {
	Players = { },

	Instantiate = function( src )
		if ZMan.Players[src] == nil then
			Utils.Logger.Info( ( 'New player instantiated (%s)' ):format( src ) )
			-- TODO:
			--  Retrieve from Database
			ZMan.Players[src] = CPlayer.Create( src, 'John', 'Doe', 345 )
			
			return
		end

		Utils.Logger.Debug( ( 'Error instantiating a new Player object! (%s) already exists in the table!' ):format( GetPlayerName( src ) ) )
	end,

	Destroy = function( src )
		if ZMan.Players[src] ~= nil then
			Utils.Logger.Info( ( 'Saved %s' ):format( GetPlayerName( source ) ) )
			ZMan.Players[src] = nil

			return
		end

		Utils.Logger.Debug( ( 'Error destroying a Player object! (%s) doesn\'t exist in our table!' ):format( GetPlayerName( src ) ) )
	end,

	Get = function( src )
		if ZMan.Players[src] ~= nil then
			return ZMan.Players[src]
		end

		Utils.Logger.Debug( ( 'Cannot get %s\'s object! Doesn\'t exist on Players table!' ):format( GetPlayerName( source ) ) )
	end,

	GetPlayers = function()
		return ZMan.Players
	end,

	UpdatePlayer = function( source )
		TriggerClientEvent( '__zm:updatePlayerData', source, { Job = 'Bombeiro' } )
	end
}