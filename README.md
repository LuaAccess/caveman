# caveman — personal fork

Ultra-compressed AI communication mode for Claude Code. Cuts ~65-75% of output tokens while keeping full technical accuracy.

> **Based on:** [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) (MIT License)
> **This fork:** Stripped to Claude Code only. No network calls. No npx. No telemetry. History file size-capped.

---

## What it does

Say `caveman mode` or `/caveman` → Claude Code responds like this:

> ❌ "Sure! I'd be happy to help. The issue you're experiencing is likely caused by..."
> ✅ "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"

Same technical accuracy. ~70% fewer tokens. Lower cost per session.

---

## Modes

| Command | Effect |
|---|---|
| `/caveman` | Full mode (default) |
| `/caveman lite` | Tighter prose, keeps articles |
| `/caveman ultra` | Maximum compression |
| `/caveman-stats` | Token usage + estimated savings this session |
| `stop caveman` | Back to normal |

---

## Install

**Requirements:** Claude Code CLI, Node ≥ 18

```bash
git clone https://github.com/YOUR_USERNAME/caveman
cd caveman
bash install.sh
```

Preview before installing:
```bash
bash install.sh --dry-run
```

Uninstall:
```bash
bash install.sh --uninstall
```

---

## Security notes (what was changed from upstream)

| Issue | Fix applied |
|---|---|
| `.caveman-history.jsonl` had no size cap | Capped at 5MB in `caveman-config.js` |
| `readHistory()` had no size cap | Added matching cap |
| Installer used `npx` / GitHub as install source | Removed — install is local only |
| 30+ agent installers included | Removed — Claude Code only |

All other security properties of the original are preserved:
- `O_NOFOLLOW` on all flag file reads/writes
- Atomic temp+rename writes
- Symlink detection on flag files and parent directories
- 64-byte hard cap on flag file reads
- VALID_MODES whitelist — untrusted bytes never injected into model context
- No outbound network calls from hooks

---

## Files

```
caveman/
├── install.sh                    ← run this
├── LICENSE                       ← MIT (keep this)
├── README.md
├── .claude-plugin/
│   └── plugin.json               ← Claude Code plugin manifest
├── skills/
│   └── caveman/
│       └── SKILL.md              ← caveman behavior (edit this to customize)
└── src/
    └── hooks/
        ├── caveman-config.js     ← shared config + safe file I/O
        ├── caveman-activate.js   ← SessionStart hook
        ├── caveman-mode-tracker.js  ← UserPromptSubmit hook
        ├── caveman-stats.js      ← /caveman-stats command
        ├── caveman-statusline.sh ← [CAVEMAN] badge in statusline
        └── package.json          ← pins hooks dir to CommonJS
```

---

## Customize

Edit `skills/caveman/SKILL.md` to change behavior. That file is the single source of truth for what caveman does. Re-run `bash install.sh` after changes to update the installed copy.

---

## License

MIT — see LICENSE file. Original work by Julius Brussee.
