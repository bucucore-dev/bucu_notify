-- ============================================================================
-- BUCU Notification System — Server Main Handler
-- ============================================================================

local function sendNotification(targetSrc, text, nType, duration)
    if not text or text == "" then return false end
    nType = nType or "info"
    duration = tonumber(duration) or NotifyConfig.DefaultDuration or 4000

    if targetSrc == -1 then
        TriggerClientEvent('bucu:notify:show', -1, text, nType, duration)
    else
        targetSrc = tonumber(targetSrc) or 0
        if targetSrc > 0 then
            TriggerClientEvent('bucu:notify:show', targetSrc, text, nType, duration)
        end
    end
    return true
end

-- Server Export: exports.bucu_notify:Notify(source, text, type, duration)
exports('Notify', sendNotification)

-- Network Event
RegisterNetEvent('bucu:notify:send', function(targetSrc, text, nType, duration)
    sendNotification(targetSrc, text, nType, duration)
end)
