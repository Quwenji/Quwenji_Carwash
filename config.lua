-- Konfigurationsdatei

Config = {}

-- Autowasch-Standorte
Config.CarWashLocations = {
    vector3(26.5512, -1391.9619, 29.3628),
    vector3(168.0035, -1715.3590, 29.2917),
    vector3(-74.3135, 6427.6465, 31.4400),
    vector3(-699.6396, -932.6825, 19.0139),
    -- Weitere Standorte können hier hinzugefügt werden
}

-- Waschoptionen
Config.WashOptions = {
    {
        label = 'Standardwäsche',
        cleanDuration = 12 * 60 * 60, -- Fahrzeug bleibt 12 Stunden sauber
        price = 100, -- Basispreis für die Standardwäsche
        duration = 5 -- Dauer der Wäsche in Sekunden
    },
    {
        label = 'Premiumwäsche',
        cleanDuration = 24 * 60 * 60, -- Fahrzeug bleibt 24 Stunden sauber
        price = 200, -- Basispreis für die Premiumwäsche
        duration = 8 -- Dauer der Wäsche in Sekunden
    }
}

-- Währungssymbol
Config.CurrencySymbol = "$"

-- Jobname für das Konto, das das Geld erhalten soll
Config.JobAccount = 'staatsbank' -- Ändern Sie dies zum gewünschten Job (z.B. 'mechanic', 'carwash')

-- Dynamische Preisgestaltung
Config.DynamicPricing = {
    enabled = true,
    peakHours = { start = 18, to = 22 }, -- Hauptzeiten (18:00 bis 22:00)
    peakMultiplier = 1.5 -- Preissteigerung während der Hauptzeiten
}

-- Sprachoptionen
Config.Locale = 'de' -- Verfügbare Optionen: 'de', 'en'
