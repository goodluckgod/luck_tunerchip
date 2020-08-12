-- Original Author: Elipse
-- Modified by: ModFreakz
-- For support, previews and showcases, head to https://discord.gg/ukgQa5K

local menu = false
ESX = nil

function getVehData(veh)
    if not DoesEntityExist(veh) then return nil end
    local lvehstats = {
        boost = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce"),
        fuelmix = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia"),
        braking = GetVehicleHandlingFloat(veh ,"CHandlingData", "fBrakeBiasFront"),
        drivetrain = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront"),
        brakeforce = GetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce")
    }
    return lvehstats
end

function setVehData(veh,data)
    if not DoesEntityExist(veh) or not data then return nil end
    SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", data.boost*1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", data.fuelmix*1.0 )
    SetVehicleEnginePowerMultiplier(veh, data.gearchange*1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", data.braking*1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", data.drivetrain*1.0)
    SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce", data.brakeforce*1.0)
    TriggerServerEvent('tuning:SetData',data,ESX.Game.GetVehicleProperties(veh))
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(1000)
	end

	PlayerData = ESX.GetPlayerData()
end)

function toggleMenu(b,send)
    local vehData = getVehData(GetVehiclePedIsIn(GetPlayerPed(-1),false))
    if send then SendNUIMessage(({type = "togglemenu", state = b, data = vehData})) end
    menu = b
    SetNuiFocus(b,b)
end

RegisterNUICallback("togglemenu",function(data,cb)
    toggleMenu(data.state,false)
end)

RegisterNUICallback("save",function(data,cb)
    local veh = GetVehiclePedIsIn(GetPlayerPed(-1),false)
    if not IsPedInAnyVehicle(GetPlayerPed(-1)) or GetPedInVehicleSeat(veh, -1)~=GetPlayerPed(-1) then return end
    setVehData(veh,data)
    lastVeh = veh
    lastStats = stats
end)

RegisterNetEvent("tuning:useLaptop")
AddEventHandler("tuning:useLaptop", function()
    if PlayerData.job.name == Config.Mec1 or
    PlayerData.job.name == Config.Mec2 or 
    PlayerData.job.name == Config.Mec3 or
    PlayerData.job.name == Config.Mec4 or
    PlayerData.job.name == Config.Mec5 or
    PlayerData.job.name == Config.Mec6 or
    PlayerData.job.name == Config.Mec7 then
    
    if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
        if not IsThisModelABicycle(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1),false))) and
        not IsThisModelABoat(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1),false))) and
        not IsThisModelAHeli(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1),false))) and
        not IsThisModelAJetski(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1),false))) and
        not IsThisModelAPlane(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1),false))) then
    if not menu then
        TriggerEvent('esx_inventoryhud:doClose')
        Citizen.Wait(3000)
        local ped = GetPlayerPed(-1)
        toggleMenu(true,true)
        while IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1)==ped do
            Citizen.Wait(100)
        end
        toggleMenu(false,true)
    else
        return
    end
else     
    TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Bu araca yazılım yükleyemezsin!'}) 
end
else
TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Araçta değilsin!'}) 
end
else
TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Bu tableti kullanacak kadar bilgili değilsin!'}) 
end

end)

RegisterNetEvent("tuning:closeMenu")
AddEventHandler("tuning:closeMenu",function()
    toggleMenu(false,true)
end)

local lastVeh = false
local lastData = false
local gotOut = false
Citizen.CreateThread(function(...)
    while not ESX do Citizen.Wait(0); end
    while not ESX.IsPlayerLoaded() do Citizen.Wait(0); end
    while true do
        Citizen.Wait(30)
        if IsPedInAnyVehicle(GetPlayerPed(-1)) then
            local veh = GetVehiclePedIsIn(GetPlayerPed(-1),false)
            if veh ~= lastVeh or gotOut then
                if gotOut then gotOut = false; end
                local responded = false
                ESX.TriggerServerCallback('tuning:CheckStats', function(doTune,stats)
                    if doTune then
                        setVehData(veh,stats)
                        lastStats = stats
                    else
                        if lastVeh and veh and lastVeh == veh and lastData then
                            setVehData(veh,lastData)
                        end
                    end
                    lastVeh = veh
                    responded = true
                end, ESX.Game.GetVehicleProperties(veh))
                while not responded do Citizen.Wait(0); end
            end
        else
            if not gotOut then
                gotOut = true
            end
        end
    end
end)