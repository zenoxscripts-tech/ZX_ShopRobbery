local spawnedPeds = {}
local isTextUiVisible = false
local inZone = false

-----
--| Pomocne Funkcije
-----

local function ShowNotify(title, description, type, duration)
    if Config.Settings.Notify.type == "ox_lib" then
        lib.notify({
            title = title,
            description = description,
            duration = duration or 5000,
            type = type or "info"
        })
    end
    
    if Config.Settings.Notify.type == "esx_notify" then
        exports['esx_notify']:Notify(type or info, title, duration or 5000, description) 
    end

    if Config.Settings.Notify.type == "okokNotify" then
        exports['okokNotify']:Alert(title, description, duration or 5000, type)
    end
end

local function HasEnoughPolice()
    local police = 0

    local activePlayers = GetActivePlayers()
 
    for _, player in ipairs(activePlayers) do 
        if Config.Settings.Framework.type == "esx" then
            local ESX = exports["es_extended"]:getSharedObject()

            if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.RobberySettings.required_jobs.job then
                police = police + 1
            end

        elseif Config.Settings.Framework.type == "qb-core" then
            local QBCore = exports['qb-core']:GetCoreObject()

            local PlayerData = QBCore.Functions.GetPlayerData()

            if PlayerData.job and PlayerData.job.name == Config.RobberySettings.required_jobs.job then
                police = police + 1
            end
        end
    end

    if not (police >= Config.RobberySettings.required_jobs.min_job_members_online) then
        return false
    end

    return true
end

local function CanGettingCash(pedIndex)
    if pedIndex.state ~= "hands_up" then
        return false
    end

    if pedIndex.waitStartRobberyTime == nil then
        pedIndex.waitStartRobberyTime = GetGameTimer()
    end

    if (GetGameTimer() - pedIndex.waitStartRobberyTime) < Config.RobberySettings.timeToHandsUpToCash then
        return false
    end

    return true
end


local function GettingCashAnimation(ped, pedIndex)
    ClearPedTasksImmediately(ped)

    RequestAnimDict(pedIndex.config.GettingCash.animations.animName)

    while not HasAnimDictLoaded(pedIndex.config.GettingCash.animations.animName) do
        Wait(10)
    end

    TaskPlayAnim(
        ped,
        pedIndex.config.GettingCash.animations.animName,
        pedIndex.config.GettingCash.animations.animDict,
        8.0,
        -8.0,
        -1,
        49,
        0,
        false,
        false,
        false
    )    

end

local function StartHandUpAnimation(robberyPed, shop)
    ClearPedTasksImmediately(robberyPed)

    RequestAnimDict(shop.Ped.animations.animName)

    while not HasAnimDictLoaded(shop.Ped.animations.animName) do
        Wait(10)
    end

    TaskPlayAnim(
        robberyPed,
        shop.Ped.animations.animName,
        shop.Ped.animations.animDict,
        8.0,
        -8.0,
        -1,
        49,
        0,
        false,
        false,
        false
    )    
end

local function StartPlacingCashAnimation(ped, shop)
    RequestAnimDict(shop.config.PlacingCash.animations.animName)

    while not HasAnimDictLoaded(shop.config.PlacingCash.animations.animName) do
        Wait(10)
    end

    TaskPlayAnim(
        ped,
        shop.config.PlacingCash.animations.animName,
        shop.config.PlacingCash.animations.animDict,
        8.0,
        -8.0,
        -1,
        0,
        0,
        false,
        false,
        false
    )   

end

local function ProccessPlacingCash() 
    for _, cashierPed in ipairs(spawnedPeds) do
        if cashierPed.state == "placing_cash" then        
            StartPlacingCashAnimation(cashierPed.ped, cashierPed)
            cashierPed.state = "placing_cash_finished"
        end
    end
end

local function ProcessGettingCash() 
    for _, cashierPed in ipairs(spawnedPeds) do
        if cashierPed.state == "getting_cash" then

            if cashierPed.gettingCashStartTime == nil then
                cashierPed.gettingCashStartTime = GetGameTimer()
                GettingCashAnimation(cashierPed.ped, cashierPed)
            end

            local elapsed = GetGameTimer() - cashierPed.gettingCashStartTime

            if elapsed >= Config.RobberySettings.gettingCashTime then
                ClearPedTasksImmediately(cashierPed.ped)
                cashierPed.state = "placing_cash"
                cashierPed.gettingCashStartTime = nil
            end
        end
    end
end

local function SpawnShopPed(shopIndex, index)
    local ped = shopIndex.Ped
    local pedModel = GetHashKey(ped.model)

    if not IsModelValid(pedModel) then
        print("WARNING: Invalid ped model: " .. ped.model)
        return
    end

    RequestModel(pedModel)

    while not HasModelLoaded(pedModel) do
        Wait(0)
    end

    local shopPed = CreatePed(
		4, 
		pedModel, 
		ped.coords.x, 
		ped.coords.y, 
		ped.coords.z, 
		ped.coords.w, 
		false, 
		false
	)

    spawnedPeds[index] = {
        config = shopIndex,
        ped = shopPed,
        moneyBag = nil,
        state = "idle",
        aimStartTime = nil,
        waitStartRobberyTime = nil,
        gettingCashStartTime = nil,
        cooldown = nil
    }

    TaskStartScenarioInPlace(shopPed, ped.animations.normalScenario, 0, true)

    FreezeEntityPosition(shopPed, true)
    SetEntityInvincible(shopPed, true)
    SetBlockingOfNonTemporaryEvents(shopPed, true)

end

local function SetupMoneyBagInteraction(shop)
    if Config.Settings.Interaction.type == "ox_target" then
        exports.ox_target:addLocalEntity(shop.moneyBag, {
            {
                name = "pickup_money_bag",
                label = Locales.PickupMoneyBagTargetLabel,
                distance = Config.Settings.Interaction.distance,
                icon =  Config.Settings.Interaction.targetIcon,
                onSelect = function()
                    shop.state = "finished"
                    shop.cooldown = GetGameTimer()
                    TriggerServerEvent("ZX_ShopRobbery:MoneyBagPickedUp", shop)
                end
            }
        })

        ShowNotify(Locales.SpawnMoneyBagPropTitle, Locales.SpawnMoneyBagPropDescription, "info", Config.Settings.Notify.notifyDuration)
    elseif Config.Settings.Interaction.type == "qb-target" then
        exports['qb-target']:AddTargetEntity(shop.moneyBag, {
            options = {
                {
                    num = 1,
                    icon = Config.Settings.Interaction.targetIcon,
                    label = Locales.PickupMoneyBagTargetLabel,
                    action = function()
                        shop.state = "finished"
                        shop.cooldown = GetGameTimer()
                        TriggerServerEvent("ZX_ShopRobbery:MoneyBagPickedUp", shop)
                    end,
                }
            },
            distance = Config.Settings.Interaction.distance
        }) 

        ShowNotify(Locales.SpawnMoneyBagPropTitle, Locales.SpawnMoneyBagPropDescription, "info", Config.Settings.Notify.notifyDuration)
    end
end

local function SpawnMoneyBagProp(shop)
    local propModel = GetHashKey(shop.config.PlacingCash.prop)

    if not IsModelValid(propModel) then
        print("WARNING: Invalid prop model: " .. shop.config.PlacingCash.prop)
        return
    end

    RequestModel(propModel)  

    while not HasModelLoaded(propModel) do
        Wait(0)
    end

    local obj = CreateObject(propModel, shop.config.PlacingCash.coords, true, true, false)

    shop.state = "waiting_for_pickup"

    shop.moneyBag = obj

    SetupMoneyBagInteraction(shop)
                    
end

local function ShowTextUi(shop)
    local playerPedId = PlayerPedId()
    local coords = GetEntityCoords(playerPedId)
    local distance = #(coords - shop.config.PlacingCash.coords)

    if distance > Config.Settings.Interaction.distance then
        return
    end

    inZone = true

    if not isTextUiVisible and inZone then
        isTextUiVisible = true
        lib.showTextUI(Locales.PickupMoneyBagTextUiLabel)
        ShowNotify(Locales.SpawnMoneyBagPropTitle, Locales.SpawnMoneyBagPropDescription, "info", Config.Settings.Notify.notifyDuration)
    end

    if not shop.state == "finished" then
        ShowNotify(Locales.SpawnMoneyBagPropTitle, Locales.SpawnMoneyBagPropDescription, "info", Config.Settings.Notify.notifyDuration)
    end
end

local function HideTextUI()
    if not inZone and isTextUiVisible then
        lib.hideTextUI()
        isTextUiVisible = false
    end
end

local function IsCooldownFinished(shop)
    if shop.cooldown == nil then
        return true
    end

    local now = GetGameTimer()
    local elapsed = now - shop.cooldown
    local cooldown = Config.RobberySettings.cooldown
    local remainingSeconds = math.floor((cooldown - elapsed) / 1000)
    local minutes = math.floor(remainingSeconds / 60)
    local seconds = remainingSeconds - (minutes * 60)
    local remainingCooldown = string.format("%02d:%02d", minutes, seconds)
 
    if elapsed < cooldown then
        ShowNotify(Locales.CooldownRemainingTitle, Locales.CooldownRemainingDescription .. remainingCooldown .. "min", "error", Config.Settings.Notify.notifyDuration)
        return false
    end

    return true
end

-----
--| Glavne Funkcije
-----

local function StartRobberyInteraction()
    if not IsPlayerFreeAiming(PlayerId()) then
        return false
    end

    local success, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())  

    if not success then
        return false
    end 

    for i, cashierPed in ipairs(spawnedPeds) do 

        if entity == cashierPed.ped then

            local cooldownFinished = IsCooldownFinished(cashierPed)

            if not cooldownFinished then
                return
            end

            if cashierPed.aimStartTime == nil then
                cashierPed.aimStartTime = GetGameTimer()

            end
            return true, cashierPed
        end

    end

end

local function RestartShopRobbery()

    for _, shop in ipairs(spawnedPeds) do
        
        if shop.state == "finished" then

            shop.state = "idle"

            local coords = shop.config.Ped.coords
            SetEntityCoords(shop.ped, coords.x, coords.y, coords.z, false, false, false, true)
            SetEntityHeading(shop.ped, coords.w)
            FreezeEntityPosition(shop.ped, true)
            TaskStartScenarioInPlace(
                shop.ped,
                shop.config.Ped.animations.normalScenario,
                0,
                true
            )

        end
    end
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for _, peds in ipairs(spawnedPeds) do 

        if DoesEntityExist(peds.ped) then
            DeleteEntity(peds.ped)
        end
    end
end)

RegisterNetEvent("ZX_ShopRobbery:MoneyBagDelite")
AddEventHandler("ZX_ShopRobbery:MoneyBagDelite", function(shop)
    if Config.Settings.Interaction.type == "qb-target" then
        exports['qb-target']:RemoveTargetEntity(shop.moneyBag, Locales.PickupMoneyBagTargetLabel)

    elseif Config.Settings.Interaction.type == "ox_target" then
        exports.ox_target:removeLocalEntity(shop.moneyBag, "pickup_money_bag")
    end

    DeleteEntity(shop.moneyBag)
    shop.moneyBag = nil
    ShowNotify(Locales.PickupMoneyBagTitle, Locales.PickupMoneyBagDescription, "success", Config.Settings.Notify.notifyDuration)
    RestartShopRobbery()
end)

local function ProcessShopState(pedIndex)
    if pedIndex.state == "idle" then
        pedIndex.state = "aiming"
    
    elseif pedIndex.state == "aiming" then
        local elapsed = GetGameTimer() - pedIndex.aimStartTime

        if elapsed >= Config.RobberySettings.aim_time_required then
            pedIndex.state = "hands_up" 
            StartHandUpAnimation(pedIndex.ped, pedIndex.config)
            ShowNotify(Locales.StartRobberyTitle, Locales.StartRobberyDescription, "success", Config.Settings.Notify.notifyDuration)
        end

    elseif pedIndex.state == "hands_up" then
        if CanGettingCash(pedIndex) then
            pedIndex.state = "go_to_cash"
            FreezeEntityPosition(pedIndex.ped, false)
        end

    elseif pedIndex.state == "go_to_cash" then
        TaskGoStraightToCoord(pedIndex.ped, pedIndex.config.GettingCash.coords.x, pedIndex.config.GettingCash.coords.y, pedIndex.config.GettingCash.coords.z, 1.0, -1, pedIndex.config.GettingCash.heading, 0.0) 
        pedIndex.state = "walking_to_cash"

    end
end

local function ProcessShopPeds()
    for _, shopIndex in ipairs(spawnedPeds) do
        if shopIndex.state == "walking_to_cash" then

            local coords = GetEntityCoords(shopIndex.ped)
            local distance = #(coords - shopIndex.config.GettingCash.coords)

            if distance < 1.2 then
                shopIndex.state = "turning_to_cash"

                Citizen.SetTimeout(1000, function()

                    TaskAchieveHeading(shopIndex.ped, shopIndex.config.GettingCash.heading, 1000)

                    Citizen.SetTimeout(1500, function()
                        shopIndex.state = "getting_cash"
                    end)
                end)
            end
        end
    end
end

-----
--| Thread
-----

CreateThread(function()
    for i, shop in ipairs(Config.Robberys) do
        SpawnShopPed(shop, i)
    end

end)

CreateThread(function()
    local sleep = 500 
    while true do 
        inZone = false
        for _, shop in ipairs(spawnedPeds) do 
            if shop.state == "placing_cash_finished" then
                SpawnMoneyBagProp(shop)

            elseif shop.state == "waiting_for_pickup" then
                sleep = 0
                if Config.Settings.Interaction.type == "textUi" then
                    ShowTextUi(shop)
                end

                if IsControlJustReleased(0, 38) then
                    shop.cooldown = GetGameTimer()
                    shop.state = "finished"
                    TriggerServerEvent("ZX_ShopRobbery:MoneyBagPickedUp", shop)
                end
            end
        end 

        if Config.Settings.Interaction.type == "textUi" then
            HideTextUI()
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    local sleep = 500
    while true do 

        local success, pedIndex = StartRobberyInteraction()

        if success then 
            if HasEnoughPolice() then
                ProcessShopState(pedIndex)

            else
                ShowNotify(Locales.NotEnoughPoliceAvailableTitle, Locales.NotEnoughPoliceAvailableDescription, "error", 5000)
            end
        end

        ProcessShopPeds()

        ProcessGettingCash()

        ProccessPlacingCash()   

        if not success then 
            for _, shop in ipairs(spawnedPeds) do
                if shop.state == "aiming" then
                    shop.state = "idle"
                    shop.aimStartTime = nil
                    shop.waitStartRobberyTime = nil

                elseif shop.state == "hands_up" then
                    shop.state = "idle"
                    shop.aimStartTime = nil
                    shop.waitStartRobberyTime = nil

                end
            end
        end

        Wait(sleep)
    end
end)            
