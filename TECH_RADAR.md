# TECH_RADAR — DreamNova Agent Hub
> Auto-updated daily at 06:00 by daily-scan.sh
> Last manual update: 2026-02-24

## Current Stack
| Tool | Version | Role | Port |
|------|---------|------|------|
| Claude Code | claude-sonnet-4-6 | Center / CEO Brain | CLI |
| OpenClaw | 2026.2.22-2 | Ops / 8 agents / cron | :18789 |
| ZeroClaw | 0.1.6 | Lightweight / Telegram | :42617 |
| Agent Zero | latest | Deep Research / Web | :50001 |
| Ollama | latest | Local LLMs | :11434 |

## Free Models with Tool Use (OpenRouter) — Tested 2026-02-24
- meta-llama/llama-3.3-70b-instruct:free (rate-limited evenings)
- qwen/qwen3-coder:free (coding focus, 480B)
- mistralai/mistral-small-3.1-24b-instruct:free
- nvidia/nemotron-nano-9b-v2:free
- openai/gpt-oss-20b:free

## Local Models (Ollama)
- qwen3-coder:latest (18GB — primary for ZeroClaw)

## On Watch (integrate when stable)
- [ ] Gemini 3.1 Pro via OpenRouter (not yet available on free tier)
- [ ] Claude 3.5 Haiku via OpenRouter
- [ ] Mistral Devstral (agent-optimized)
- [ ] OpenClaw v2027 (watch for major updates)

## Rejected
- deepseek/deepseek-r1-0528:free — no tool use support
- google/gemini-2.0-flash-exp:free — not found on OpenRouter
