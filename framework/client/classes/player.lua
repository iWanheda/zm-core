ZMan =
{
    Player =
    {
        Data = { }
    },

    UpdateData = function(key, value)
        ZMan.Player.Data[tostring(key)] = json.decode(value)
    end,
    
    ShowNotification = function(type, cap, message, time)
        if type == "info" then
            exports["swt_notifications"]:Info(cap or "", message or "", "top", time or 2500, true)
        elseif type == "success" then
            exports["swt_notifications"]:Success(cap or "", message or "", "top", time or 2500, true)
        elseif type == "warn" then
            exports["swt_notifications"]:Warning(cap or "", message or "", "top", time or 2500, true)
        elseif type == "error" then
            exports["swt_notifications"]:Negative(cap or "", message or "", "top", time or 2500, true)
        end
    end
}

RegisterNetEvent("__zm:sendNotification")
AddEventHandler(
    "__zm:sendNotification",
    function(data)
        ZMan.ShowNotification(data.t, data.c, data.m, data.ti)
    end
)

RegisterNetEvent("__zm:updatePlayerData")
AddEventHandler(
    "__zm:updatePlayerData",
    function(data)
        for k, v in pairs(data) do
            Utils.Logger.Debug(("Updating %s%s -> %s%s"):format(Utils.Colors.Green, k, Utils.Colors.Green, v))

            ZMan.UpdateData(k, v)
        end
    end
)
