local QBCore = exports['qb-core']:GetCoreObject()
local keys = {}
local usedKeys = {}

QBCore.Functions.CreateCallback("carremote:isVehicleOwned", function(source, cb, plate)
	local src = source
	local pData = QBCore.Functions.GetPlayer(src)
	if pData and plate then
		MySQL.query('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?',
			{ plate, pData.PlayerData.citizenid }, function(result)
			if result[1] then
				cb(true)
			else
				cb(false)
			end
		end)
	else
		cb(false)
	end
end)

RegisterNetEvent('carremote:grantKey', function(plate, modelName)
	local player = source

	if player and plate and modelName then
		if not keys[player] then keys[player] = {} end
		keys[player][plate] = modelName
		usedKeys[plate] = player
	end
end)

RegisterNetEvent('carremote:removeKey', function(targetID, plate)
	local tPlayer = targetID

	if tPlayer and plate and keys[tPlayer] and keys[tPlayer][plate] then
		keys[tPlayer][plate] = nil
		TriggerClientEvent('carremote:keyLost', tPlayer, plate)
	end
end)

RegisterNetEvent('carremote:shareKey', function(targetID, plate, modelName)
	local player = source
	local tPlayer = targetID

	if player and tPlayer and plate and modelName and keys[player] and keys[player][plate] == modelName then
		if not keys[tPlayer] then keys[tPlayer] = {} end
		keys[tPlayer][plate] = keys[player][plate]

		TriggerClientEvent('carremote:keyReceived', tPlayer, plate)
		TriggerClientEvent('carremote:keyShared', player, plate)
	end
end)

RegisterNetEvent('carremote:removeAllKeys', function(targetID)
	local tPlayer = targetID

	if tPlayer and keys[tPlayer] then
		keys[tPlayer] = {}
		TriggerClientEvent('carremote:allKeysLost', tPlayer)
	end
end)

RegisterNetEvent('carremote:vehicleSound', function(maxDistance, soundFile, maxVolume, vehicleNetId)
	TriggerClientEvent('carremote:vehicleSound', -1, source, maxDistance, soundFile, maxVolume, vehicleNetId)
end)

RegisterNetEvent('carremote:lock', function(vehicleNetId, isInside, isMotorcycle)
	TriggerClientEvent('carremote:lock', -1, vehicleNetId, isInside, isMotorcycle)
end)

RegisterNetEvent('carremote:unlock', function(vehicleNetId, isInside, isMotorcycle)
	TriggerClientEvent('carremote:unlock', -1, vehicleNetId, isInside, isMotorcycle)
end)

RegisterNetEvent('carremote:engineOn', function(vehicleNetId, isInside)
	TriggerClientEvent('carremote:engineOn', -1, vehicleNetId, isInside)
end)

RegisterNetEvent('carremote:engineOff', function(vehicleNetId)
	TriggerClientEvent('carremote:engineOff', -1, vehicleNetId)
end)

RegisterNetEvent('carremote:startAlarm', function(vehicleNetId, isMotorcycle)
	TriggerClientEvent('carremote:startAlarm', -1, vehicleNetId, isMotorcycle)
end)

RegisterNetEvent('carremote:stopAlarm', function(vehicleNetId)
	TriggerClientEvent('carremote:stopAlarm', -1, vehicleNetId)
end)

RegisterNetEvent('carremote:motorcycleAlarm', function(vehicleNetId)
	TriggerClientEvent('carremote:motorcycleAlarm', -1, vehicleNetId)
end)

RegisterNetEvent('carremote:findVehicle', function(vehicleNetId)
	TriggerClientEvent('carremote:findVehicle', -1, vehicleNetId)
end)

RegisterNetEvent('carremote:checkKey', function(plate, modelName, pedCoords)
	local player = source

	if player and plate and modelName then
		if keys[player] and keys[player][plate] and keys[player][plate] == modelName then
			TriggerClientEvent('carremote:hasKey', player, pedCoords)
		else
			if not usedKeys[plate] then
				if not keys[player] then keys[player] = {} end

				keys[player][plate] = modelName
				usedKeys[plate] = player

				TriggerClientEvent('carremote:hasKey', player, pedCoords)
			else
				TriggerClientEvent('carremote:noKey', player, pedCoords)
			end
		end
	end
end)

AddEventHandler('playerDropped', function(reason)
	local player = source

	if player and keys[player] then
		for k, v in pairs(keys[player]) do
			if usedKeys[k] == player then
				usedKeys[k] = nil
			end
		end

		keys[player] = nil
	end
end)
