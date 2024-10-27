-- Client-Skript

local isNearCarWash = false
local currentWashLocation = nil
local isWashing = false
local cleanVehicles = {}
local blipsCreated = false

-- Laden gespeicherter Daten
CreateThread(function()
    TriggerServerEvent('carwash:requestCleanVehicles')
end)

-- Funktion zum Erstellen der Blips
function CreateCarWashBlips()
    if blipsCreated then return end
    for _, coords in pairs(Config.CarWashLocations) do
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, 100) -- Blip-Symbol für Autowaschanlagen
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Translate('car_wash'))
        EndTextCommandSetBlipName(blip)
    end
    blipsCreated = true
end

-- Hauptthread zur Überprüfung der Nähe zu Waschanlagen
CreateThread(function()
    CreateCarWashBlips() -- Blips erstellen
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        isNearCarWash = false

        for _, coords in pairs(Config.CarWashLocations) do
            local distance = #(playerCoords - coords)
            if distance < 15.0 then
                isNearCarWash = true
                currentWashLocation = coords
                DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.0, 0, 255, 255, 50, false, true, 2, false, nil, nil, false)
                if distance < 3.0 then
                    Draw3DText(coords.x, coords.y, coords.z + 1.0, Translate('press_to_wash'))
                    if IsControlJustReleased(0, 38) and not isWashing then -- E-Taste
                        OpenWashMenu()
                    end
                end
            end
        end

        if not isNearCarWash then
            Wait(1000)
        else
            Wait(0)
        end
    end
end)

-- Öffnet das OX-Menü zur Auswahl der Waschoption
function OpenWashMenu()
    ShowWashMenu()
end

function ShowWashMenu()
    local options = {}

    for i, option in ipairs(Config.WashOptions) do
        local dynamicPrice = CalculateDynamicPrice(option.price)
        local title = option.label .. " (" .. Config.CurrencySymbol .. dynamicPrice .. ")"
        local description = Translate('wash_price', Config.CurrencySymbol, dynamicPrice)
        table.insert(options, {
            title = title,
            description = description .. "\n" .. "Fahrzeug bleibt " .. math.floor(option.cleanDuration / 3600) .. " Stunden sauber",
            event = 'carwash:attemptWash',
            args = { price = dynamicPrice, cleanDuration = option.cleanDuration, duration = option.duration },
            disabled = isWashing
        })
    end

    lib.registerContext({
        id = 'carwash_menu',
        title = Translate('car_wash'),
        options = options
    })

    lib.showContext('carwash_menu')
end

-- Event-Handler für den Versuch, die Wäsche zu starten
RegisterNetEvent('carwash:attemptWash')
AddEventHandler('carwash:attemptWash', function(data)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 then
        if GetPedInVehicleSeat(vehicle, -1) == playerPed then
            if GetVehicleEngineHealth(vehicle) < 800 then
                ShowNotification(Translate('vehicle_too_damaged'))
                return
            end
            -- Server-Event aufrufen, um die Zahlung zu verarbeiten
            TriggerServerEvent('carwash:pay', data.price, data.cleanDuration, data.duration, GetVehicleNumberPlateText(vehicle))
        else
            ShowNotification(Translate('not_driver'))
        end
    else
        ShowNotification(Translate('not_in_vehicle'))
    end
end)

-- Event-Handler, um die Wäsche zu starten (nach erfolgreicher Zahlung)
RegisterNetEvent('carwash:startWash')
AddEventHandler('carwash:startWash', function(cleanDuration, duration, plate)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 then
        StartWashing(vehicle, cleanDuration, duration, plate)
    end
end)

-- Event-Handler für nicht genügend Geld
RegisterNetEvent('carwash:notEnoughMoney')
AddEventHandler('carwash:notEnoughMoney', function()
    ShowNotification(Translate('not_enough_money'))
end)

-- Laden der Sauberkeitsdaten
RegisterNetEvent('carwash:loadCleanVehicles')
AddEventHandler('carwash:loadCleanVehicles', function(data)
    cleanVehicles = data
end)

-- Funktion zum Starten der Waschanimation und -logik
function StartWashing(vehicle, cleanDuration, duration, plate)
    isWashing = true
    FreezeEntityPosition(vehicle, true)
    ShowNotification(Translate('washing_vehicle'))

    -- Start der Waschanimation
    local particleDict = "core"
    local particleName = "ent_amb_waterfall_splash_p"
    RequestNamedPtfxAsset(particleDict)
    while not HasNamedPtfxAssetLoaded(particleDict) do
        Wait(0)
    end

    UseParticleFxAssetNextCall(particleDict)
    local particle = StartParticleFxLoopedOnEntity(particleName, vehicle, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

    -- Soundeffekt abspielen
    PlaySoundFromEntity(-1, "SPRAY", vehicle, "CAR_WASH_SOUNDS", true, 0)

    -- Warten Sie für die Dauer der Wäsche
    Wait(duration * 1000)

    -- Beenden der Animation
    StopParticleFxLooped(particle, 0)
    RemoveNamedPtfxAsset(particleDict)

    -- Fahrzeug sauber machen
    SetVehicleDirtLevel(vehicle, 0.0)
    ShowNotification(Translate('wash_complete', math.floor(cleanDuration / 3600)))

    -- Sauberkeitsstatus speichern
    cleanVehicles[plate] = GetGameTimer() + (cleanDuration * 1000)
    TriggerServerEvent('carwash:updateCleanStatus', plate, cleanVehicles[plate])

    FreezeEntityPosition(vehicle, false)
    isWashing = false
end

-- Hält das Fahrzeug für die angegebene Dauer sauber
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if vehicle ~= 0 then
            local plate = GetVehicleNumberPlateText(vehicle)
            if cleanVehicles[plate] and cleanVehicles[plate] > GetGameTimer() then
                SetVehicleDirtLevel(vehicle, 0.0)
            else
                cleanVehicles[plate] = nil
            end
        end
        Wait(1000)
    end
end)

-- Funktion zum Berechnen des dynamischen Preises
function CalculateDynamicPrice(basePrice)
    if Config.DynamicPricing.enabled then
        local hour = GetClockHours()
        if hour >= Config.DynamicPricing.peakHours.start and hour < Config.DynamicPricing.peakHours.to then
            return math.floor(basePrice * Config.DynamicPricing.peakMultiplier)
        end
    end
    return basePrice
end

-- Funktion zum Zeichnen von 3D-Text
function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local camCoords = GetGameplayCamCoord()
    local distance = #(camCoords - vector3(x, y, z))

    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 215)
        SetTextCentre(true)
        SetTextDropshadow(1, 1, 1, 1, 255)
        SetTextOutline()
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

-- Funktion zum Anzeigen von Benachrichtigungen
function ShowNotification(msg)
    lib.notify({
        title = Translate('car_wash'),
        description = msg,
        type = 'inform'
    })
end
