# DreamNova 4-Point Agent Architecture

**Claude Code** (center) → **OpenClaw** + **ZeroClaw** + **Agent Zero**

## Quick Start
```bash
chmod +x *.sh

# Auto-dispatch a task to the right agent
./dispatch.sh auto "research new AI agent frameworks"

# Direct dispatch
./dispatch.sh zeroclaw "quick status check"
./dispatch.sh openclaw "notify Keren client via Telegram"
./dispatch.sh agentzero "deep research: best free AI models 2026"

# Install auto-healing (every 5 min)
(crontab -l 2>/dev/null; echo "*/5 * * * * $HOME/Desktop/dreamnova-agent-hub/auto-heal.sh") | crontab -

# Install daily scanner (06:00)
(crontab -l 2>/dev/null; echo "0 6 * * * $HOME/Desktop/dreamnova-agent-hub/daily-scan.sh") | crontab -
```

## Files
- `index.html` — GitHub Pages documentation site
- `dispatch.sh` — Smart task router (auto-selects agent)
- `auto-heal.sh` — Health monitor + auto-restart
- `daily-scan.sh` — Daily tech scanner + Telegram report
- `TECH_RADAR.md` — Auto-updated model/tool inventory

## Architecture
```
           Claude Code (CENTER)
                   │
        ┌──────────┼──────────┐
        │          │          │
    OpenClaw   ZeroClaw   AgentZero
    :18789     :42617     :50001
    Ops/Cron  Telegram   Research
```

## Communication
- Claude Code → Any agent: `./dispatch.sh auto "task"`
- Any agent → Claude Code: write to `~/Desktop/AGENTS_COMMON/AGENT_BRIDGE.md`
- Memory: `SESSION_LIVE.md` + `SESSIONS_INDEX.md` + per-agent memory dirs
