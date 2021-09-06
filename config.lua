Config =
{
  ServerName = "ZimaN",
  Debug = true,
  AutoSaveTime = 2, -- In Minutes
  Queue = true, -- Use a custom queue system

  SpawnLocation = vector3(-428.6901, 1111.886, 327.6732),

  SpawnPeds = false, -- Should we spawn default GTA MP peds on the streets?

  UseIpl = nil,
  DefaultHabitat = vector3(266.0572, -1007.618, -101.0198),

  -- Player will be given these items upon first join
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

  Identifier = "license",
  BanType = "TOKEN",

  -- Static Data
  
  Items =
  {
    ["idcard"] =  { label = "Citizen Card",   weight = 0.1,   exclusive = true },
    ["phone"] =   { label = "Phone",          weight = 0.6,   exclusive = true },
    ["cookie"] =  { label = "Cookie",         weight = 0.2,   exclusive = true },
    ["water"] =   { label = "Water Bottle",   weight = 1.0,   exclusive = true }
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
