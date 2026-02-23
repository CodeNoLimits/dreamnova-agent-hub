#!/bin/bash
# DreamNova Daily Tech Scanner — 06:00 every day
# Install: crontab -e → add: 0 6 * * * ~/Desktop/dreamnova-agent-hub/daily-scan.sh

DATE=$(date '+%Y-%m-%d')
REPORT="$HOME/Desktop/DREAMNOVA_MISSION_CONTROL/reports/DESKTOP_SCAN_${DATE}.md"
TECH_RADAR="$HOME/Desktop/dreamnova-agent-hub/TECH_RADAR.md"
BOT_TOKEN="8602042308:AAETcbkD6GGPPKAO5VSBE2wMybPVPnqltV8"
DAVID_ID="7269582214"

notify() {
  curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${DAVID_ID}" \
    --data-urlencode "text=$1" > /dev/null 2>&1
}

echo "# Daily Scan — $DATE" > "$REPORT"
echo "" >> "$REPORT"

# 1. Agent health
echo "## Agent Status" >> "$REPORT"
HEALTH_MSG="📊 Daily Scan $DATE:\n"
for item in "ZeroClaw:42617" "OpenClaw:18789" "AgentZero:50001"; do
  name="${item%%:*}"; port="${item##*:}"
  if curl -sf --max-time 3 "http://127.0.0.1:${port}/health" > /dev/null 2>&1; then
    echo "- ✅ $name (:$port)" >> "$REPORT"
    HEALTH_MSG+="✅ $name\n"
  else
    echo "- ❌ $name (:$port) — DOWN" >> "$REPORT"
    HEALTH_MSG+="❌ $name\n"
  fi
done

# 2. ZeroClaw update check
echo "" >> "$REPORT"
echo "## Tool Updates" >> "$REPORT"
ZC_UPDATE=$(brew outdated zeroclaw 2>/dev/null)
if [ -n "$ZC_UPDATE" ]; then
  echo "- 🦀 ZeroClaw UPDATE AVAILABLE: $ZC_UPDATE" >> "$REPORT"
  HEALTH_MSG+="🦀 ZeroClaw update available!\n"
fi

OC_UPDATE=$(npm outdated -g openclaw 2>/dev/null | grep openclaw | awk '{print $1,$2,"→",$4}')
if [ -n "$OC_UPDATE" ]; then
  echo "- 🦞 OpenClaw UPDATE: $OC_UPDATE" >> "$REPORT"
  HEALTH_MSG+="🦞 OpenClaw update available!\n"
fi

# 3. New free OpenRouter models with tool support
echo "" >> "$REPORT"
echo "## New Free OpenRouter Models (tool-use)" >> "$REPORT"
NEW_MODELS=$(curl -s --max-time 10 "https://openrouter.ai/api/v1/models" | python3 -c "
import sys,json,datetime
try:
  models = json.load(sys.stdin).get('data',[])
  free_tools = [m['id'] for m in models
                if ':free' in m.get('id','')
                and 'tools' in (m.get('supported_parameters') or [])]
  print('\n'.join(free_tools[:8]))
except: pass
" 2>/dev/null)
echo "$NEW_MODELS" >> "$REPORT"

# 4. Ollama model updates
echo "" >> "$REPORT"
echo "## Ollama Library" >> "$REPORT"
OLLAMA_MODELS=$(ollama list 2>/dev/null | awk 'NR>1{print "- "$1}')
echo "$OLLAMA_MODELS" >> "$REPORT"

# 5. GitHub trending AI agents
echo "" >> "$REPORT"
echo "## GitHub Trending (AI Agents)" >> "$REPORT"
GH_TRENDING=$(curl -s --max-time 10 \
  "https://api.github.com/search/repositories?q=ai+agent+created:>$(date -v-1d '+%Y-%m-%d')&sort=stars&per_page=5" \
  | python3 -c "
import sys,json
try:
  data=json.load(sys.stdin)
  for r in data.get('items',[])[:5]:
    print(f'- [{r[\"full_name\"]}]({r[\"html_url\"]}) ⭐{r[\"stargazers_count\"]}')
except: pass
" 2>/dev/null)
echo "$GH_TRENDING" >> "$REPORT"

# 6. Update TECH_RADAR.md
{
  echo "# TECH_RADAR — Updated $DATE"
  echo ""
  echo "## Free Models with Tool Use (OpenRouter)"
  echo "$NEW_MODELS"
  echo ""
  echo "## Trending AI Agent Repos"
  echo "$GH_TRENDING"
  echo ""
  echo "## Local Models (Ollama)"
  echo "$OLLAMA_MODELS"
} > "$TECH_RADAR"

# Send Telegram summary
HEALTH_MSG+="📋 Full report: DESKTOP_SCAN_${DATE}.md"
notify "$HEALTH_MSG"

echo "✅ Daily scan complete: $REPORT"
