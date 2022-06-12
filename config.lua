Config = {}

Config.Locale = 'en'               -- By default there is only the 'en' locale, but you can add your own.
Config.Cooldown = 1000             -- Cooldown Between Car Remote Actions
Config.SwitchDistance = 3          -- How Close You Need To Be To Switch Connected Vehicles
Config.MaxRemoteRange = 30         -- Set max range that the remote will work.
Config.MaxAlarmDistance = 50       -- Maximum hearing distance for alarms
Config.MaxAlarmVolume = 0.5        -- Maximum volume for alarms
Config.MaxOutsideDistance = 50     -- Maximum hearing distance for sounds that play from outside vehicle (not alarms)
Config.MaxOutsideVolume = 0.20     -- Maximum volume for sounds that play from outside of vehicle (not alarms)
Config.MaxInsideDistance = 4       -- Maximum hearing distance for sounds that play from inside vehicle
Config.MaxInsideVolume = 0.5       -- Maximum volume for sounds that play from inside vehicle
Config.UseRemoteRange = true       -- Set whether you want to use the maximum remote range feature
Config.UseBattery = true           -- Set whether you are using the battery on the keyfob or not
Config.StealableMotorcycles = true -- Set whether you want to be realistic and make motorcycles stealable
Config.UseLockedAlarms = true      -- Thread For Triggering Car / Motorcycle Alarms
Config.AllowForcedEntry = true     -- Set whether you want the player to be able to force entry
Config.Debug = true

--Key mapping
Config.ToggleUi = 'ADD' --Defult NUMPAD ADD
Config.ToggleEngine = 'NUMPADENTER'
Config.ToggleLocks = 'SUBTRACT' --Defult NUMPAD SUBTRACT


--Notify configs 
Config.QBConnected = "Keyfob Connected: "
Config.QBKeysGranted = "Keys Granted:  "
Config.QBKeysReceived = "Key Received: "
Config.QBKeyLost = "Key Lost: "
Config.QBKeyShared = "Key Shared:"
Config.QBAllKeysLost = "All Keys Lost"
Config.QBNoConnection = "No Connection To Vehicle"
Config.QBNoPlayer = "No Player Nearby"
Config.QBUnlocked = "Vehicle Unlocked"
Config.QBLocked = "Vehicle Locked"
Config.QBEngineOn = "Engine On"
Config.QBEngineOff = "Engine Off"
Config.QBOutOfRange = "OUT OF RANGE"
Config.QBNoTrunk = "NO TRUNK"
Config.QBTrunkOpened = "Trunk Opened"
Config.QBTrunkClosed = "Trunk Closed"
