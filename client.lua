local playerHealth = 100
local lastHitTime = {}
local healthState = "normal"
local stateEndTime = 0

local function GetBoneZone(boneId)
    for _, headBone in ipairs(Config.BoneZones.head) do
        if boneId == headBone then
            return "head"
        end
    end
    
    for _, bodyBone in ipairs(Config.BoneZones.body) do
        if boneId == bodyBone then
            return "body"
        end
    end
    
    for _, limbBone in ipairs(Config.BoneZones.limbs) do
        if boneId == limbBone then
            return "limbs"
        end
    end
    
    return "body"
end

local function GetHitBone(victim)
    local hit, bone = GetPedLastDamageBone(victim)
    if hit then
        return bone
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local victimCoords = GetEntityCoords(victim)
    
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
        playerCoords.x, playerCoords.y, playerCoords.z + 0.5,
        victimCoords.x, victimCoords.y, victimCoords.z + 1.0,
        -1, playerPed, 0
    )
    
    local _, rayHit, hitCoords = GetShapeTestResult(rayHandle)
    
    if rayHit == 1 then
        local closestBone = 24818
        local closestDistance = 999.0
        
        for boneId, boneName in pairs(Config.BoneNames) do
            local boneCoords = GetPedBoneCoords(victim, boneId, 0.0, 0.0, 0.0)
            local distance = #(hitCoords - boneCoords)
            
            if distance < closestDistance then
                closestDistance = distance
                closestBone = boneId
            end
        end
        
        return closestBone
    end
    
    return 24818
end

local function CalculateDamage(weaponHash, boneId)
    local weaponConfig = Config.WeaponDamage[weaponHash]
    if not weaponConfig then
        return 10
    end
    
    local zone = GetBoneZone(boneId)
    
    if zone == "head" then
        return weaponConfig.headDamage
    elseif zone == "body" then
        return weaponConfig.bodyDamage
    else
        return weaponConfig.limbDamage
    end
end

local function UpdateHealthState(damage)
    local totalDamage = 100 - playerHealth
    
    for stateName, stateConfig in pairs(Config.HealthStates) do
        if totalDamage >= stateConfig.minDamage and totalDamage <= stateConfig.maxDamage then
            if healthState ~= stateName then
                healthState = stateName
                stateEndTime = GetGameTimer() + stateConfig.duration
                print("ETAT: " .. stateConfig.message)
                TriggerServerEvent('damageSystem:stateChanged', stateName, stateConfig.message)
                
                if stateName == "dead" then
                    SetEntityHealth(PlayerPedId(), 0)
                end
            end
            break
        end
    end
end

local function ProcessDamage(damage)
    playerHealth = playerHealth - damage
    if playerHealth < 0 then
        playerHealth = 0
    end
    
    UpdateHealthState(damage)
end

AddEventHandler('gameEventTriggered', function(name, data)
    if name == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        local attacker = data[2]
        local weaponHash = data[3]
        local playerPed = PlayerPedId()
        
        if IsEntityAPed(victim) and IsEntityAPed(attacker) and IsPedAPlayer(victim) and IsPedAPlayer(attacker) then
            local currentTime = GetGameTimer()
            local hitId = tostring(attacker) .. "_" .. tostring(victim) .. "_" .. tostring(weaponHash) .. "_" .. tostring(currentTime)
            
            if not lastHitTime[hitId] then
                lastHitTime[hitId] = true
                
                Citizen.SetTimeout(100, function()
                    lastHitTime[hitId] = nil
                end)
                
                local bone = GetHitBone(victim)
                local boneName = Config.BoneNames[bone] or ("BONE_" .. tostring(bone))
                local damage = CalculateDamage(weaponHash, bone)
                
                if victim == playerPed then
                    local attackerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
                    local oldHealth = playerHealth
                    ProcessDamage(damage)
                    print("IMPACT: " .. damage .. " degats recu de joueur " .. attackerId .. " sur " .. boneName .. " (Vie: " .. oldHealth .. " -> " .. playerHealth .. ")")
                    TriggerServerEvent('damageSystem:damageReceived', attackerId, GetPlayerServerId(PlayerId()), damage, boneName)
                end
                
                if attacker == playerPed then
                    local victimId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim))
                    print("TIR REUSSI: " .. damage .. " degats inflige a joueur " .. victimId .. " sur " .. boneName)
                    TriggerServerEvent('damageSystem:damageDealt', GetPlayerServerId(PlayerId()), victimId, damage, boneName)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        if healthState ~= "normal" and healthState ~= "dead" then
            if GetGameTimer() >= stateEndTime then
                healthState = "normal"
                print("ETAT: NORMAL")
                TriggerServerEvent('damageSystem:stateChanged', "normal", "NORMAL")
            end
        end
        
        if playerHealth < 100 and healthState == "normal" then
            playerHealth = playerHealth + 1
            if playerHealth > 100 then
                playerHealth = 100
            end
        end
    end
end)

AddEventHandler('playerSpawned', function()
    playerHealth = 100
    healthState = "normal"
    stateEndTime = 0
end)