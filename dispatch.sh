#!/bin/bash
# DreamNova Agent Dispatcher — Claude Code sends tasks to the right agent
# Usage: ./dispatch.sh [openclaw|zeroclaw|agentzero] "your task"
# Or:    ./dispatch.sh auto "your task"  — auto-routes based on task type

AGENT="${1:-auto}"
TASK="$2"

OC_TOKEN="b9705047256b1ea3acadf7a2d1cdd8acc49e6f458c66e539"
ZC_TOKEN="dreamnova-zc-2026"
AZ_TOKEN="ND-YcAFpPSJejhz-"

dispatch_openclaw() {
  openclaw agent -m "$1" 2>/dev/null \
    || curl -s -X POST "http://127.0.0.1:18789/api/v1/tasks" \
       -H "Authorization: Bearer $OC_TOKEN" \
       -H "Content-Type: application/json" \
       -d "{\"message\":\"$1\"}"
}

dispatch_zeroclaw() {
  zeroclaw agent -m "$1" 2>/dev/null
}

dispatch_agentzero() {
  curl -s -X POST "http://127.0.0.1:50001/api_message" \
    -H "Content-Type: application/json" \
    -H "X-API-KEY: $AZ_TOKEN" \
    -d "{\"message\":\"$1\",\"lifetime_hours\":4}"
}

auto_route() {
  local task_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')

  # Research / web search → Agent Zero
  if echo "$task_lower" | grep -qE "research|search|find|analyze|study|compare|trend|market"; then
    echo "→ Routing to Agent Zero (research)" >&2
    dispatch_agentzero "$1"
    return
  fi

  # Client / cron / schedule / notification → OpenClaw
  if echo "$task_lower" | grep -qE "client|cron|schedule|telegram|notify|alert|keren|baroukh|esther|ariel"; then
    echo "→ Routing to OpenClaw (client/ops)" >&2
    dispatch_openclaw "$1"
    return
  fi

  # Quick / simple / background → ZeroClaw
  if echo "$task_lower" | grep -qE "quick|simple|check|status|summary|brief|list"; then
    echo "→ Routing to ZeroClaw (quick task)" >&2
    dispatch_zeroclaw "$1"
    return
  fi

  # Default: ZeroClaw (fastest, local)
  echo "→ Routing to ZeroClaw (default)" >&2
  dispatch_zeroclaw "$1"
}

case "$AGENT" in
  openclaw|oc)  dispatch_openclaw "$TASK" ;;
  zeroclaw|zc)  dispatch_zeroclaw "$TASK" ;;
  agentzero|az) dispatch_agentzero "$TASK" ;;
  auto)         auto_route "$TASK" ;;
  *)            echo "Usage: $0 [openclaw|zeroclaw|agentzero|auto] 'task'" ;;
esac
