ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end
end)

local function canPushVehicle(ped)
    return not IsEntityDead(ped)
        and not IsPedFatallyInjured(ped)
        and not IsPedRagdoll(ped)
        and not IsPedBeingStunned(ped)
        and not IsPedFalling(ped)
        and not IsPedInParachuteFreeFall(ped)
end

RegisterCommand('vehicle-push', function()
    if not IsControlPressed(0, 21 --[[LEFTSHIFT]]) then
        return
    end

    local ped = PlayerPedId()
    if not canPushVehicle(ped) or IsPedInAnyVehicle(ped, false) then
        return
    end

    local closestVehicle, distance = ESX.Game.GetClosestVehicle()
    if closestVehicle == 0 or distance >= 3.0 then
        return
    end

    if not IsVehicleSeatFree(closestVehicle, -1) then
        return
    end

    local isInFront = false
    local vehicleForward = GetEntityForwardVector(closestVehicle)
    local vehicleCoords = GetEntityCoords(closestVehicle)
    local pedCoords = GetEntityCoords(ped)
    local frontCoords = vehicleCoords + vehicleForward
    local rearCoords = vehicleCoords - vehicleForward

    if not IsEntityAttachedToEntity(ped, closestVehicle) then
        NetworkRequestControlOfEntity(closestVehicle)

        local minDim = GetModelDimensions(GetEntityModel(closestVehicle))
        if #(frontCoords - pedCoords) > #(rearCoords - pedCoords) then
            isInFront = false
            AttachEntityToEntity(ped, closestVehicle, GetPedBoneIndex(ped, 6286), 0.0, minDim.y - 0.3, minDim.z + 1.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, true)
        else
            isInFront = true
            AttachEntityToEntity(ped, closestVehicle, GetPedBoneIndex(ped, 6286), 0.0, minDim.y * -1 + 0.1, minDim.z + 1.0, 0.0, 0.0, 180.0, 0.0, false, false, true, false, true)
        end
    end

    ESX.Streaming.RequestAnimDict('missfinale_c2ig_11')
    TaskPlayAnim(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0, -8.0, -1, 35, 0, 0, 0, 0)
    Citizen.Wait(200)

    while true do
        Citizen.Wait(50)

        if not IsControlPressed(0, 38) or not canPushVehicle(ped) then
            break
        end

        if IsControlPressed(0, 34) then
            TaskVehicleTempAction(ped, closestVehicle, 11, 1000)
        elseif IsControlPressed(0, 9) then
            TaskVehicleTempAction(ped, closestVehicle, 10, 1000)
        end

        if isInFront then
            SetVehicleForwardSpeed(closestVehicle, -1.25)
        else
            SetVehicleForwardSpeed(closestVehicle, 1.25)
        end

        if HasEntityCollidedWithAnything(closestVehicle) then
            SetVehicleOnGroundProperly(closestVehicle)
        end
    end

    DetachEntity(ped, false, false)
    StopAnimTask(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
    FreezeEntityPosition(ped, false)
end, false)

RegisterKeyMapping('vehicle-push', 'vehicle-push[E]', 'keyboard', 'e')
