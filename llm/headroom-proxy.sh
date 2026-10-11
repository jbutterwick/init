#!/usr/bin/env bash
set -euo pipefail
# Launch the headroom compression proxy pointed at the active upstream provider.
_llm_dir="${XDG_CONFIG_HOME:-$HOME/.config}/llm"
# shellcheck disable=SC1090
. "$_llm_dir/env.sh"

HEADROOM_BIN="${HEADROOM_BIN:-$HOME/.local/bin/headroom}"

# Privacy defaults (no telemetry beacon / update pings)
export HEADROOM_BEACON="${HEADROOM_BEACON:-off}"
export DO_NOT_TRACK="${DO_NOT_TRACK:-1}"
export HEADROOM_UPDATE_CHECK="${HEADROOM_UPDATE_CHECK:-off}"

exec "$HEADROOM_BIN" proxy \
  --host 127.0.0.1 \
  --port 8787 \
  --anthropic-api-url "${LLM_UPSTREAM_URL:?LLM_UPSTREAM_URL unset}"
