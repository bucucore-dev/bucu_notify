// ============================================================================
// BUCU Notification & Progress Bar System — NUI Engine
// ============================================================================

const NotifyApp = (() => {
    let audioCtx = null;
    let progressTimer = null;
    let progressInterval = null;

    const icons = {
        success: `<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>`,
        error: `<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>`,
        warning: `<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>`,
        info: `<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>`,
        police: `<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>`
    };

    // ------------------------------------------------------------------------
    // WebAudio Synthesizer for Haptic Feedback
    // ------------------------------------------------------------------------
    function getAudioContext() {
        if (!audioCtx) {
            audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        }
        return audioCtx;
    }

    function playTone(freq, type = 'sine', duration = 0.12, gainLvl = 0.04) {
        try {
            const ctx = getAudioContext();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();

            osc.type = type;
            osc.frequency.setValueAtTime(freq, ctx.currentTime);
            gain.gain.setValueAtTime(gainLvl, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration);

            osc.connect(gain);
            gain.connect(ctx.destination);

            osc.start();
            osc.stop(ctx.currentTime + duration);
        } catch (e) {}
    }

    function playNotificationSound(type) {
        if (type === 'success') {
            playTone(659.25, 'sine', 0.08, 0.04);
            setTimeout(() => playTone(880.00, 'sine', 0.14, 0.04), 70);
        } else if (type === 'error') {
            playTone(280, 'triangle', 0.14, 0.05);
            setTimeout(() => playTone(220, 'triangle', 0.16, 0.05), 80);
        } else if (type === 'warning') {
            playTone(493.88, 'sine', 0.10, 0.04);
            setTimeout(() => playTone(587.33, 'sine', 0.12, 0.04), 70);
        } else if (type === 'police') {
            playTone(523.25, 'sine', 0.08, 0.04);
            setTimeout(() => playTone(659.25, 'sine', 0.12, 0.04), 80);
        } else {
            playTone(587.33, 'sine', 0.10, 0.04);
        }
    }

    // ------------------------------------------------------------------------
    // Toast Notification Engine
    // ------------------------------------------------------------------------
    function createToast(text, type = 'info', duration = 4000, title = null) {
        const stack = document.getElementById('toast-container');
        const card = document.createElement('div');
        card.className = `toast-card toast-${type}`;

        const iconSvg = icons[type] || icons.info;
        const displayTitle = title || type.toUpperCase();

        card.innerHTML = `
            <div class="toast-content-row">
                <div class="toast-icon-wrap">${iconSvg}</div>
                <div class="toast-text-wrap">
                    <span class="toast-title">${displayTitle}</span>
                    <span class="toast-body">${text}</span>
                </div>
            </div>
            <div class="toast-timer-bar">
                <div class="toast-timer-fill"></div>
            </div>
        `;

        stack.appendChild(card);
        playNotificationSound(type);

        // Animate timer fill bar
        const fill = card.querySelector('.toast-timer-fill');
        fill.style.transition = `width ${duration}ms linear`;
        void fill.offsetWidth;
        fill.style.width = '0%';

        // Dismiss handler
        let isDismissed = false;
        const dismiss = () => {
            if (isDismissed) return;
            isDismissed = true;
            card.classList.add('removing');
            setTimeout(() => card.remove(), 240);
        };

        card.addEventListener('click', dismiss);
        setTimeout(dismiss, duration);
    }

    // ------------------------------------------------------------------------
    // Interactive Progress Bar Engine (Backward Compatibility Fallback)
    // ------------------------------------------------------------------------
    function startProgress(id, label, duration = 3000) {
        const container = document.getElementById('progress-container');
        const titleEl = document.getElementById('progress-label');
        const percentEl = document.getElementById('progress-percent');
        const fillEl = document.getElementById('progress-bar-fill');

        if (progressTimer) clearTimeout(progressTimer);
        if (progressInterval) clearInterval(progressInterval);

        titleEl.innerText = label || 'Processing...';
        percentEl.innerText = '0%';
        fillEl.style.transition = 'none';
        fillEl.style.width = '0%';

        container.classList.remove('hidden');
        void fillEl.offsetWidth;

        fillEl.style.transition = `width ${duration}ms cubic-bezier(0.4, 0, 0.2, 1)`;
        fillEl.style.width = '100%';

        const startTime = Date.now();
        progressInterval = setInterval(() => {
            const elapsed = Date.now() - startTime;
            const pct = Math.min(100, Math.floor((elapsed / duration) * 100));
            percentEl.innerText = `${pct}%`;
            if (pct >= 100) {
                clearInterval(progressInterval);
            }
        }, 50);

        progressTimer = setTimeout(() => {
            container.classList.add('hidden');
            clearInterval(progressInterval);
        }, duration);
    }

    function stopProgress() {
        const container = document.getElementById('progress-container');
        if (progressTimer) clearTimeout(progressTimer);
        if (progressInterval) clearInterval(progressInterval);
        container.classList.add('hidden');
    }

    // ------------------------------------------------------------------------
    // NUI Message Handlers
    // ------------------------------------------------------------------------
    window.addEventListener('message', (event) => {
        const data = event.data;
        if (!data || !data.action) return;

        if (data.action === 'notify') {
            createToast(data.text, data.type, data.duration, data.title);
        } else if (data.action === 'startProgress') {
            startProgress(data.id, data.label, data.duration);
        } else if (data.action === 'stopProgress') {
            stopProgress();
        }
    });

    return {
        createToast,
        startProgress,
        stopProgress
    };
})();
