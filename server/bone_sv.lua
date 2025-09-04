RegisterServerEvent('hitDetection:notify')
AddEventHandler('hitDetection:notify', function(attackerId, victimId, boneName, damage, type)
    local attacker = GetPlayerName(attackerId)
    local victim = GetPlayerName(victimId)
    
    if type == 'attacker' then
        print("SERVEUR: " .. attacker .. " (" .. attackerId .. ") a touche " .. victim .. " (" .. victimId .. ") sur " .. boneName .. " - Degats: " .. damage)
    elseif type == 'victim' then
        print("SERVEUR: " .. victim .. " (" .. victimId .. ") touche par " .. attacker .. " (" .. attackerId .. ") sur " .. boneName .. " - Degats: " .. damage)
    end
end)