local ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    exports.ox_target:addGlobalPlayer({
        {
            icon = 'fa-solid fa-stethoscope',
            label = 'Examiner le patient',
            onSelect = function(data)
                local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                TriggerServerEvent('damageSystem:requestMedicalExam', targetId)
            end,
            canInteract = function(entity, distance, coords, name, bone)
                if ESX and ESX.GetPlayerData() and ESX.GetPlayerData().job then
                    return ESX.GetPlayerData().job.name == 'ambulance'
                end
                return false
            end
        }
    })
end)