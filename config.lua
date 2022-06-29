Config = {}

Config.Locale = 'es'               -- By default there is only the 'en' locale, but you can add your own.
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
Config.ToggleEngine = 'G'
Config.ToggleLocks = 'L' --Defult NUMPAD SUBTRACT

--Notify languages
Config.Languages = {
    ['en'] = { -- English
        ['key_connected'] = 'Keyfob Connected: ',
        ['key_granted'] = 'Keys Granted:  ',
        ['key_recieve'] = 'Key Received: ',
        ['key_lost'] = 'Key Lost: ',
        ['key_shared'] = 'Key Shared: ',
        ['key_lost_all'] = 'All Keys Lost',
        ['no_connection'] = 'No Connection To Vehicle',
        ['no_player'] = 'No Player Nearby',
        ['veh_unlock'] = 'Vehicle Unlocked',
        ['veh_lock'] = 'Vehicle Locked',
        ['engine_on'] = 'Engine On',
        ['engine_off'] = 'Engine Off',
        ['no_range'] = 'Out Of Range',
        ['no_trunk'] = 'This Vehicle Has No Trunk',
        ['trunk_open'] = 'Trunk Opened',
        ['trunk_close'] = 'Trunk Closed',
    },
    ['es'] = { -- Spanish
        ['key_connected'] = 'Llavero conectado: ',
        ['key_granted'] = 'Llaves recibidas:  ',
        ['key_recieve'] = 'Te han dado las llaves: ',
        ['key_lost'] = 'Has perdido las llaves: ',
        ['key_shared'] = 'Has compartido las llaves: ',
        ['key_lost_all'] = 'Has perdido todas las llaves.',
        ['no_connection'] = 'Sin conexión con el vehículo.',
        ['no_player'] = 'Ningún jugador cercab.',
        ['veh_unlock'] = 'Vehículo desbloqueado.',
        ['veh_lock'] = 'Vehículo bloqueado',
        ['engine_on'] = 'Motor encendido',
        ['engine_off'] = 'Motor apagado',
        ['no_range'] = 'Fuera de alcance',
        ['no_trunk'] = 'Este vehículo no tiene maletero.',
        ['trunk_open'] = 'Maletero abierto.',
        ['trunk_close'] = 'Maletero cerrado.',
    }
}
