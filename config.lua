-- ============================================================================
-- BUCU Notification & UI System — Configuration
-- ============================================================================

NotifyConfig = {}

NotifyConfig.Language = 'en'
NotifyConfig.DefaultDuration = 4000      -- Default 4 seconds per toast
NotifyConfig.MaxStackedToasts = 5        -- Maximum toasts visible simultaneously
NotifyConfig.Position = 'top-right'      -- 'top-right', 'top-center', 'bottom-right'
NotifyConfig.EnableSound = true          -- WebAudio haptic chimes

NotifyConfig.Types = {
    ['success'] = {
        title = "SUCCESS",
        color = "#10b981",
        soundFreq = 880
    },
    ['error'] = {
        title = "ERROR",
        color = "#ef4444",
        soundFreq = 220
    },
    ['warning'] = {
        title = "WARNING",
        color = "#f59e0b",
        soundFreq = 440
    },
    ['info'] = {
        title = "INFO",
        color = "#00f0ff",
        soundFreq = 660
    }
}
