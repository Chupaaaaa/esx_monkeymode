ESX = exports["es_extended"]:getSharedObject()

local currentSkin = nil
local screenEffect = Config.screenEffect
local effectTime = Config.effectTime
local runSpeed = Config.runSpeedMultiplier
local walkSpeed = Config.walkSpeedMultiplier
local used = false
local playerWeapons = {}

function savePlayerWeapons()
    local playerId = PlayerId()
    local playerPedId = PlayerPedId()
    playerWeapons = {}

    for _, weapon in ipairs(ESX.GetPlayerData().loadout) do
        table.insert(playerWeapons, {
            name = weapon.name,
            ammo = GetAmmoInPedWeapon(playerPedId, GetHashKey(weapon.name))
        })

        RemoveWeaponFromPed(playerPedId, GetHashKey(weapon.name))
        TriggerServerEvent('esx:removeWeapon', weapon.name)
    end
end

function restorePlayerWeapons()
    local playerId = PlayerId()
    local playerPedId = PlayerPedId()

    for _, weapon in ipairs(playerWeapons) do
        GiveWeaponToPed(playerPedId, GetHashKey(weapon.name), weapon.ammo, false, false)
        TriggerServerEvent('esx:addWeapon', weapon.name, weapon.ammo)
    end
end

function saveOldSkin()
    TriggerEvent('skinchanger:getSkin', function(skin)
        currentSkin = skin
    end)
end

function startMonkeyMode()
    local playerId = PlayerId()
    local playerPedId = PlayerPedId()
    local model = "a_c_chimp"

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(10)
    end

    SetPlayerModel(playerId, model)

    AnimpostfxPlay(screenEffect, 0, true)

    SetRunSprintMultiplierForPlayer(playerId, runSpeed)
    SetPedMoveRateOverride(playerPedId, walkSpeed)
end

function stopMonkeyMode()
    local playerId = PlayerId()
    local playerPedId = PlayerPedId()
    local model = "mp_m_freemode_01"

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(10)
    end

    SetPlayerModel(playerId, model)

    TriggerEvent('skinchanger:loadSkin', currentSkin)

    AnimpostfxStop(screenEffect)

    SetRunSprintMultiplierForPlayer(playerId, 1.0)
    SetPedMoveRateOverride(playerPedId, 1.0)
end

function monkeymode()
    local playerId = PlayerId()
    local playerPedId = PlayerPedId()
    saveOldSkin()
    savePlayerWeapons()

    Wait(100)

    startMonkeyMode()

    Wait(effectTime)

    stopMonkeyMode()
    restorePlayerWeapons()
end

RegisterCommand("monkeymode", function ()
    if used then
        print("Der MONKEYMODE kann nur einmal pro Login genutzt werden!")
    else
        monkeymode()

        used = true
    end
end, Config.restricted)