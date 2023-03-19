Config =
{
  ServerName = "ZimaN",
  Debug = true,
  AutoSaveTime = 5, -- In Minutes
  Queue = true, -- Use a custom queue system
  MultiCharacters = false,
  EnablePvP = true,
  
  SpawnLocation = vector3(-428.6901, 1111.886, 327.6732),

  SpawnPeds = true, -- Should we spawn default GTA MP peds on the streets?

  -- Players will be given these items upon first join
  DefaultInventory =
  {
    idcard = 1,
    phone = 1,
    cookie = 5,
    water = 5
  },
    
  MoneyTypes = 
  {
    cash = 1100,
    bank = 35000,
    crypto = 0
  },

  Identifier = "discord",
  BanType = "token",

  -- Static Data
  
  Items =
  {
    ["idcard"] =  { label = "Citizen Card",   weight = 0.1,   exclusive = false },
    ["phone"] =   { label = "Phone",          weight = 0.6,   exclusive = false },
    ["cookie"] =  { label = "Cookie",         weight = 0.2,   exclusive = false },
    ["water"] =   { label = "Water Bottle",   weight = 1.0,   exclusive = false }
  },

  -- What should new player's default group be?
  DefaultGroup = "regular",

  Groups =
  {
    ["admin"] = true,
    ["moderator"] = true,
    ["regular"] = true
  }
}
