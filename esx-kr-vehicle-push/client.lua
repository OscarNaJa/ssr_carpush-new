ESX = nil
Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)
RegisterCommand('vehicle-push', function()
    if IsControlPressed(0, 21 --[[LEFTSHIFT]]) then
        local ped = PlayerPedId()
        local closestVehicle, Distance = ESX.Game.GetClosestVehicle()
        local checkpush = true
        if not IsVehicleSeatFree(closestVehicle, -1) --[[and GetVehicleEngineHealth(closestVehicle) /10 >= Config.DamageNeeded]] then
            checkpush = false
        end
        local vehicleCoords = GetEntityCoords(closestVehicle)
        local dimension = GetModelDimensions(GetEntityModel(closestVehicle), First, Second)
        local IsInFront = false
        
        if Distance < 3.0  and not IsPedInAnyVehicle(ped, false) and checkpush then
            if not IsEntityAttachedToEntity(ped, closestVehicle) then
                NetworkRequestControlOfEntity(closestVehicle)
                if GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle), GetEntityCoords(ped), true) > GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle) * -1, GetEntityCoords(ped), true) then
                    IsInFront = false
                    AttachEntityToEntity(PlayerPedId(), closestVehicle, GetPedBoneIndex(6286), 0.0, dimension.y - 0.3, dimension.z  + 1.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, true)
                else
                    IsInFront = true
                    AttachEntityToEntity(PlayerPedId(), closestVehicle, GetPedBoneIndex(6286), 0.0, dimension.y * -1 + 0.1 , dimension.z + 1.0, 0.0, 0.0, 180.0, 0.0, false, false, true, false, true)
                end
            end
            ESX.Streaming.RequestAnimDict('missfinale_c2ig_11')
            TaskPlayAnim(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0, -8.0, -1, 35, 0, 0, 0, 0)
            Citizen.Wait(200)
            while true do Wait(7)
                if IsControlPressed(0, 34) then
                    TaskVehicleTempAction(PlayerPedId(), closestVehicle, 11, 1000)
                end
                if IsControlPressed(0, 9) then
                    TaskVehicleTempAction(PlayerPedId(), closestVehicle, 10, 1000)
                end
                if IsInFront then
                    SetVehicleForwardSpeed(closestVehicle, -1.25)
                else
                    SetVehicleForwardSpeed(closestVehicle, 1.25)
                end
                if HasEntityCollidedWithAnything(closestVehicle) then
                    SetVehicleOnGroundProperly(closestVehicle)
                end
                if not IsControlPressed(0, 38) then
                    DetachEntity(ped, false, false)
                    StopAnimTask(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
                    FreezeEntityPosition(ped, false)
                    break
                end
            end
        end
    end
end, false)
RegisterKeyMapping('vehicle-push', 'vehicle-push[E]', 'keyboard', 'e')