ESX = nil

TriggerEvent(Config.SharedObject, function(obj) ESX = obj end)

RegisterServerEvent('dv_licenses:buy')
AddEventHandler('dv_licenses:buy', function(type, price)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= price then
        if type ~= "DriverLicense" then
            xPlayer.removeMoney(Config.DriverLicense.item_price)
            xPlayer.addInventoryItem(Config.DriverLicense.item_name, 1)
            if Config.UseDvNotify then
                TriggerClientEvent('dv_notify:alert', source, "You successfully bought a " ..ESX.GetItemLabel(Config.DriverLicense.item_name).."!", 5000, "71FF33", true)
            else
                xPlayer.showNotification("You successfully bought a " ..ESX.GetItemLabel(Config.DriverLicense.item_name).."!")
            end
        else
            xPlayer.removeMoney(Config.CardLicense.item_price)
            xPlayer.addInventoryItem(Config.CardLicense.item_name, 1)
            if Config.UseDvNotify then
                TriggerClientEvent('dv_notify:alert', source, "You successfully bought a " ..ESX.GetItemLabel(Config.CardLicense.item_name).."!", 5000, "71FF33", true)
            else
                xPlayer.showNotification("You successfully bought a " ..ESX.GetItemLabel(Config.CardLicense.item_name).."!")
            end  
        end
    else
        if Config.UseDvNotify then
            TriggerClientEvent('dv_notify:alert', source, "You don't have enought money!", 5000, "d31f37", true)
        else
            xPlayer.showNotification("You don't have enought money!")
        end  
    end
end)