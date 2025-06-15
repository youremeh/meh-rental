Config = {}

Config.PlatePrefix = 'RENT' -- up to 8 chars (prefix + numbers - will add random numbers if less than 8)
Config.RefundPercent = 0.65 -- 65% refund - takes damage into account

Config.Vehicles = {
    { label = 'Sultan', model = 'sultan', price = 250 },
}

Config.Locations = {
    {
        coords = vec3(-963.34, -388.5, 37.84), heading = 117.17,
        spawn = vec4(-970.87, -391.75, 37.1, 28.41),
        label = 'Vehicle Rental', pedModel = 'a_m_m_business_01',
        blip = { sprite = 225, color = 3, scale = 0.75 }
    }
}