local QBCore = exports['qb-core']:GetCoreObject()

MySQL.ready(function()
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS vehicle_rentals (
            plate VARCHAR(8) NOT NULL PRIMARY KEY,
            owner VARCHAR(64) NOT NULL,
            model VARCHAR(50) NOT NULL,
            price INT NOT NULL,
            rented_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]], {})
end)

local function getPlayerId(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    return Player.PlayerData.citizenid or Player.PlayerData.license or Player.PlayerData.steam
end

lib.callback.register('qb-vehiclerental:server:rent', function(source, plate, model, price)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    local removed = Player.Functions.RemoveMoney('cash', price)
    if not removed then
        return false
    end

    local ownerId = getPlayerId(source)
    MySQL.Async.execute([[
        INSERT INTO vehicle_rentals (plate, owner, model, price)
        VALUES (@plate, @owner, @model, @price)
    ]], {
        ['@plate'] = plate,
        ['@owner'] = ownerId,
        ['@model'] = model,
        ['@price'] = price
    })

    return true
end)

lib.callback.register('qb-vehiclerental:server:getRental', function(source, plate)
    local ownerId = getPlayerId(source)
    if not ownerId then return nil end

    local result = MySQL.Sync.fetchAll([[
        SELECT price FROM vehicle_rentals
        WHERE plate = @plate AND owner = @owner
    ]], {
        ['@plate'] = plate,
        ['@owner'] = ownerId
    })

    if result and result[1] then
        return { price = result[1].price }
    end
    return nil
end)

RegisterNetEvent('qb-vehiclerental:server:return', function(plate, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ownerId = getPlayerId(src)
    if not ownerId then return end

    local result = MySQL.Sync.fetchAll([[
        SELECT * FROM vehicle_rentals WHERE plate = @plate AND owner = @owner
    ]], {
        ['@plate'] = plate,
        ['@owner'] = ownerId
    })

    if not result or not result[1] then
        return
    end

    Player.Functions.AddMoney('cash', amount, "rental-refund")

    MySQL.Async.execute([[
        DELETE FROM vehicle_rentals WHERE plate = @plate
    ]], {
        ['@plate'] = plate
    })
end)