Config =
{
  ServerName = "ZimaN",
  Debug = true,
  AutoSaveTime = 5, -- In Minutes
  Queue = true, -- Use a custom queue system
  MultiCharacters = false,
  EnablePvP = true,
  
  SpawnLocation = vector3(-428.6901, 1111.886, 327.6732),

  SpawnPeds = false, -- Should we spawn default GTA MP peds on the streets?

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

  Identifier = "license", -- Identifier Type: license, steam, discord, ip, live
  BanType = "token",

  -- Static Data
  
  Items =
  {
    ["idcard"] =        { label = "Citizen Card", weight = 0.1, type = "default" },
    ["creditcard"] =    { label = "Credit Card",  weight = 0.1, type = "default" },
    ["phone"] =         { label = "Phone",        weight = 0.6, type = "default" },
    ["cookie"] =        { label = "Cookie",       weight = 0.2, type = "consumable" },
    ["water"] =         { label = "Water Bottle", weight = 1.0, type = "consumable" }
  },

  -- What should new player's default group be?
  DefaultGroup = "regular",

  Groups =
  {
    ["admin"],
    ["moderator"],
    ["regular"]
  }
}