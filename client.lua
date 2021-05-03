-- simple script to start/lock/unlock car from NUI

-- store array of vehicles
local myVehicles = {}

local debug_mode = true
local function debug_print(str)
	if debug_mode then
		print('FiveM-Remote-Key :: '..str)
	end
end

local function requestNetworkControl(veh)
	if not NetworkHasControlOfEntity(veh) then
		NetworkRequestControlOfNetworkId(NetworkGetNetworkIdFromEntity(veh))
		while not NetworkHasControlOfNetworkId(NetworkGetNetworkIdFromEntity(veh)) do
			Citizen.Wait(0)
		end
	end
end

function add_vehicle(veh) 
	if veh then
		local p = false
		if type(veh) == "string" then
			p = veh
		else
			p = GetVehicleNumberPlateText(veh)
		end
		if p then
			myVehicles[p] = true
			debug_print('add_vehicle() added '..p..' to myVehicles table')
		else
			debug_print('add_vehicle() p is false / null')
		end
	else
		debug_print('add_vehicle() veh is false / null')
	end
end

function remove_vehicle(veh)
	if veh then
		local p = false
		if type(veh) == "string" then
			p = veh
		else
			p = GetVehicleNumberPlateText(veh)
		end
		if p then
			myVehicles[p] = nil
			debug_print('remove_vehicle() removed '..p..' from myVehicles table')
		else
			debug_print('remove_vehicle() p is false / null')
		end
	else
		debug_print('remove_vehicle() veh is false / null')
	end
end

local function doIOwnVehicle(veh)
	if veh then
		local p = false
		if type(veh) == "string" then
			p = veh
		else
			p = GetVehicleNumberPlateText(veh)
		end
		if p then
			if myVehicles[p] then
				debug_print('doIOwnVehicle() own vehicle '..p)
				return true
			else
				debug_print('doIOwnVehicle() not own vehicle '..p)
				return false
			end
		else
			debug_print('doIOwnVehicle() p is false / null')
		end
	else
		debug_print('doIOwnVehicle() veh is false / null')
	end
end

local function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end
local function getVehicleLookingAt()
	local targetVehicle = false
	local coordA = GetEntityCoords(GetPlayerPed(-1), 1)
	local coordB = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 20.0, -1.0)
	targetVehicle = getVehicleInDirection(coordA, coordB)
	return targetVehicle
end

local function unLockVehicle()
	local veh = getVehicleLookingAt()
	if veh and doIOwnVehicle(veh) then
		requestNetworkControl(veh)
		SetVehicleDoorsLocked(veh, 1)
	end
end
local function lockVehicle()
	local veh = getVehicleLookingAt()
	if veh and doIOwnVehicle(veh) then
		requestNetworkControl(veh)
		SetVehicleDoorsLocked(veh, 2)
	end
end
local function startVehicle()
	local veh = getVehicleLookingAt()
	if veh and doIOwnVehicle(veh) then
		requestNetworkControl(veh)
		SetVehicleEngineOn(veh, true, true, true)
	end
end

local keyOpen = false
RegisterNetEvent('FiveM-Remote-Key:toggle')
AddEventHandler('FiveM-Remote-Key:toggle', function()
	if keyOpen then
		SendNUIMessage({
			display = false
		})
		SetNuiFocus(false)
		keyOpen = false
	else
		SendNUIMessage({
			display = true
		})
		SetNuiFocus(true,true)
		keyOpen = true
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)	
		if IsControlJustPressed(0,311) then
			TriggerEvent('FiveM-Remote-Key:toggle')
		end
	end
end)


RegisterNUICallback('action', function(data,cb)
	if data.action == 'unlock' then
		unLockVehicle()
	elseif data.action == 'lock' then
		lockVehicle()
	elseif data.action == 'start' then
		startVehicle()
	end
end)




