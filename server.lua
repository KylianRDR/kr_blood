RegisterServerEvent('damageSystem:damageReceived')
AddEventHandler('damageSystem:damageReceived', function(attackerId, victimId, damage, boneName)
    local attackerName = GetPlayerName(attackerId)
    local victimName = GetPlayerName(victimId)
    
    print("SERVEUR: " .. victimName .. " (" .. victimId .. ") a recu " .. damage .. " degats de " .. attackerName .. " (" .. attackerId .. ") sur " .. boneName)
end)

RegisterServerEvent('damageSystem:damageDealt')
AddEventHandler('damageSystem:damageDealt', function(attackerId, victimId, damage, boneName)
    local attackerName = GetPlayerName(attackerId)
    local victimName = GetPlayerName(victimId)
    
    print("SERVEUR: " .. attackerName .. " (" .. attackerId .. ") a inflige " .. damage .. " degats a " .. victimName .. " (" .. victimId .. ") sur " .. boneName)
end)

RegisterServerEvent('damageSystem:stateChanged')
AddEventHandler('damageSystem:stateChanged', function(state, message)
    local playerName = GetPlayerName(source)
    
    print("SERVEUR: " .. playerName .. " (" .. source .. ") est maintenant en etat: " .. message)
end)