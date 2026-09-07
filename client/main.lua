-- ============================================================================
-- BUCU Notification & UI System — Client Main Engine
-- ============================================================================

local activeProgress = nil

-- ============================================================================
-- Public Exports
-- ============================================================================

-- Export: exports.bucu_notify:Notify(text, type, duration)
local function notify(text, nType, duration)
    if not text or text == "" then return end
    SendToast(tostring(text), nType or "info", duration)
end

exports('Notify', notify)

-- Export: exports.bucu_notify:ProgressBar(label, duration, options, onFinish, onCancel)
local function runProgressBar(label, duration, options, onFinish, onCancel)
    options = options or {}
    duration = tonumber(duration) or 3000
    local progressId = "prog_" .. tostring(GetGameTimer())
    local ped = PlayerPedId()
    local startHealth = GetEntityHealth(ped)
    local startCoords = GetEntityCoords(ped)
    local isCancelled = false

    activeProgress = progressId
    SendProgressStart(progressId, label, duration)

    -- Play animation if configured
    if options.anim and options.anim.dict and options.anim.anim then
        RequestAnimDict(options.anim.dict)
        local timeout = 1000
        while not HasAnimDictLoaded(options.anim.dict) and timeout > 0 do
            Wait(50)
            timeout = timeout - 50
        end
        if HasAnimDictLoaded(options.anim.dict) then
            TaskPlayAnim(ped, options.anim.dict, options.anim.anim, 2.0, 2.0, duration, options.anim.flag or 49, 0, false, false, false)
        end
    end

    -- Create Prop if configured
    local propObj = nil
    if options.prop and options.prop.model then
        local propHash = GetHashKey(options.prop.model)
        RequestModel(propHash)
        local timeout = 1000
        while not HasModelLoaded(propHash) and timeout > 0 do
            Wait(50)
            timeout = timeout - 50
        end
        if HasModelLoaded(propHash) then
            local pCoords = GetEntityCoords(ped)
            propObj = CreateObject(propHash, pCoords.x, pCoords.y, pCoords.z + 0.2, true, true, true)
            local bone = options.prop.bone or 57005
            AttachEntityToEntity(propObj, ped, GetPedBoneIndex(ped, bone), 0.12, 0.028, 0.001, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        end
    end

    -- Progress Watcher Thread
    local elapsed = 0
    while elapsed < duration do
        Wait(100)
        elapsed = elapsed + 100

        -- 1. Check Move Cancellation
        if options.cancelOnMove then
            local currentCoords = GetEntityCoords(ped)
            if #(currentCoords - startCoords) > 0.4 or IsPedMoving(ped) then
                isCancelled = true
                break
            end
        end

        -- 2. Check Damage Cancellation
        if options.cancelOnDamage then
            local curHealth = GetEntityHealth(ped)
            if curHealth < startHealth or IsEntityDead(ped) then
                isCancelled = true
                break
            end
        end

        -- 3. Check Manual Cancel (e.g. Backspace or X)
        if IsControlJustPressed(0, 73) then -- X key
            isCancelled = true
            break
        end
    end

    -- Clean up Prop & Anim
    if propObj and DoesEntityExist(propObj) then
        DeleteEntity(propObj)
    end
    if options.anim then
        ClearPedTasks(ped)
    end

    activeProgress = nil

    if isCancelled then
        SendProgressCancel(progressId)
        notify("Action cancelled.", "warning", 2500)
        if onCancel then onCancel() end
    else
        if onFinish then onFinish() end
    end
end

exports('ProgressBar', runProgressBar)

-- Export: exports.bucu_notify:DrawText3D(x, y, z, text)
exports('DrawText3D', function(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)

        local factor = string.len(text) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 10, 15, 25, 160)
    end
end)

-- ============================================================================
-- Universal Cross-Framework Compatibility Hooks
-- ============================================================================

-- BUCU Core Event
RegisterNetEvent('bucu:notify:show', function(text, nType, duration)
    notify(text, nType, duration)
end)

-- QBCore Emulation: QBCore:Notify
RegisterNetEvent('QBCore:Notify', function(text, nType, length)
    notify(text, nType, length)
end)

-- ESX Emulation: esx:showNotification
RegisterNetEvent('esx:showNotification', function(text, nType, length)
    notify(text, nType, length)
end)

-- ox_lib Emulation: ox_lib:notify
RegisterNetEvent('ox_lib:notify', function(data)
    if type(data) == "table" then
        local msg = data.description or data.title or "Notification"
        notify(msg, data.type or "info", data.duration)
    else
        notify(data, "info")
    end
end)
