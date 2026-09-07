-- ============================================================================
-- BUCU Notification System — Client NUI Controller
-- ============================================================================

local function getLocale(key)
    local lang = NotifyConfig.Language or 'en'
    local dict = NotifyLocales[lang] or NotifyLocales['en']
    return dict[key] or key
end

function SendToast(text, nType, duration)
    nType = nType or 'info'
    duration = tonumber(duration) or NotifyConfig.DefaultDuration or 4000

    local titleKey = 'title_' .. nType
    local title = getLocale(titleKey) or string.upper(nType)

    SendNUIMessage({
        action = 'showToast',
        text = text,
        type = nType,
        duration = duration,
        title = title
    })
end

function SendProgressStart(progressId, label, duration)
    SendNUIMessage({
        action = 'startProgress',
        id = progressId,
        label = label,
        duration = duration
    })
end

function SendProgressCancel(progressId)
    SendNUIMessage({
        action = 'cancelProgress',
        id = progressId
    })
end
