local KGCore = exports['kg-core']:GetCoreObject()

-- Functions

local function ResetHouseStateTimer(house)
    CreateThread(function()
        Wait(Config.TimeToCloseDoors * 60000)
        Config.Houses[house]['opened'] = false
        for _, v in pairs(Config.Houses[house]['furniture']) do
            v['searched'] = false
        end
        TriggerClientEvent('kg-houserobbery:client:ResetHouseState', -1, house)
    end)
end

-- Callbacks

KGCore.Functions.CreateCallback('kg-houserobbery:server:GetHouseConfig', function(_, cb)
    cb(Config.Houses)
end)

-- Events

RegisterNetEvent('kg-houserobbery:server:SetBusyState', function(cabin, house, bool)
    Config.Houses[house]['furniture'][cabin]['isBusy'] = bool
    TriggerClientEvent('kg-houserobbery:client:SetBusyState', -1, cabin, house, bool)
end)

RegisterNetEvent('kg-houserobbery:server:enterHouse', function(house)
    local src = source
    if not Config.Houses[house]['opened'] then
        ResetHouseStateTimer(house)
        TriggerClientEvent('kg-houserobbery:client:setHouseState', -1, house, true)
    end
    TriggerClientEvent('kg-houserobbery:client:enterHouse', src, house)
    Config.Houses[house]['opened'] = true
end)

RegisterNetEvent('kg-houserobbery:server:searchFurniture', function(cabin, house)
    local src = source
    local player = KGCore.Functions.GetPlayer(src)
    local tier = Config.Houses[house].tier
    local availableItems = Config.Rewards[tier][Config.Houses[house].furniture[cabin].type]
    local itemCount = math.random(0, 3)
    if itemCount > 0 then
        for _ = 1, itemCount do
            local selectedItem = availableItems[math.random(1, #availableItems)]
            local itemInfo = KGCore.Shared.Items[selectedItem.item]

            if not itemInfo.unique then
                local amount = math.random(selectedItem.min, selectedItem.max)
                exports['kg-inventory']:AddItem(src, selectedItem.item, amount, false, false, 'kg-houserobbery:server:searchFurniture')
            else
                exports['kg-inventory']:AddItem(src, selectedItem.item, 1, false, false, 'kg-houserobbery:server:searchFurniture')
            end
            TriggerClientEvent('kg-inventory:client:ItemBox', src, itemInfo, 'add')
            Wait(500)
        end
    else
        TriggerClientEvent('KGCore:Notify', src, Lang:t('error.emty_box'), 'error')
    end
    Config.Houses[house]['furniture'][cabin]['searched'] = true
    TriggerClientEvent('kg-houserobbery:client:setCabinState', -1, house, cabin, true)
end)

RegisterNetEvent('kg-houserobbery:server:removeAdvancedLockpick', function()
    local Player = KGCore.Functions.GetPlayer(source)
    if not Player then return end
    exports['kg-inventory']:RemoveItem(source, 'advancedlockpick', 1, false, 'kg-houserobbery:server:removeAdvancedLockpick')
end)

RegisterNetEvent('kg-houserobbery:server:removeLockpick', function()
    local Player = KGCore.Functions.GetPlayer(source)
    if not Player then return end
    exports['kg-inventory']:RemoveItem(source, 'lockpick', 1, false, 'kg-houserobbery:server:removeLockpick')
end)
