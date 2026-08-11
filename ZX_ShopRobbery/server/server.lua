-----
--| Pomocne funkcije 
-----

local function GiveRework(item, count, shop, src)
    if Config.Settings.Inventory.type == "tgiann-inventory" then
        exports["tgiann-inventory"]:AddItem(src, shop.config.Rework.reworkItem, count)

    elseif Config.Settings.Inventory.type == "ox_inventory" then
        exports.ox_inventory:AddItem(src, shop.config.Rework.reworkItem, count)
    
    elseif Config.Settings.Inventory.type == "qs-inventory" then
        exports['qs-inventory']:AddItem(src, item, count)

    elseif Config.Settings.Inventory.type == "jpr-inventory" then
        exports['jpr-inventory']:AddItem(src, item, count, false, false, 'jpr-inventory:testAdd')

    elseif Config.Settings.Inventory.type == "qb-inventory" then
        exports['qb-inventory']:AddItem(src, item, count, false, false, 'qb-inventory:testAdd')
    end
end

local function HasEnoughPolice()
    local police = 0

    if Config.Settings.Framework.type == "esx" then
        local ESX = exports["es_extended"]:getSharedObject()

        local xPlayers = ESX.GetExtendedPlayers()
        for _, xPlayer in pairs(xPlayers) do
            if xPlayer.job and xPlayer.job.name == Config.RobberySettings.required_jobs.job then
                police = police + 1
            end
        end
    end

    if Config.Settings.Framework.type == "qb-core" then
        local QBCore = exports['qb-core']:GetCoreObject()

        local players = QBCore.Functions.GetQBPlayers()
        for _, Player in pairs(players) do
            if Player.PlayerData.job and Player.PlayerData.job.name == Config.RobberySettings.required_jobs.job then
                police = police + 1
            end
        end
    end

    if not (police >= Config.RobberySettings.required_jobs.min_job_members_online) then
        return false
    end

    return true
end

-----
--| Glavne Funkcije
-----

RegisterNetEvent("ZX_ShopRobbery:MoneyBagPickedUp")
AddEventHandler("ZX_ShopRobbery:MoneyBagPickedUp", function(shop)
    local src = source
    local playerPedId = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPedId)
    local distance = #(playerCoords - shop.config.PlacingCash.coords)

    if distance > 30 then
        return
    end

    local cooldwon = Config.RobberySettings.cooldown / 1000
    local remainingCooldown = (os.time() - shop.cooldown) / 1000

    if shop.cooldown and remainingCooldown < cooldwon then
        return
    end

    if not HasEnoughPolice() then
        return
    end

    local moneyCount = math.random(shop.config.Rework.count.min, shop.config.Rework.count.max)

    GiveRework(shop.config.Rework.reworkItem, moneyCount, shop, src)

    TriggerClientEvent("ZX_ShopRobbery:MoneyBagDelite", src, shop)
end)