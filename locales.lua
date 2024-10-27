-- Lokalisierungsdatei

Locales = {
    ['de'] = {
        ['car_wash'] = 'Autowäsche',
        ['press_to_wash'] = '[E] Fahrzeug waschen',
        ['washing_vehicle'] = 'Fahrzeug wird gewaschen, bitte warten...',
        ['wash_complete'] = 'Dein Fahrzeug wurde gewaschen und bleibt für %s Stunden sauber.',
        ['not_enough_money'] = 'Du hast nicht genug Geld, um das Fahrzeug zu waschen.',
        ['vehicle_too_damaged'] = 'Dein Fahrzeug ist zu beschädigt, um es zu waschen.',
        ['not_in_vehicle'] = 'Du musst in einem Fahrzeug sein, um es zu waschen.',
        ['not_driver'] = 'Du musst der Fahrer sein, um das Fahrzeug zu waschen.',
        ['wash_canceled'] = 'Die Fahrzeugwäsche wurde abgebrochen.',
        ['dynamic_price_info'] = 'Aktueller Preis: %s%s',
        ['wash_price'] = 'Preis: %s%s',
    },
    ['en'] = {
        ['car_wash'] = 'Car Wash',
        ['press_to_wash'] = '[E] Wash Vehicle',
        ['washing_vehicle'] = 'Washing vehicle, please wait...',
        ['wash_complete'] = 'Your vehicle has been washed and will stay clean for %s hours.',
        ['not_enough_money'] = 'You do not have enough money to wash the vehicle.',
        ['vehicle_too_damaged'] = 'Your vehicle is too damaged to be washed.',
        ['not_in_vehicle'] = 'You must be in a vehicle to wash it.',
        ['not_driver'] = 'You must be the driver to wash the vehicle.',
        ['wash_canceled'] = 'The vehicle wash was canceled.',
        ['dynamic_price_info'] = 'Current Price: %s%s',
        ['wash_price'] = 'Price: %s%s',
    }
}

function Translate(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
    end
end
