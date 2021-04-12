local CPlayer = { }
CPlayer.__index = CPlayer

-- Create our actual Player instance
function CPlayer.Create( src )
	local self = setmetatable( { }, CPlayer )
	self.src = src

	return self
end

-- Get player's source
function CPlayer:GetSource()
	return self.src
end

-- Get player's rockstar identifier
function CPlayer:GetIdentifier()
	return tostring( GetPlayerIdentifier( self.src, 0 ) ):sub( 9 )
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
	return GetPlayerName( self.src )
end

-- Get player's coords
function CPlayer:GetPosition()
	return GetEntityCoords( GetPlayerPed( self.src ) )
end

-- Get player's base name (FiveM, Steam)
function CPlayer:ShowNotification( type, cap, msg, time )
	return TriggerClientEvent( '__zm:sendNotification', self.src, { t = type, c = cap, m = msg, ti = time } )
end

function CPlayer:UpdatePlayer( data )
	TriggerClientEvent( '__zm:updatePlayerData', self.src, data )
end

function CPlayer:SavePlayer()
	Utils.Logger.Info( ( 'Saved %i player(s)' ):format( Utils.Misc.TableSize( ZMan.GetPlayers() ) ) )
	Utils.Logger.Debug( ( 'Saved %s' ):format( self:GetBaseName() ) )

	local playerPos, playerIdentifier = self:GetPosition(), self:GetIdentifier()
	local x, y, z = playerPos.x, playerPos.y, playerPos.z

	MySQL.Async.execute( 'UPDATE users SET last_location = @last_location WHERE identifier = @id',
	{
		['@last_location'] = json.encode( { x, y, z } ),
		['@id'] = tostring( playerIdentifier )
	}, function() end )
end

-- Player management
ZMan = {
	Players = { },

	Instantiate = function( src )
		if ZMan.Players[src] == nil then
			Utils.Logger.Info( ( 'New player instantiated (%s)' ):format( src ) )
			-- TODO:
			--  Retrieve from Database
			ZMan.Players[src] = CPlayer.Create( src )
			
			return
		end

		Utils.Logger.Debug( ( 'Error instantiating a new Player object! (%s) already exists in the table!' ):format( GetPlayerName( src ) ) )
	end,

	Destroy = function( src )
		if ZMan.Players[src] ~= nil then
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
	end
}