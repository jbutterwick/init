#!/usr/bin/env bash
set -euo pipefail
# Launch the Claude Code Telegram bot with the shared LLM env (proxy + provider key),
# after the headroom proxy is ready.
_llm_dir="${XDG_CONFIG_HOME:-$HOME/.config}/llm"
# shellcheck disable=SC1090
. "$_llm_dir/env.sh"

# Ensure the claude CLI is resolvable for the bot's agent SDK
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export CLAUDE_CLI_PATH="${CLAUDE_CLI_PATH:-$HOME/.local/bin/claude}"

BOT_DIR="${BOT_DIR:-$HOME/projects/claude-code-telegram}"

# Glob the poetry venv so a venv rebuild doesn't break the unit
if [ -z "${BOT_BIN:-}" ]; then
  # shellcheck disable=SC2012
  BOT_BIN=$(ls -d "$HOME"/.cache/pypoetry/virtualenvs/claude-code-telegram-*/bin/claude-telegram-bot 2>/dev/null | head -1 || true)
fi
if [ -z "${BOT_BIN:-}" ] || [ ! -x "$BOT_BIN" ]; then
  echo "run-telegram-bot: claude-telegram-bot binary not found" >&2
  exit 1
fi

# Wait for headroom proxy readiness (avoids a start race with headroom-proxy.service)
for _ in $(seq 1 30); do
  if curl -fsS --max-time 1 "http://127.0.0.1:8787/health" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

cd "$BOT_DIR"
exec "$BOT_BIN"
