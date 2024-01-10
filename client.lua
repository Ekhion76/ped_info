local enable, tempClosestPeds
local closestPeds = {}
local next = next

local function round(num)
    return math.floor(num * 10 + 0.5) / 10
end

local function DrawText3D(coords, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 2.0)
    local dist = #(GetGameplayCamCoords() - coords)

    local scale = (1 / dist) * 15
    local fov = (1 / GetGameplayCamFov()) * 10
    scale = scale * fov

    if onScreen then
        SetTextScale(1.5 * scale, 1.5 * scale)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function start()
    CreateThread(function()
        local pos, model, info
        local pattern = '%s: %s~n~'
        while enable do
            Wait(500)

            pos = GetEntityCoords(PlayerPedId())
            tempClosestPeds = {}

            --for _, player in ipairs(GetActivePlayers()) do
            --      local ped = GetPlayerPed(player)

            for _, ped in pairs(GetGamePool('CPed')) do
                if #(GetEntityCoords(ped) - pos) <= 80 then
                    model = GetEntityModel(ped)
                    info = ''
                    tempClosestPeds[ped] = info
                            .. pattern:format('health', GetEntityHealth(ped))
                            .. pattern:format('vehiclePedIsIn', GetVehiclePedIsIn(ped, false))
                            .. pattern:format('interiorFromEntity', GetInteriorFromEntity(ped)) -- 1536001 = laf2k_race
                    --.. pattern:format('inAnyVehicle', IsPedInAnyVehicle(ped, true))
                    --.. pattern:format('attachedToAnyVehicle', IsEntityAttachedToAnyVehicle(ped))
                    --.. pattern:format('pedMaxHealth', GetPedMaxHealth(ped))
                    --.. pattern:format('entityMaxHealth', GetEntityMaxHealth(ped))
                    --.. pattern:format('pedInMeleeCombat', IsPedInMeleeCombat(ped))
                    --.. pattern:format('lastMaterialHitByEntity', GetLastMaterialHitByEntity(ped))
                    --.. pattern:format('roomKeyFromEntity', GetRoomKeyFromEntity(ped))
                    --.. pattern:format('pedInjured', IsPedInjured(ped))
                end
            end

            closestPeds = tempClosestPeds
            --closestPeds = table.clone(tempClosestPeds) -- Avoid concurrent access by creating a copy of the table.
        end
    end)

    -- PED OVERHEAD
    CreateThread(function()
        while enable do
            Wait(0)
            if next(closestPeds) then
                for ped, info in pairs(closestPeds) do
                    DrawText3D(GetEntityCoords(ped), info)
                end
            else
                Wait(1000)
            end
        end
    end)
end

RegisterCommand('pedinfo', function()
    enable = not enable
    if enable then
        start()
    end
end)