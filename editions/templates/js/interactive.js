// interactive.js – Zero-friction Greek reader (hover peek + click lock)
document.addEventListener('DOMContentLoaded', () => {
    const tokens = document.querySelectorAll('.text_token');
    const morphSource = document.getElementById('morphdata');
    const infopanel = document.getElementById('infopanel');
    let lockedToken = null;

    function showMorph(token) {
        const urn = token.dataset.ctsurn;
        if (!urn) return;

        const sourceDiv = morphSource.querySelector(`.morph4token[data-tokenurn="${urn}"]`);
        if (!sourceDiv) {
            infopanel.innerHTML = `<p><em>No morphological data for this token.</em></p>`;
            return;
        }

        const clone = sourceDiv.cloneNode(true);
        clone.style.display = 'block';

        const word = token.textContent.trim();
        const header = `
            <div class="morph-header" style="margin-bottom:1rem;border-bottom:1px solid #ddd;padding-bottom:0.5rem;">
                <strong style="font-size:1.2rem">${word}</strong>
                <span style="font-size:0.8rem;color:#777;float:right">${urn}</span>
            </div>`;

        infopanel.innerHTML = header + clone.innerHTML;

        if (lockedToken) {
            const closeBtn = document.createElement('button');
            closeBtn.textContent = '✕ Unlock';
            closeBtn.className = 'close-btn';
            closeBtn.style.cssText = 'float:right;font-size:0.8rem;padding:2px 8px;background:#eee;border:none;border-radius:4px;cursor:pointer;';
            infopanel.prepend(closeBtn);
        }
    }

    function clearPanel() {
        if (lockedToken) return;
        infopanel.innerHTML = '';
    }

    tokens.forEach(token => {
        token.addEventListener('mouseenter', () => {
            if (!lockedToken || lockedToken === token) {
                showMorph(token);
            }
        });

        token.addEventListener('mouseleave', () => {
            clearPanel();
        });

        token.addEventListener('click', e => {
            e.stopImmediatePropagation();

            if (lockedToken === token) {
                lockedToken.classList.remove('locked');
                lockedToken = null;
                clearPanel();
            } else {
                if (lockedToken) lockedToken.classList.remove('locked');
                lockedToken = token;
                token.classList.add('locked');
                showMorph(token);
            }
        });
    });

    infopanel.addEventListener('click', e => {
        if (e.target.classList.contains('close-btn')) {
            if (lockedToken) {
                lockedToken.classList.remove('locked');
                lockedToken = null;
            }
            clearPanel();
        }
    });

    console.log('%c✅ Greek reader interactivity ready (hover/click + responsive)', 'color:#8b0000;font-weight:bold');
});