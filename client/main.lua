QBCore = exports['qb-core']:GetCoreObject()

local connectedVehicle, currentVehicle, uiActive, cooldown, activeAlarms, attempted = nil, nil, false, false, {}, {}

function openKeyfob(vehicle, pedCoords, vehicleCoords)
	if vehicle and pedCoords and vehicleCoords then
		local distance = pedCoords - vehicleCoords

		if #distance > Config.MaxRemoteRange then
			QBCore.Functions.Notify(Config.QBOutOfRange, 'error')
			uiActive = false
		else
			local battery = 'battery-100'
			local engine = 0
			local locked = 0

			local range = #distance / Config.MaxRemoteRange

			range = 100 - (math.floor((range * 10) + 0.5) * 10)

			battery = 'battery-' .. tostring(range)

			if GetIsVehicleEngineRunning(vehicle) then engine = 1 end
			if GetVehicleDoorLockStatus(vehicle) ~= 1 then locked = 1 end

			SendNUIMessage({ type = 'open', battery = battery, engine = engine, locked = locked })
			SetNuiFocus(true, true)
		end
	else
		uiActive = false
	end
end

function prepareKeyfob()
	if not uiActive then
		uiActive = true

		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped, false)
		local closestVehicle = QBCore.Functions.GetClosestVehicle(pedCoords)
		local vehicle = closestVehicle
		if vehicle or connectedVehicle then
			local vehicleCoords = GetEntityCoords(vehicle, false)
			local distance = pedCoords - vehicleCoords

			if #distance < Config.SwitchDistance then
				local plate = QBCore.Functions.GetPlate(vehicle)
				local model = GetEntityModel(vehicle)
				local modelName = tostring(model)
				if Config.Debug then
				print("plate: ".. plate)
				end
				if plate then

					QBCore.Functions.TriggerCallback('carremote:isVehicleOwned', function(owned)
						if owned then
							TriggerServerEvent('carremote:grantKey', plate, modelName)

							if connectedVehicle then
								if connectedVehicle ~= vehicle then
									connectedVehicle = vehicle
									QBCore.Functions.Notify(Config.QBConnected .. plate, "success")
								end

								if DoesEntityExist(connectedVehicle) then
									vehicleCoords = GetEntityCoords(connectedVehicle, false)
									openKeyfob(connectedVehicle, pedCoords, vehicleCoords)
								else
									QBCore.Functions.Notify(Config.QBOutOfRange, "error")
									uiActive = false
								end
							else
								connectedVehicle = vehicle
								QBCore.Functions.Notify(Config.QBConnected .. plate, "success")

								if DoesEntityExist(connectedVehicle) then
									vehicleCoords = GetEntityCoords(connectedVehicle, false)
									openKeyfob(connectedVehicle, pedCoords, vehicleCoords)
								else
									QBCore.Functions.Notify(Config.QBOutOfRange, "error")
									uiActive = false
								end
							end
						else
							if connectedVehicle then
								if DoesEntityExist(connectedVehicle) then
									vehicleCoords = GetEntityCoords(connectedVehicle, false)
									openKeyfob(connectedVehicle, pedCoords, vehicleCoords)
								else
									QBCore.Functions.Notify(Config.QBOutOfRange, "error")
									uiActive = false
								end
							else
								QBCore.Functions.Notify(Config.QBNoConnection, "error")
								uiActive = false
							end
						end
					end, plate)
				else
					currentVehicle = vehicle
					TriggerServerEvent('carremote:checkKey', plate, modelName, pedCoords)
				end
			else
				if connectedVehicle then
					if DoesEntityExist(connectedVehicle) then
						vehicleCoords = GetEntityCoords(connectedVehicle, false)
						openKeyfob(connectedVehicle, pedCoords, vehicleCoords)
					else
						QBCore.Functions.Notify(Config.QBOutOfRange, "error")
						uiActive = false
					end
				else
					QBCore.Functions.Notify(Config.QBNoConnection, "error")
					uiActive = false
				end
			end
		else
			if connectedVehicle then
				if DoesEntityExist(connectedVehicle) then
					vehicleCoords = GetEntityCoords(connectedVehicle, false)
					openKeyfob(connectedVehicle, pedCoords, vehicleCoords)
				else
					QBCore.Functions.Notify(Config.QBOutOfRange, "error")
					uiActive = false
				end
			else
				QBCore.Functions.Notify(Config.QBNoConnection, "error")
				uiActive = false
			end
		end
	else
		QBCore.Functions.Notify(Config.QBNoConnection, "error")
		uiActive = false
	end
end

function toggleLocks(vehicle, isInside)
	if vehicle then
		local lockStatus = GetVehicleDoorLockStatus(vehicle)
		local vehicleClass = GetVehicleClass(vehicle)
		local vehicleNetId = VehToNet(vehicle)
		local isMotorcycle = false

		if vehicleClass == 8 then isMotorcycle = true end

		if vehicleNetId then
			if isInside then
				if lockStatus ~= 1 then
					if not isMotorcycle then
						TriggerServerEvent('carremote:vehicleSound', Config.MaxInsideDistance, 'unlock-inside', Config.MaxInsideVolume,
							vehicleNetId)
					end

					TriggerServerEvent('carremote:unlock', vehicleNetId, isInside, isMotorcycle)
					QBCore.Functions.Notify(Config.QBUnlocked)
				else
					if not isMotorcycle then
						TriggerServerEvent('carremote:vehicleSound', Config.MaxInsideDistance, 'lock-inside', Config.MaxInsideVolume,
							vehicleNetId)
					end

					TriggerServerEvent('carremote:lock', vehicleNetId, isInside, isMotorcycle)
					QBCore.Functions.Notify(Config.QBLocked)
				end
			else
				if lockStatus ~= 1 then
					playAnimation()
					Wait(300)
					TriggerServerEvent('carremote:vehicleSound', Config.MaxOutsideDistance, 'unlock-inside', Config.MaxOutsideVolume,
						vehicleNetId)
					TriggerServerEvent('carremote:unlock', vehicleNetId, isInside, isMotorcycle)
					QBCore.Functions.Notify(Config.QBUnlocked)
					SendNUIMessage({ type = "locks", value = 0 })
				else
					playAnimation()
					Wait(300)
					TriggerServerEvent('carremote:vehicleSound', Config.MaxOutsideDistance, 'lock-outside', Config.MaxOutsideVolume,
						vehicleNetId)
					TriggerServerEvent('carremote:lock', vehicleNetId, isInside, isMotorcycle)
					QBCore.Functions.Notify(Config.QBLocked)
					SendNUIMessage({ type = "locks", value = 1 })
				end
			end
		end
	end
end

function toggleEngine(vehicle, isInside)
	if vehicle and DoesEntityExist(vehicle) then
		local engineStatus = GetIsVehicleEngineRunning(vehicle)
		local vehicleNetId = VehToNet(vehicle)

		if vehicleNetId then
			while not NetworkHasControlOfEntity(vehicle) do
				NetworkRequestControlOfEntity(vehicle)
				Wait(10)
			end

			if isInside then
				if engineStatus then
					TriggerServerEvent('carremote:engineOff', vehicleNetId)
					QBCore.Functions.Notify(Config.QBEngineOff)
				else
					TriggerServerEvent('carremote:engineOn', vehicleNetId)
					QBCore.Functions.Notify(Config.QBEngineOn, "success")
				end
			else
				if engineStatus then
					playAnimation()
					Wait(300)
					TriggerServerEvent('carremote:engineOff', vehicleNetId)
					QBCore.Functions.Notify(Config.QBEngineOff)
					SendNUIMessage({ type = "engine", value = 0 })
				else
					playAnimation()
					Wait(300)
					TriggerServerEvent('carremote:engineOn', vehicleNetId)
					QBCore.Functions.Notify(Config.QBEngineOn, "success")
					SendNUIMessage({ type = "engine", value = 1 })
				end
			end
		end
	end
end

function toggleAlarm(vehicle, isEmergency)
	if vehicle and DoesEntityExist(vehicle) then
		local alarmStatus = IsVehicleAlarmActivated(vehicle)
		local vehicleClass = GetVehicleClass(vehicle)
		local vehicleNetId = VehToNet(vehicle)
		local isMotorcycle = false

		if vehicleClass == 8 then isMotorcycle = true end

		if vehicleNetId then
			if isEmergency then
				if not alarmStatus then
					TriggerServerEvent('carremote:startAlarm', vehicleNetId, isMotorcycle)
				end
			else
				if alarmStatus then
					playAnimation()
					Wait(300)
					TriggerServerEvent('carremote:stopAlarm', vehicleNetId)
				else
					playAnimation()
					Wait(300)
					TriggerServerEvent('carremote:startAlarm', vehicleNetId, isMotorcycle)
				end
			end
		end
	end

	if not isEmergency then
		cooldown = true
		startCooldown()
	end
end

function motorcycleAlarm(vehicle)
	if vehicle and DoesEntityExist(vehicle) then
		activeAlarms[vehicle] = true

		SetVehicleAlarm(vehicle, 1)
		StartVehicleAlarm(vehicle)
		SetVehicleAlarmTimeLeft(vehicle, 180000)

		local count = 0

		while count < 30 and activeAlarms[vehicle] do
			count = count + 1

			if not IsHornActive(vehicle) then
				StartVehicleHorn(vehicle, 1, "NORMAL", false)
			end

			SetVehicleLights(vehicle, 2)
			SetVehicleBrakeLights(vehicle, true)
			Wait(100)
			SetVehicleLights(vehicle, 0)
			SetVehicleBrakeLights(vehicle, false)
			Wait(100)
			SetVehicleLights(vehicle, 2)
			SetVehicleBrakeLights(vehicle, true)
			Wait(100)
			SetVehicleLights(vehicle, 0)
			SetVehicleBrakeLights(vehicle, false)
			Wait(500)
		end

		activeAlarms[vehicle] = nil
	end
end

function prepareMotorcycleAlarm(vehicle)
	if vehicle and DoesEntityExist(vehicle) then
		local vehicleClass = GetVehicleClass(vehicle)
		local vehicleNetId = VehToNet(vehicle)

		if vehicleNetId and vehicleClass == 8 then
			playAnimation()
			Wait(300)
			TriggerServerEvent('carremote:motorcycleAlarm', vehicleNetId)
		end
	end
end

function flashLights(vehicle, type)
	if vehicle then
		if type == "lock" then
			SetVehicleLights(vehicle, 2)
			SetVehicleBrakeLights(vehicle, true)
			Wait(100)
			SetVehicleLights(vehicle, 0)
			SetVehicleBrakeLights(vehicle, false)
			Wait(200)
			SetVehicleLights(vehicle, 2)
			SetVehicleBrakeLights(vehicle, true)
			Wait(100)
			SetVehicleLights(vehicle, 0)
			SetVehicleBrakeLights(vehicle, false)
		elseif type == "unlock" then
			SetVehicleLights(vehicle, 2)
			SetVehicleBrakeLights(vehicle, true)
			Wait(250)
			SetVehicleLights(vehicle, 0)
			SetVehicleBrakeLights(vehicle, false)
		elseif type == "stopAlarm" then
			SetVehicleLights(vehicle, 2)
			SetVehicleBrakeLights(vehicle, true)
			Wait(75)
			SetVehicleLights(vehicle, 0)
			SetVehicleBrakeLights(vehicle, false)
			Wait(75)
			SetVehicleLights(vehicle, 2)
			SetVehicleBrakeLights(vehicle, true)
			Wait(75)
			SetVehicleLights(vehicle, 0)
			SetVehicleBrakeLights(vehicle, false)
		elseif type == "findVehicle" then
			SetVehicleLights(vehicle, 2)
			SetVehicleBrakeLights(vehicle, true)
			Wait(75)
			SetVehicleLights(vehicle, 0)
			SetVehicleBrakeLights(vehicle, false)
		end
	end
end

exports('flashLights', flashLights)

function startCooldown()
	if Config and Config.Cooldown then
		Wait(Config.Cooldown)
		cooldown = false
	else
		Wait(1000)
		cooldown = false
	end
end

function playAnimation()
	local ped = PlayerPedId()
	local lib = "anim@mp_player_intmenu@key_fob@"
	local anim = "fob_click"
	local count = 0

	RequestAnimDict(lib)

	while not HasAnimDictLoaded(lib) and count < 100 do
		count = count + 1
		Wait(10)
	end

	if HasAnimDictLoaded(lib) then
		TaskPlayAnim(ped, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
	end

	Wait(300)

	PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
end

function grantKey(vehicle)
	if vehicle and DoesEntityExist(vehicle) then
		local model = GetEntityModel(vehicle)
		local modelName = tostring(model)
		local plate = nil
		plate = GetVehicleNumberPlateText(vehicle)
		if plate and modelName then
			connectedVehicle = vehicle
			TriggerServerEvent('carremote:grantKey', plate, modelName)
			QBCore.Functions.Notify(Config.QBKeysGranted .. plate, "success")
		end
	end
end

RegisterNetEvent('carremote:vehicleSound', function(playerNetId, maxDistance, soundFile, maxVolume, sourceEntity)
	local vehicle = NetToVeh(sourceEntity)

	if DoesEntityExist(vehicle) then
		local pedCoords = GetEntityCoords(PlayerPedId(), false)
		local vehicleCoords = GetEntityCoords(vehicle, false)
		local distance = pedCoords - vehicleCoords

		if #distance < maxDistance then
			local dist = #distance / maxDistance

			volume = (1 - dist) * maxVolume

			SendNUIMessage({ type = "playSound", file = soundFile, volume = volume })
		end
	end
end)

RegisterNetEvent('carremote:lock', function(vehicleNetId, isInside, isMotorcycle)
	local vehicle = NetToVeh(vehicleNetId)

	if vehicle and DoesEntityExist(vehicle) then
		if isInside then
			if isMotorcycle and Config.StealableMotorcycles then
				SetVehicleDoorsLocked(vehicle, 7)
				SetVehicleNeedsToBeHotwired(vehicle, true)
			else
				SetVehicleDoorsLocked(vehicle, 2)
			end
		else
			if isMotorcycle and Config.StealableMotorcycles then
				SetVehicleDoorsLocked(vehicle, 7)
				SetVehicleNeedsToBeHotwired(vehicle, true)
				flashLights(vehicle, "lock")
			else
				flashLights(vehicle, "lock")
				SetVehicleDoorsLocked(vehicle, 2)
			end
		end
	end
end)

RegisterNetEvent('carremote:unlock', function(vehicleNetId, isInside, isMotorcycle)
	local vehicle = NetToVeh(vehicleNetId)

	if vehicle and DoesEntityExist(vehicle) then
		if isInside then
			if isMotorcycle and Config.StealableMotorcycles then
				SetVehicleDoorsLocked(vehicle, 1)
				SetVehicleNeedsToBeHotwired(vehicle, false)
			else
				SetVehicleDoorsLocked(vehicle, 1)
			end
		else
			if isMotorcycle and Config.StealableMotorcycles then
				SetVehicleDoorsLocked(vehicle, 1)
				SetVehicleNeedsToBeHotwired(vehicle, false)
				flashLights(vehicle, "unlock")
			else
				SetVehicleDoorsLocked(vehicle, 1)
				flashLights(vehicle, "unlock")
			end
		end
	end
end)

RegisterNetEvent('carremote:engineOn', function(vehicleNetId)
	local vehicle = NetToVeh(vehicleNetId)

	if vehicle and DoesEntityExist(vehicle) then
		local count = 0

		while not GetIsVehicleEngineRunning(vehicle) and count < 10 do
			SetVehicleEngineOn(vehicle, true, true, true)
			count = count + 1
			Wait(100)
		end
	end
end)

RegisterNetEvent('carremote:engineOff', function(vehicleNetId)
	local vehicle = NetToVeh(vehicleNetId)

	if vehicle and DoesEntityExist(vehicle) then
		local count = 0

		while GetIsVehicleEngineRunning(vehicle) and count < 10 do
			SetVehicleEngineOn(vehicle, false, true, true)
			count = count + 1
			Wait(100)
		end
	end
end)

RegisterNetEvent('carremote:startAlarm', function(vehicleNetId, isMotorcycle)
	local vehicle = NetToVeh(vehicleNetId)

	if vehicle and DoesEntityExist(vehicle) then
		if isMotorcycle then
			motorcycleAlarm(vehicle)
		else
			SetVehicleAlarm(vehicle, 1)
			StartVehicleAlarm(vehicle)
			SetVehicleAlarmTimeLeft(vehicle, 180000)
		end
	end
end)

RegisterNetEvent('carremote:stopAlarm', function(vehicleNetId)
	local vehicle = NetToVeh(vehicleNetId)

	if vehicle and DoesEntityExist(vehicle) then
		if activeAlarms[vehicle] then
			activeAlarms[vehicle] = nil
		end

		SetVehicleAlarm(vehicle, 0)
		flashLights(vehicle, "stopAlarm")
	end
end)

RegisterNetEvent('carremote:motorcycleAlarm', function(vehicleNetId)
	local vehicle = NetToVeh(vehicleNetId)

	if DoesEntityExist(vehicle) then
		motorcycleAlarm(vehicle)
	end
end)

RegisterNetEvent('carremote:findVehicle', function(vehicleNetId)
	local vehicle = NetToVeh(vehicleNetId)

	if vehicle and DoesEntityExist(vehicle) then
		playAnimation()
		Wait(300)
		flashLights(vehicle, "findVehicle")
	end
end)

RegisterNetEvent('carremote:keyReceived', function(plate)
	if plate then QBCore.Functions.Notify(Config.QBKeysReceived .. plate) end
end)

RegisterNetEvent('carremote:keyShared', function(plate)
	if plate then QBCore.Functions.Notify(Config.QBKeyShared .. plate) end
end)

RegisterNetEvent('carremote:keyLost', function(plate)
	if plate then QBCore.Functions.Notify(Config.QBKeyLost .. plate, "error") end
end)

RegisterNetEvent('carremote:allKeysLost', function()
	if plate then QBCore.Functions.Notify(Config.QBAllKeysLost, "error") end
end)

---------------------------------------------------------------------------------
--                           KEYBINDING COMMANDS                               --
---------------------------------------------------------------------------------

-- +hotkeyui KEYBIND COMMAND
RegisterCommand('+hotkeyui', function()
	if not cooldown then
		local ped = PlayerPedId()

		if (IsPedInAnyVehicle(ped, true)) then
			local vehicle = GetVehiclePedIsIn(ped, false)

			if vehicle then
				toggleLocks(vehicle, true)
			end
		else
			prepareKeyfob()
		end

		cooldown = true
		startCooldown()
	end
end, false)

-- -hotkeyui KEYBIND COMMAND (NULL)
RegisterCommand('-hotkeyui', function()
	return
end, false)

-- +hotkeylocks KEYBIND COMMAND
RegisterCommand('+hotkeylocks', function()
	if not cooldown then
		local ped = PlayerPedId()

		if (IsPedInAnyVehicle(ped, true)) then
			local vehicle = GetVehiclePedIsIn(ped, false)

			if vehicle then
				toggleLocks(vehicle, true)
			end
		else
			if connectedVehicle and DoesEntityExist(connectedVehicle) then
				toggleLocks(connectedVehicle, false)
			end
		end

		cooldown = true
		startCooldown()
	end
end, false)

-- -hotkeylocks KEYBIND COMMAND (NULL)
RegisterCommand('-hotkeylocks', function()
	return
end, false)

-- +hotkeyengine KEYBIND COMMAND
RegisterCommand('+hotkeyengine', function()
	if not cooldown then
		local ped = PlayerPedId()

		if (IsPedInAnyVehicle(ped, true)) then
			local vehicle = GetVehiclePedIsIn(ped, false)

			if vehicle then
				toggleEngine(vehicle, true)
			end
		else
			if connectedVehicle and DoesEntityExist(connectedVehicle) then
				toggleEngine(connectedVehicle, false)
			end
		end

		cooldown = true
		startCooldown()
	end
end, false)

-- -hotkeyengine KEYBIND COMMAND (NULL)
RegisterCommand('-hotkeyengine', function()
	return
end, false)

---------------------------------------------------------------------------------
--                                 KEYBINDINGS                                 --
---------------------------------------------------------------------------------

RegisterKeyMapping('+hotkeyui', 'Toggle UI', 'keyboard', Config.ToggleUi)
RegisterKeyMapping('+hotkeyengine', 'Toggle Engine', 'keyboard', Config.ToggleEngine)
RegisterKeyMapping('+hotkeylocks', 'Toggle Locks', 'keyboard', Config.ToggleLocks)

---------------------------------------------------------------------------------
--                                 NUI Callbacks                               --
---------------------------------------------------------------------------------

RegisterNUICallback('lock', function()
	if not cooldown then
		if connectedVehicle and DoesEntityExist(connectedVehicle) then
			local vehicleClass = GetVehicleClass(connectedVehicle)
			local vehicleNetId = VehToNet(connectedVehicle)
			local isMotorcycle = false

			if vehicleNetId then
				if vehicleClass == 8 then isMotorcycle = true end

				playAnimation()
				Wait(300)
				TriggerServerEvent('carremote:vehicleSound', Config.MaxOutsideDistance, 'lock-outside', Config.MaxOutsideVolume,
					vehicleNetId)
				TriggerServerEvent('carremote:lock', vehicleNetId, false, isMotorcycle)
				QBCore.Functions.Notify(Config.QBLocked)
				SendNUIMessage({ type = "locks", value = 1 })
			end
		end

		cooldown = true
		startCooldown()
	end
end)

RegisterNUICallback('unlock', function()
	if not cooldown then
		if connectedVehicle and DoesEntityExist(connectedVehicle) then
			local vehicleClass = GetVehicleClass(connectedVehicle)
			local vehicleNetId = VehToNet(connectedVehicle)
			local isMotorcycle = false

			if vehicleNetId then
				if vehicleClass == 8 then isMotorcycle = true end

				playAnimation()
				Wait(300)
				TriggerServerEvent('carremote:vehicleSound', Config.MaxOutsideDistance, 'unlock-inside', Config.MaxOutsideVolume,
					vehicleNetId)
				TriggerServerEvent('carremote:unlock', vehicleNetId, false, isMotorcycle)
				QBCore.Functions.Notify(Config.QBUnlocked)
				SendNUIMessage({ type = "locks", value = 0 })
			end
		end

		cooldown = true
		startCooldown()
	end
end)

RegisterNUICallback('engine', function()
	if not cooldown then
		if connectedVehicle and DoesEntityExist(connectedVehicle) then
			toggleEngine(connectedVehicle, false)
		end

		cooldown = true
		startCooldown()
	end
end)

RegisterNUICallback('alarm', function()
	if not cooldown then
		if connectedVehicle and DoesEntityExist(connectedVehicle) then
			toggleAlarm(connectedVehicle, false)
		end

		cooldown = true
		startCooldown()
	end
end)

RegisterNUICallback('trunk', function()
	if not cooldown then
		if connectedVehicle and DoesEntityExist(connectedVehicle) then
			playAnimation()
			Wait(300)

			if GetIsDoorValid(connectedVehicle, 5) then
				if GetVehicleDoorAngleRatio(connectedVehicle, 5) > 0.0 then
					SetVehicleDoorShut(connectedVehicle, 5, 0)
					QBCore.Functions.Notify(Config.QBTrunkClosed)
				else
					SetVehicleDoorOpen(connectedVehicle, 5, 0)
					QBCore.Functions.Notify(Config.QBTrunkOpened, "success")
				end
			else
				QBCore.Functions.Notify(Config.QBNoTrunk, "error")
			end
		end

		cooldown = true
		startCooldown()
	end
end)

RegisterNUICallback('share', function()
	if not cooldown then
		if connectedVehicle and DoesEntityExist(connectedVehicle) then
			local ped = PlayerPedId()
			local pedCoords = GetEntityCoords(ped)
			local targetPlayer = func_f(pedCoords)

			if targetPlayer then
				local plate = GetVehicleNumberPlateText(connectedVehicle)
				local targetID = GetPlayerServerId(targetPlayer)
				local model = GetEntityModel(connectedVehicle)
				local modelName = tostring(model)

				if plate and targetID and modelName then
					TriggerServerEvent('carremote:shareKey', targetID, plate, modelName)
				end
			end
		end

		cooldown = true
		startCooldown()
	end
end)

RegisterNUICallback('findVehicle', function()
	if not cooldown then
		if connectedVehicle and DoesEntityExist(connectedVehicle) then
			local vehicleNetId = VehToNet(connectedVehicle)

			if vehicleNetId then
				TriggerServerEvent('carremote:findVehicle', vehicleNetId)
			end
		end

		cooldown = true
		startCooldown()
	end
end)

RegisterNUICallback('close', function()
	SetNuiFocus(false, false)
	uiActive = false
	cooldown = true
	startCooldown()
end)

if Config.UseLockedAlarms then
	local alarmTriggering = false

	CreateThread(function()
		while true do
			Wait(30000)
			attemped = {}
		end
	end)

	CreateThread(function(plate)
		while true do
			local ped = PlayerPedId()

			if IsPedGettingIntoAVehicle(ped) then
				local vehicle = GetVehiclePedIsTryingToEnter(ped)

				if vehicle and not plate then
					if attempted[vehicle] then
						local vehicleClass = GetVehicleClass(vehicle)

						if vehicleClass ~= 18 and vehicleClass ~= 19 then
							SetVehicleDoorsLocked(vehicle, 2)
							toggleAlarm(vehicle, true)
						end
					else
						attempted[vehicle] = true
						local lockStatus = GetVehicleDoorLockStatus(vehicle)
						local vehicleClass = GetVehicleClass(vehicle)

						if lockStatus == 2 or lockStatus == 7 then
							if not IsVehicleAlarmActivated(vehicle) then
								if vehicleClass == 8 then
									local vehicleNetId = VehToNet(vehicle)

									if vehicleNetId then
										if Config.StealableMotorcycles then SetVehicleDoorsLocked(vehicle, 1) end
										TriggerServerEvent('carremote:motorcycleAlarm', vehicleNetId)
									end
								end
							end
						end
					end
				end

				while IsPedGettingIntoAVehicle(ped) do
					Wait(1)
				end

				Wait(1000)
			else
				Wait(10)
			end
		end
	end)
end

function func_a()
	return GetGamePool('CVehicle')
end

function func_b(a, b)
	local c, d, b = -1, -1, b

	for k, v in pairs(a) do
		if DoesEntityExist(v) then
			local e = #(b - GetEntityCoords(v))

			if d == -1 or e < d then
				c, d = v, e
			end
		end
	end

	return c
end

function func_c(coords)
	return func_b(func_a(), coords)
end

function func_d()
	local a, b = {}, PlayerId()

	for _, c in ipairs(GetActivePlayers()) do
		local d = GetPlayerPed(c)
		if DoesEntityExist(d) and c ~= b then table.insert(a, c) end
	end

	return a
end

function func_e(a, b)
	local c, d, b = -1, -1, b

	for k, v in pairs(a) do
		local f = GetPlayerPed(v)

		if DoesEntityExist(f) then
			local e = #(b - GetEntityCoords(f))

			if d == -1 or e < d then
				c, d = v, e
			end
		end
	end

	return c
end

function func_f(coords)
	return func_e(func_d(), coords)
end

RegisterNetEvent('carremote:hasKey', function(pedCoords)
	if currentVehicle then
		if connectedVehicle ~= currentVehicle then connectedVehicle = currentVehicle end

		if DoesEntityExist(connectedVehicle) then
			local vehicleCoords = GetEntityCoords(connectedVehicle, false)
			openKeyfob(connectedVehicle, pedCoords, vehicleCoords)
		else
			uiActive = false
		end
	else
		connectedVehicle = currentVehicle

		if DoesEntityExist(connectedVehicle) then
			local vehicleCoords = GetEntityCoords(connectedVehicle, false)
			openKeyfob(connectedVehicle, pedCoords, vehicleCoords)
		else
			uiActive = false
		end
	end

	currentVehicle = nil
end)

RegisterNetEvent('carremote:noKey', function(pedCoords)
	if connectedVehicle then
		if DoesEntityExist(connectedVehicle) then
			local vehicleCoords = GetEntityCoords(connectedVehicle, false)
			openKeyfob(connectedVehicle, pedCoords, vehicleCoords)
		else
			uiActive = false
		end
	end

	currentVehicle = nil
end)

exports('grantKey', grantKey)
