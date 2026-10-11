# ~/.config/llm/env.sh — non-secret. Sourced by shells and systemd wrappers.
# Sets ANTHROPIC_* to the local headroom proxy; upstream chosen via LLM_PROVIDER.

_llm_dir="${XDG_CONFIG_HOME:-$HOME/.config}/llm"
_llm_providers="$_llm_dir/providers.env"

if [ -r "$_llm_providers" ]; then
  # shellcheck disable=SC1090
  . "$_llm_providers"
fi

_llm_apply() {
  _llm_provider="${LLM_PROVIDER:-xiaomi}"
  case "$_llm_provider" in
    xiaomi)    _llm_prefix=XIAOMI ;;
    dashscope) _llm_prefix=DASHSCOPE ;;
    openai)    _llm_prefix=OPENAI ;;
    gemini)    _llm_prefix=GEMINI ;;
    deepseek)  _llm_prefix=DEEPSEEK ;;
    *)
      echo "llm: unknown LLM_PROVIDER='$_llm_provider'" >&2
      return 1
      ;;
  esac

  # Indirect expansion (bash/zsh)
  eval "LLM_UPSTREAM_URL=\${${_llm_prefix}_BASE_URL:-}"
  eval "LLM_API_KEY=\${${_llm_prefix}_API_KEY:-}"
  eval "LLM_MODEL=\${${_llm_prefix}_MODEL:-}"

  if [ -z "$LLM_UPSTREAM_URL" ] || [ -z "$LLM_API_KEY" ]; then
    echo "llm: provider '$_llm_provider' missing ${_llm_prefix}_BASE_URL or ${_llm_prefix}_API_KEY" >&2
  fi

  # Always point Claude at the local headroom proxy
  export ANTHROPIC_BASE_URL="http://127.0.0.1:8787"
  export ANTHROPIC_API_KEY="$LLM_API_KEY"
  export ANTHROPIC_MODEL="$LLM_MODEL"
  export LLM_PROVIDER="$_llm_provider"
  export LLM_UPSTREAM_URL
  # Belt-and-braces for the headroom CLI (its --anthropic-api-url flag is primary)
  export ANTHROPIC_TARGET_API_URL="$LLM_UPSTREAM_URL"
}

_llm_apply

llm-use() {
  _llm_arg="${1:-}"
  if [ -z "$_llm_arg" ]; then
    echo "usage: llm-use <xiaomi|dashscope|openai|gemini|deepseek>" >&2
    return 2
  fi
  _llm_file="${XDG_CONFIG_HOME:-$HOME/.config}/llm/providers.env"
  if [ ! -w "$_llm_file" ]; then
    echo "llm-use: cannot write $_llm_file" >&2
    return 1
  fi
  _llm_tmp=$(mktemp) || return 1
  sed "s/^LLM_PROVIDER=.*/LLM_PROVIDER=$_llm_arg/" "$_llm_file" >"$_llm_tmp" && cat "$_llm_tmp" >"$_llm_file"
  rm -f "$_llm_tmp"
  # shellcheck disable=SC1090
  . "$_llm_file"
  _llm_apply
  systemctl --user restart headroom-proxy.service 2>/dev/null || true
  echo "llm: provider=$LLM_PROVIDER upstream=$LLM_UPSTREAM_URL model=$ANTHROPIC_MODEL base=$ANTHROPIC_BASE_URL"
}
