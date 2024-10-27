-- Server-Skript

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Speichert saubere Fahrzeuge
local cleanVehicles = {}

-- Event-Handler für die Zahlung und Start der Wäsche
RegisterServerEvent('carwash:pay')
AddEventHandler('carwash:pay', function(price, cleanDuration, duration, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local jobAccount = Config.JobAccount

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)

        -- Geld zum Job-Konto hinzufügen
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. jobAccount, function(account)
            if account then
                account.addMoney(price)
            else
                print('Gesellschaftskonto für Job "' .. jobAccount .. '" nicht gefunden.')
            end
        end)

        -- Client-Event auslösen, um die Wäsche zu starten
        TriggerClientEvent('carwash:startWash', source, cleanDuration, duration, plate)
    else
        -- Nicht genügend Geld
        TriggerClientEvent('carwash:notEnoughMoney', source)
    end
end)

-- Laden gespeicherter Sauberkeitsdaten
RegisterServerEvent('carwash:requestCleanVehicles')
AddEventHandler('carwash:requestCleanVehicles', function()
    local src = source
    MySQL.Async.fetchAll('SELECT * FROM carwash_clean_vehicles', {}, function(results)
        for _, v in pairs(results) do
            cleanVehicles[v.plate] = v.clean_until
        end
        TriggerClientEvent('carwash:loadCleanVehicles', src, cleanVehicles)
    end)
end)

-- Aktualisiert den Sauberkeitsstatus in der Datenbank
RegisterServerEvent('carwash:updateCleanStatus')
AddEventHandler('carwash:updateCleanStatus', function(plate, cleanUntil)
    cleanVehicles[plate] = cleanUntil
    MySQL.Async.execute('REPLACE INTO carwash_clean_vehicles (plate, clean_until) VALUES (@plate, @clean_until)', {
        ['@plate'] = plate,
        ['@clean_until'] = cleanUntil
    })
end)
