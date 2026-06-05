// interactive.js – Zero-friction Greek reader + Editor Mode (fixed)
document.addEventListener('DOMContentLoaded', () => {
    const tokens = document.querySelectorAll('.text_token');
    const morphSource = document.getElementById('morphdata');
    const infopanel = document.getElementById('infopanel');
    let lockedToken = null;
    let editorChoices = {}; // tokenUrn → morphUrn

    const editorControls = document.getElementById('editor-controls');
    const downloadBtn = document.getElementById('download-editor-tsv');
    const clearBtn = document.getElementById('clear-editor-choices');

    function renderEditorControls() {
        editorControls.style.display = Object.keys(editorChoices).length > 0 ? 'block' : 'none';
    }

    function showMorph(token) {
        const tokenUrn = token.dataset.ctsurn;
        if (!tokenUrn) return;

        const sourceDiv = morphSource.querySelector(`.morph4token[data-tokenurn="${tokenUrn}"]`);
        if (!sourceDiv) {
            infopanel.innerHTML = `<p><em>No morphological data for this token.</em></p>`;
            return;
        }

        // Clear panel and build fresh DOM (preserves events)
        infopanel.innerHTML = '';

        const word = token.textContent.trim();
        const header = document.createElement('div');
        header.className = 'morph-header';
        header.style.cssText = 'margin-bottom:1rem;border-bottom:1px solid #ddd;padding-bottom:0.5rem;';
        header.innerHTML = `
            <strong style="font-size:1.2rem">${word}</strong>
            <span style="font-size:0.8rem;color:#777;float:right">${tokenUrn}</span>`;
        infopanel.appendChild(header);

        const clone = sourceDiv.cloneNode(true);
        clone.style.display = 'block';

        // Add Editor buttons + highlighting
        clone.querySelectorAll('.parse_and_lex').forEach(parsing => {
            const morphUrn = parsing.getAttribute('data-morphurn');
            if (!morphUrn) return;

            const btn = document.createElement('button');
            btn.className = 'preferred-btn';
            btn.textContent = 'Mark as preferred';
            btn.title = 'Click to record this parsing for this context';

            btn.addEventListener('click', e => {
                e.stopImmediatePropagation();
                if (editorChoices[tokenUrn] === morphUrn) {
                    delete editorChoices[tokenUrn];
                    parsing.classList.remove('preferred');
                    btn.textContent = 'Mark as preferred';
                } else {
                    editorChoices[tokenUrn] = morphUrn;
                    clone.querySelectorAll('.parse_and_lex').forEach(p => p.classList.remove('preferred'));
                    parsing.classList.add('preferred');
                    btn.textContent = '✓ Preferred here';
                }
                renderEditorControls();
            });

            // Restore previous choice
            if (editorChoices[tokenUrn] === morphUrn) {
                parsing.classList.add('preferred');
                btn.textContent = '✓ Preferred here';
            }

            parsing.style.position = 'relative';
            parsing.appendChild(btn);
        });

        infopanel.appendChild(clone);

        // Close button when locked
        if (lockedToken) {
            const closeBtn = document.createElement('button');
            closeBtn.textContent = '✕ Unlock';
            closeBtn.className = 'close-btn';
            closeBtn.style.cssText = 'float:right;font-size:0.8rem;padding:2px 8px;background:#eee;border:none;border-radius:4px;cursor:pointer;margin-bottom:1rem;';
            infopanel.prepend(closeBtn);
        }
    }

    function clearPanel() {
        if (lockedToken) return;
        infopanel.innerHTML = '';
    }

    tokens.forEach(token => {
        token.addEventListener('mouseenter', () => {
            if (!lockedToken || lockedToken === token) showMorph(token);
        });

        token.addEventListener('mouseleave', clearPanel);

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

    // Editor buttons
    downloadBtn.addEventListener('click', () => {
        if (Object.keys(editorChoices).length === 0) return;
        let tsv = Object.keys(editorChoices)
            .sort()
            .map(k => `${k}\t${editorChoices[k]}`)
            .join('\n');
        const blob = new Blob([tsv], { type: 'text/tab-separated-values' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `editors_index_${window.location.pathname.split('/').pop().replace('.html','')}.tsv`;
        a.click();
        URL.revokeObjectURL(url);
    });

    clearBtn.addEventListener('click', () => {
        if (confirm('Clear ALL preferred parsings for this page?')) {
            editorChoices = {};
            renderEditorControls();
            if (lockedToken) showMorph(lockedToken);
        }
    });

    renderEditorControls();

    console.log('%c✅ Greek reader + Editor Mode ready (hover/click + preferred parsings + TSV export)', 'color:#8b0000;font-weight:bold');
});