local QBCore = exports['qb-core']:GetCoreObject()
local jamProbability = 0.05  -- 5% chance of jamming
local jammedWeapons = {}
local originalAmmo = {}

-- Function to check if the player is a police officer
local function isPlayerPolice()
    local PlayerData = QBCore.Functions.GetPlayerData()
    return PlayerData.job.name == "police"
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        if IsPedShooting(playerPed) then
            local weaponHash = GetSelectedPedWeapon(playerPed)
            if not jammedWeapons[weaponHash] and not isPlayerPolice() then
                if math.random() < jamProbability then
                    jammedWeapons[weaponHash] = true
                    originalAmmo[weaponHash] = GetAmmoInPedWeapon(playerPed, weaponHash)
                    SetPedAmmo(playerPed, weaponHash, 0)
                    QBCore.Functions.Notify("Your gun has jammed! Press R to unjam.", "error")
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 45) then  -- R key
            local playerPed = PlayerPedId()
            local weaponHash = GetSelectedPedWeapon(playerPed)
            if jammedWeapons[weaponHash] then
                jammedWeapons[weaponHash] = nil
                SetPedAmmo(playerPed, weaponHash, originalAmmo[weaponHash])
                QBCore.Functions.Notify("You have unjammed your gun.", "success")
            end
        end
    end
end)
