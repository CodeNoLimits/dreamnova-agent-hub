#!/bin/bash
# DreamNova Auto-Heal — runs every 5min via cron
# Install: crontab -e → add: */5 * * * * ~/Desktop/dreamnova-agent-hub/auto-heal.sh >> ~/.dreamnova/heal.log 2>&1

BRIDGE="$HOME/Desktop/AGENTS_COMMON/AGENT_BRIDGE.md"
BOT_TOKEN="8602042308:AAETcbkD6GGPPKAO5VSBE2wMybPVPnqltV8"
DAVID_ID="7269582214"
LOG_FILE="$HOME/.dreamnova/heal.log"
mkdir -p "$HOME/.dreamnova"

notify() {
  curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${DAVID_ID}" \
    --data-urlencode "text=$1" > /dev/null 2>&1
}

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

check_and_heal() {
  local name="$1"
  local url="$2"
  local restart_cmd="$3"

  if curl -sf --max-time 5 "$url" > /dev/null 2>&1; then
    return 0  # healthy
  fi

  log "⚠️  $name is DOWN — attempting restart"
  echo "" >> "$BRIDGE" 2>/dev/null
  echo "### $(date '+%H:%M') — AUTO-HEAL: $name DOWN" >> "$BRIDGE" 2>/dev/null

  eval "$restart_cmd" > /dev/null 2>&1
  sleep 5

  if curl -sf --max-time 5 "$url" > /dev/null 2>&1; then
    log "✅ $name RESTORED"
    notify "✅ AUTO-HEAL: $name restored"
    echo "- Restored at $(date '+%H:%M')" >> "$BRIDGE" 2>/dev/null
  else
    log "❌ $name FAILED to restart — needs manual check"
    notify "❌ $name failed to auto-restart — check needed!"
    echo "- FAILED to restore at $(date '+%H:%M')" >> "$BRIDGE" 2>/dev/null
  fi
}

# Check all 4 agents
check_and_heal "ZeroClaw"  "http://127.0.0.1:42617/health"  "zeroclaw service restart"
check_and_heal "OpenClaw"  "http://127.0.0.1:18789/health"  "openclaw gateway restart 2>/dev/null || launchctl kickstart -k gui/$(id -u)/ai.openclaw.node"
check_and_heal "AgentZero" "http://127.0.0.1:50001/health"  "docker restart agent-zero"
check_and_heal "Ollama"    "http://127.0.0.1:11434/api/tags" "open -a Ollama"

# Daily summary at 06:00
HOUR=$(date '+%H')
MIN=$(date '+%M')
if [ "$HOUR" = "06" ] && [ "$MIN" -lt "5" ]; then
  SUMMARY="🌅 06h00 DreamNova Status:\n"
  for name_url in "ZeroClaw:http://127.0.0.1:42617/health" "OpenClaw:http://127.0.0.1:18789/health" "AgentZero:http://127.0.0.1:50001/health"; do
    name="${name_url%%:*}"
    url="${name_url#*:}"
    if curl -sf --max-time 3 "$url" > /dev/null 2>&1; then
      SUMMARY+="✅ $name\n"
    else
      SUMMARY+="❌ $name\n"
    fi
  done
  notify "$SUMMARY"
fi
