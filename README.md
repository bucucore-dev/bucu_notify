# bucu_notify

> Modern Glassmorphism Toast Notifications & Interactive Progress Bar with universal hooks for FiveM.

---

## 🌟 Overview

`bucu_notify` provides an ultra-responsive, visually stunning notification and progress bar system. Built with dark glassmorphism styling, vibrant accents, and smooth micro-animations.

## 📦 Features
- **4 Toast Variants**: `success`, `error`, `warning`, `info`.
- **Interactive Progress Bar**: Circular / bar loading with `cancelOnMove` and animation synchronization.
- **Floating 3D Text**: Low-overhead interaction prompt rendering.
- **Universal Shims**: Automatically catches legacy calls to `QBCore:Notify`, `ESX.ShowNotification`, and `ox_lib:notify`.

## 📥 Exports & Usage

```lua
-- Client & Server
exports.bucu_notify:Notify("Transaction successful!", "success", 4000)

-- Client Progress Bar
exports.bucu_notify:ProgressBar("Lockpicking...", 5000, {
    cancelOnMove = true,
    anim = { dict = "veh@break_in@0h@p_m_one@", anim = "low_force_entry_ds" }
}, function()
    -- On Finish
end, function()
    -- On Cancel
end)
```

## 📜 License
Part of the BUCU Framework. Licensed under the MIT License.
