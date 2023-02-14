local ESX = nil
local opened = false
local cardPrice = Config.CardLicense.item_price
local driverPrice = Config.DriverLicense.item_price

-- Wait for ESX to be initialized before proceeding
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent(Config.SharedObject, function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Open and close NUI
function openNui()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "show",
        cardPrice = cardPrice,
        driverPrice = driverPrice
    })
    opened = true
end

function closeNui()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "hide",
    })
    opened = false
end

-- Handle NUI callbacks
RegisterNUICallback('report', function(data)
    TriggerServerEvent('dv_licenses:send', data)
    ESX.ShowNotification("Report sent!")
end)

RegisterNUICallback('buy', function(data)
    TriggerServerEvent('dv_licenses:buy', data.type, data.price)
end)

RegisterNUICallback('close', function(data, cb)
    closeNui()
end)

-- Load NPC model
Citizen.CreateThread(function()
    Citizen.Wait(10000)
    RequestModel(Config.PedModel)
    while not HasModelLoaded(Config.PedModel) do
        Citizen.Wait(500)
    end
end)

-- Spawn NPCs at locations specified in Config
Citizen.CreateThread(function()
    Citizen.Wait(25000)
    if Config.UseNPC then 
        for _, item in pairs(Config.Locations) do
            local npc = CreatePed(4, GetHashKey(Config.PedModel), item.x, item.y, item.z - 1.0, item.heading, false, true)
            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            RequestAnimDict("anim@amb@nightclub@peds@")
            while not HasAnimDictLoaded("anim@amb@nightclub@peds@") do
                Citizen.Wait(1000)
            end
            Citizen.Wait(200)
            TaskPlayAnim(npc, "anim@amb@nightclub@peds@", "amb_world_human_stand_guard_male_base", 1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
        end
    end
end)

-- Check if player is near a license location
Citizen.CreateThread(function()
    Citizen.Wait(25000)
    while true do
        Citizen.Wait(5)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local minDist = 1000
        local dist = 0

        if Config.UseNPC then 
            if not Config.PerformanceMode then
                for _, item in pairs(Config.Locations) do
                    dist = #(coords - vector3(item.x, item.y, item.z))
                    
                    if dist < 5.2 then
                        ESX.Game.Utils.DrawText3D({x = item.x, y = item.y, z = item.z + 0.95}, item.name, 0.6, 0.7)
                    end
                    
                    if dist < minDist then 
                    minDist = dist 
                end
            end
	
            if minDist > 10 then
                Citizen.Wait(minDist * 10)
            end
        end
    end
end
end)

-- Draw text on screen indicating how to open the NUI
Citizen.CreateThread(function()
while true do
Citizen.Wait(0)
local pos = GetEntityCoords(PlayerPedId())
for _, item in pairs(Config.Locations) do
local dist = #(pos - vector3(item.x, item.y, item.z))
        if dist < 1.5 then
            DrawText3D(vector3(item.x, item.y, item.z + 1.0), "[" .. Config.KeyName .. "] " .. Config.Text, 0.4)
            if IsControlJustReleased(1, Config.Key) and not opened then
                openNui()
            end
        end
        
        if not Config.PerformanceMode and dist < 5 then
            DrawMarker(6, item.x, item.y, item.z - 1.0, 0.0, 0.0, 0.2, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 0, 0, 100, false, false, 2, false, false, false, false)
        end
    end
end
end)

-- Helper function to draw text in 3D space
function DrawText3D(coords, text, scale)
local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
local px, py, pz = table.unpack(GetGameplayCamCoords())
SetTextScale(scale, scale)
SetTextFont(Config.DrawTxtFont)
SetTextProportional(1)
SetTextColour(255, 255, 255, 215)
SetTextEntry("STRING")
SetTextCentre(1)
AddTextComponentString(text)
DrawText(x, y)
local factor = (string.len(text)) / 350
DrawRect(x, y + 0.0125, 0.02 + factor, 0.03, 41, 11, 41, 68)
end
