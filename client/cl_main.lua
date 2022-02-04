ESX = nil
local opened = true

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent(Config.SharedObject, function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function openNui()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "show",
        cardPrice = Config.CardLicense.item_price,
        driverPrice = Config.DriverLicense.item_price
    })
end

function closeNui()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "hide",
    })
end

RegisterNUICallback('report', function(data)
    TriggerServerEvent('dv_licenses:send', data)
    Notification("Report Sent!")
end)

RegisterNUICallback('buy', function(data)
    TriggerServerEvent('dv_licenses:buy', data.type, data.price)
end)

RegisterNUICallback('close', function(data, cb)
	SetNuiFocus(false, false)
    opened = true
end)

Citizen.CreateThread(function()
	Citizen.Wait(10000)
	RequestModel(Config.PedModel)
	while not HasModelLoaded(Config.PedModel) do
		Wait(500)
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(25000)
    if Config.UseNPC then 
    	for _, item in pairs(Config.Locations) do
            local npc = CreatePed(4, GetHashKey(Config.PedModel), item.x, item.y, item.z-1.0, item.heading, false, true)
            FreezeEntityPosition(npc, true)	
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            RequestAnimDict("anim@amb@nightclub@peds@")
            while not HasAnimDictLoaded("anim@amb@nightclub@peds@") do
            Citizen.Wait(1000)
            end				
            Citizen.Wait(200)
            TaskPlayAnim(npc,"anim@amb@nightclub@peds@","amb_world_human_stand_guard_male_base",1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
        end
    end
end)

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
                    dist = GetDistanceBetweenCoords(coords, vector3(item.x, item.y, item.z), true)
                    
                    if dist < 5.2 then
                        ESX.Game.Utils.DrawText3D({x = item.x, y = item.y, z = item.z+0.95}, item.name, 0.6, 0.7)
                    end
                    
                    if dist < minDist then minDist = dist end
                end
		
                if minDist > 10 then
                    Citizen.Wait(minDist*10)
                end
            end
        end
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local pos = GetEntityCoords(GetPlayerPed(-1))
			for _, item in pairs(Config.Locations) do
       		if (GetDistanceBetweenCoords(pos, item.x, item.y, item.z, true) < 1.5) then
					drawOn(1.255, 1.562, 1.0,1.0,0.35, "~w~["..Config.KeyName.."] " .. Config.Text, 255, 255, 255, 255)
                if IsControlJustReleased(1, Config.Key) then
                    openNui()
                end
            end
            if not Config.PerformanceMode then
                if (GetDistanceBetweenCoords(pos, item.x, item.y, item.z, true) < 5) then
                    DrawMarker(6, item.x, item.y, item.z - 1.0, 0.0, 0.0, 0.2, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 0, 0, 100, false, false, 2, false, false, false, false)
                end
		    end
        end
	end
end)

function drawOn(x,y,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(Config.DrawTxtFont)
    SetTextProportional(0)
    SetTextScale(0.4, 0.4)
	SetTextColour( 0,0,0, 255 )
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(0, 0, 0, 0, 255)
    SetTextDropShadow()
	SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/1.255, y - height/1 + 0.374)
end
