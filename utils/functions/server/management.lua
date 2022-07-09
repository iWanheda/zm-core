Utils.Management =
{
  GenCitizenId = function()
    math.randomseed(GetGameTimer())
    return (string.gsub("zxxyyxxy", "[xy]", function(c)
      return string.format("%x", (c == "x") and math.random(0, 0xF) or math.random(8, 0xB))
    end))
  end
}