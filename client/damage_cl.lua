AddEventHandler('gameEventTriggered', function(name, data)
    if name == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        local attacker = data[2]
        local weaponHash = data[3]
        local damage = data[6]
        local playerPed = PlayerPedId()
        
        if IsEntityAPed(victim) and IsEntityAPed(attacker) and IsPedAPlayer(victim) and IsPedAPlayer(attacker) then
            if victim == playerPed then
                local attackerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
                print("VICTIME DEGATS: Tu as recu " .. damage .. " degats de joueur " .. attackerId)
            end
            
            if attacker == playerPed then
                local victimId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim))
                print("TIREUR DEGATS: Tu as inflige " .. damage .. " degats a joueur " .. victimId)
            end
        end
    end
end)