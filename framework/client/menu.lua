CMenu = { }
CMenu.__index = CMenu

-- Create our actual Menu instance
function CMenu.Create(title)
  local self = setmetatable({ }, CMenu)

  math.randomseed(GetGameTimer())
  local uuid = string.gsub("xyxy-xyxy", "[xy]", function(c)
    return string.format("%x", (c == "x") and math.random(0, 0xF) or math.random(8, 0xB))
  end)

  Utils.Logger.Debug(("New ~lblue~Menu~white~ instance created with identifier => ~green~(%s)"):format(uuid))
  
  self.uuid = uuid
  self.title = title or uuid
  self.open = false

  return self
end

function CMenu:SetTitle(title)
  self.title = title
end

function CMenu:Open()
  self.open = true

  SendNuiMessage(json.encode({
    type = "__zman:internal:menu:open",
    data = self
  }))
end

function CMenu:Close()
  self.open = false
end

function CMenu:Toggle()
  --(self.open ~= true and self:Close() or self:Open())
end

local Menu = CMenu.Create()

Menu:SetTitle("Example Menu")