// interactive.js – Zero-friction Greek reader + Editor Mode (durable picks)

function copySelf(element) {
  navigator.clipboard.writeText(element.innerText)
    .catch(err => console.error("Error:", err));
}

document.addEventListener('DOMContentLoaded', () => {
    const tokens = document.querySelectorAll('.text_token');
    const morphSource = document.getElementById('morphdata');
    const infopanel = document.getElementById('infopanel');
    let lockedToken = null;
    let editorChoices = {}; // tokenUrn → "uc_form\tbc_form\tuc_lemma\tbc_lemma\tlsj\tpos"
    let editorModeEnabled = false;
    const editorToggle = document.getElementById('editor-mode-toggle');

    const editorControls = document.getElementById('editor-controls');
    const downloadBtn = document.getElementById('download-editor-tsv');
    const clearBtn = document.getElementById('clear-editor-choices');

    function renderEditorControls() {
        editorControls.style.display = Object.keys(editorChoices).length > 0 ? 'block' : 'none';
    }

    function getMorphKey(parsing) {
        const uc = parsing.getAttribute('data-uc-form') || '';
        const bc = parsing.getAttribute('data-bc-form') || '';
        const ucL = parsing.getAttribute('data-uc-lemma') || '';
        const bcL = parsing.getAttribute('data-bc-lemma') || '';
        const lsj = parsing.getAttribute('data-lsj') || '';
        const pos = parsing.getAttribute('data-pos') || '';
        return [uc, bc, ucL, bcL, lsj, pos].join('\t');
    }

    function showMorph(token) {
        const tokenUrn = token.dataset.ctsurn;
        if (!tokenUrn) return;
        const word = token.textContent.trim();
        const sourceDiv = morphSource.querySelector(`.morph4token[data-tokenurn="${tokenUrn}"]`);
        if (!sourceDiv) {
            infopanel.innerHTML = `<div class="tokenWord">${word}</div><div class="tokenurn sansfont" onclick="copySelf(this)" >${tokenUrn}</div><p style="font-size: 1rem;"><em>No morphological data for this token.</em></p>`;
            return;
        }

        infopanel.innerHTML = '';

        
        const header = document.createElement('div');
        header.className = 'morph-header';
        header.style.cssText = 'margin-bottom:1rem;border-bottom:1px solid #ddd;padding-bottom:0.5rem;';
        header.innerHTML = `<div class="tokenWord">${word}</div><div class="tokenurn sansfont" onclick="copySelf(this)" >${tokenUrn}</div>`;
        infopanel.appendChild(header);

        const clone = sourceDiv.cloneNode(true);
        clone.style.display = 'block';

        if (editorModeEnabled) {
            clone.querySelectorAll('.parse_and_lex').forEach(parsing => {
                const key = getMorphKey(parsing);
                if (!key) return;

                const btn = document.createElement('button');
                btn.className = 'preferred-btn';
                btn.textContent = 'Mark as preferred';
                btn.title = 'Click to record this parsing for this context';

                btn.addEventListener('click', e => {
                    e.stopImmediatePropagation();
                    if (editorChoices[tokenUrn] === key) {
                        delete editorChoices[tokenUrn];
                        parsing.classList.remove('preferred');
                        btn.textContent = 'Mark as preferred';
                    } else {
                        editorChoices[tokenUrn] = key;
                        clone.querySelectorAll('.parse_and_lex').forEach(p => p.classList.remove('preferred'));
                        parsing.classList.add('preferred');
                        btn.textContent = '✓ Preferred here';
                    }
                    renderEditorControls();
                });

                // Restore previous choice
                if (editorChoices[tokenUrn] === key) {
                    parsing.classList.add('preferred');
                    btn.textContent = '✓ Preferred here';
                }

                parsing.style.position = 'relative';
                parsing.appendChild(btn);
            });
        }

        infopanel.appendChild(clone);

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

    // ... (the rest of the token event listeners, clearPanel, click handling, editor toggle, etc. are unchanged)

    tokens.forEach(token => {
        token.addEventListener('mouseenter', () => {
            if (lockedToken !== token) token.classList.add('hovered');
            if (!lockedToken || lockedToken === token) showMorph(token);
        });

        token.addEventListener('mouseleave', () => {
            token.classList.remove('hovered');
            if (lockedToken !== token) token.classList.remove('hovered');
            if (!lockedToken) clearPanel();
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
            if (lockedToken) lockedToken.classList.remove('locked');
            lockedToken = null;
            clearPanel();
        }
    });

// Editor download – DURABLE 7-column format (CTS-URN + fields 3-8)
downloadBtn.addEventListener('click', () => {
    if (Object.keys(editorChoices).length === 0) {
        alert("No editor choices to download yet.");
        return;
    }

    const tsv = Object.keys(editorChoices)
        .sort()
        .map(k => `${k}\t${editorChoices[k]}`)   // ← this is now the new durable format
        .join('\n');

    const date = new Date().toISOString().split("T")[0];
    const longerdate = date + "-" + new Date().toISOString().split("T")[1].split(":")[0]+new Date().toISOString().split("T")[1].split(":")[1];


    const blob = new Blob([tsv + "\n"], { type: 'text/tab-separated-values' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `editors_index_${window.location.pathname.split('/').pop().replace('.html','')}_${longerdate}.tsv`;
    a.click();
    URL.revokeObjectURL(url);

    console.log('%c✅ Downloaded new durable editorial picks (7 columns)', 'color:#006400;font-weight:bold');
});

    clearBtn.addEventListener('click', () => {
        if (confirm('Clear ALL preferred parsings for this page?')) {
            editorChoices = {};
            renderEditorControls();
            if (lockedToken) showMorph(lockedToken);
        }
    });

    if (editorToggle) {
        editorToggle.addEventListener('change', (e) => {
            editorModeEnabled = e.target.checked;
            if (lockedToken) showMorph(lockedToken);
        });
    }

    renderEditorControls();

    console.log('%c✅ Greek reader + Editor Mode ready (durable picks via fields 3-8)', 'color:#8b0000;font-weight:bold');
});