local boneNames = {
    [31086] = "TETE",
    [39317] = "COU", 
    [57597] = "COLONNE",
    [23553] = "DOS_BAS",
    [24816] = "DOS_MILIEU", 
    [24817] = "DOS_HAUT",
    [24818] = "TORSE",
    [10706] = "CLAVICULE_G",
    [64729] = "BRAS_G",
    [45509] = "AVANT_BRAS_G", 
    [18905] = "MAIN_G",
    [64016] = "CLAVICULE_D",
    [40269] = "BRAS_D",
    [28252] = "AVANT_BRAS_D",
    [57005] = "MAIN_D", 
    [11816] = "BASSIN",
    [58271] = "CUISSE_G",
    [63931] = "MOLLET_G",
    [14201] = "PIED_G",
    [51826] = "CUISSE_D", 
    [36864] = "MOLLET_D",
    [52301] = "PIED_D"
}

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
        local closestBone = 31086
        local closestDistance = 999.0
        
        for boneId, boneName in pairs(boneNames) do
            local boneCoords = GetPedBoneCoords(victim, boneId, 0.0, 0.0, 0.0)
            local distance = #(hitCoords - boneCoords)
            
            if distance < closestDistance then
                closestDistance = distance
                closestBone = boneId
            end
        end
        
        return closestBone
    end
    
    return 31086
end

AddEventHandler('gameEventTriggered', function(name, data)
    if name == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        local attacker = data[2]
        local weaponHash = data[3]
        local damage = data[6]
        local playerPed = PlayerPedId()
        
        if IsEntityAPed(victim) and IsEntityAPed(attacker) and IsPedAPlayer(victim) and IsPedAPlayer(attacker) then
            local bone = GetHitBone(victim)
            local boneName = boneNames[bone] or ("BONE_" .. tostring(bone))
            
            if victim == playerPed then
                local attackerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
                print("VICTIME: Touche par joueur " .. attackerId .. " sur " .. boneName .. " (Degats: " .. damage .. ")")
                TriggerServerEvent('hitDetection:notify', attackerId, GetPlayerServerId(PlayerId()), boneName, damage, 'victim')
            end
            
            if attacker == playerPed then
                local victimId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim))
                print("TIREUR: Tu as touche joueur " .. victimId .. " sur " .. boneName .. " (Degats: " .. damage .. ")")
                TriggerServerEvent('hitDetection:notify', GetPlayerServerId(PlayerId()), victimId, boneName, damage, 'attacker')
            end
        end
    end
end)