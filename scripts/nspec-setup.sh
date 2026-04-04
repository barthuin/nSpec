#!/usr/bin/env bash
# nSpec — Model mode manager
# Switches between model modes by updating only the nspec/nspec-fast aliases.
# API key exports are written once and never removed.

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
DIM='\033[2m'
RESET='\033[0m'

ZSHRC="$HOME/.zshrc"
CCR_CONFIG="$HOME/.claude-code-router/config.json"

# ── Detect current mode ───────────────────────────────────────────────────────

detect_current_mode() {
  if ! grep -q "^alias nspec=" "$ZSHRC" 2>/dev/null; then
    echo "1"
  elif grep -q "claude --model claude-sonnet-4-6" "$ZSHRC" 2>/dev/null; then
    echo "2"
  elif grep -q "ANTHROPIC_MODEL=claude-sonnet-4-6" "$ZSHRC" 2>/dev/null; then
    echo "3"
  elif grep -q "ANTHROPIC_MODEL=deepseek-reasoner" "$ZSHRC" 2>/dev/null; then
    echo "4"
  else
    echo "5"
  fi
}

CURRENT_MODE=$(detect_current_mode)

# ── Helpers ───────────────────────────────────────────────────────────────────

# Remove only the alias lines (and the nSpec mode comment above them).
# API key exports are intentionally preserved.
remove_nspec_aliases() {
  if grep -q "^alias nspec=" "$ZSHRC" 2>/dev/null; then
    python3 - << 'PYEOF'
import re, os
zshrc = os.path.expanduser('~/.zshrc')
with open(zshrc, 'r') as f:
    content = f.read()
# Remove nSpec mode comment lines
cleaned = re.sub(r'# nSpec aliases[^\n]*\n', '', content)
# Remove the two alias lines
cleaned = re.sub(r'^alias nspec=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
cleaned = re.sub(r'^alias nspec-fast=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
with open(zshrc, 'w') as f:
    f.write(cleaned)
PYEOF
    echo -e "  ${YELLOW}↺ Previous nSpec aliases updated${RESET}"
  fi
}

# Add an API key export only if not already present in ~/.zshrc
ensure_key_exported() {
  local varname="$1" value="$2"
  if grep -q "^export ${varname}=" "$ZSHRC" 2>/dev/null; then
    echo -e "  ${DIM}✓ ${varname} already in ~/.zshrc — keeping${RESET}"
  else
    echo "export ${varname}=\"${value}\"" >> "$ZSHRC"
    echo -e "  ${GREEN}✓ ${varname} added to ~/.zshrc${RESET}"
  fi
}

stop_ccr() {
  if command -v ccr &>/dev/null && ccr status &>/dev/null 2>&1; then
    ccr stop || true
    echo -e "  ${YELLOW}↺ claude-code-router stopped${RESET}"
  fi
}

install_ccr_if_needed() {
  if command -v ccr &>/dev/null; then
    echo -e "  ${DIM}✓ claude-code-router already installed${RESET}"
  else
    echo "  → Installing claude-code-router..."
    npm install -g @musistudio/claude-code-router
    echo -e "  ${GREEN}✓ claude-code-router installed${RESET}"
  fi
}

ask_key() {
  local label="$1" url="$2" varname="$3"
  echo ""
  echo -e "  ${BOLD}${label}${RESET}  →  ${url}"
  read -rsp "  Paste key: " value
  echo ""
  if [[ -z "$value" ]]; then
    echo -e "  ${RED}✗ Key cannot be empty.${RESET}"
    exit 1
  fi
  printf -v "$varname" '%s' "$value"
}

write_ccr_config() {
  local p_name="$1" p_key="$2" p_model="$3"
  local s_name="$4" s_key="$5" s_model="$6"
  local p_transformer="$7" s_transformer="$8"

  mkdir -p "$HOME/.claude-code-router"

  local p_extra="" s_extra=""
  [[ -n "$p_transformer" ]] && p_extra=",
      \"transformer\": { \"use\": [\"${p_transformer}\"] }"
  [[ -n "$s_transformer" ]] && s_extra=",
      \"transformer\": { \"use\": [\"${s_transformer}\"] }"

  cat > "$CCR_CONFIG" << EOF
{
  "API_TIMEOUT_MS": 600000,
  "LOG": true,
  "LOG_LEVEL": "info",
  "Providers": [
    {
      "name": "${p_name}",
      "api_base_url": "$(provider_url "$p_name")",
      "api_key": "${p_key}",
      "models": ["${p_model}"]${p_extra}
    },
    {
      "name": "${s_name}",
      "api_base_url": "$(provider_url "$s_name")",
      "api_key": "${s_key}",
      "models": ["${s_model}"]${s_extra}
    }
  ],
  "Router": {
    "default": "${p_name},${p_model}",
    "background": "${s_name},${s_model}"
  }
}
EOF
  echo -e "  ${GREEN}✓ ~/.claude-code-router/config.json written${RESET}"
}

provider_url() {
  case "$1" in
    anthropic) echo "https://api.anthropic.com/v1/messages" ;;
    gemini)    echo "https://generativelanguage.googleapis.com/v1beta/models/" ;;
    deepseek)  echo "https://api.deepseek.com/v1/messages" ;;
    *)         echo "" ;;
  esac
}

start_ccr() {
  echo "  → Starting claude-code-router..."
  nohup ccr start &>/dev/null &
  sleep 1
  echo -e "  ${GREEN}✓ claude-code-router running (pid $!)${RESET}"
}

write_aliases() {
  local comment="$1" primary="$2" secondary="$3"
  {
    echo "# nSpec aliases (${comment})"
    echo "alias nspec=\"${primary}\""
    echo "alias nspec-fast=\"${secondary}\""
  } >> "$ZSHRC"
  echo -e "  ${GREEN}✓ Aliases updated in ~/.zshrc${RESET}"
}

# ── Mode functions ────────────────────────────────────────────────────────────

mode_1() {
  echo ""
  echo -e "${BOLD}Mode 1 — Single model${RESET}"
  echo "  All commands use the active Claude session. No extra setup."
  echo ""
  stop_ccr
  remove_nspec_aliases
  echo ""
  echo -e "${GREEN}${BOLD}✓ Mode 1 active${RESET}"
  echo "────────────────────────────────────────────────"
  echo -e "  Use ${BOLD}claude${RESET} directly."
  echo -e "  Run ${BOLD}source ~/.zshrc${RESET} to apply."
}

mode_2() {
  echo ""
  echo -e "${BOLD}Mode 2 — Sonnet 4.6 + Haiku (Anthropic only)${RESET}"
  echo ""
  stop_ccr
  remove_nspec_aliases
  write_aliases "Mode 2 — Sonnet + Haiku" \
    "claude --model claude-sonnet-4-6" \
    "claude --model claude-haiku-4-5-20251001"
  echo ""
  echo -e "${GREEN}${BOLD}✓ Mode 2 active${RESET}"
  echo "────────────────────────────────────────────────"
  echo -e "  ${BOLD}nspec${RESET}       → Sonnet 4.6"
  echo -e "  ${BOLD}nspec-fast${RESET}  → Haiku"
  echo -e "  Run ${BOLD}source ~/.zshrc${RESET} to apply."
}

mode_3() {
  echo ""
  echo -e "${BOLD}Mode 3 — Sonnet 4.6 + Gemini Flash${RESET}"
  echo ""

  local GEMINI_KEY=""
  if grep -q "^export GEMINI_API_KEY=" "$ZSHRC" 2>/dev/null; then
    echo -e "  ${DIM}✓ GEMINI_API_KEY already in ~/.zshrc${RESET}"
    GEMINI_KEY="$(grep '^export GEMINI_API_KEY=' "$ZSHRC" | head -1 | sed 's/.*="\(.*\)"/\1/')"
  else
    ask_key "Gemini API key" "https://aistudio.google.com/apikey  (free tier ok)" GEMINI_KEY
    ensure_key_exported "GEMINI_API_KEY" "$GEMINI_KEY"
  fi

  install_ccr_if_needed

  if [[ -f "$CCR_CONFIG" ]] && grep -q "claude-sonnet-4-6" "$CCR_CONFIG" && grep -q "gemini-2.5-flash" "$CCR_CONFIG"; then
    echo -e "  ${DIM}✓ ccr config already correct — skipping${RESET}"
  else
    write_ccr_config "anthropic" "\$ANTHROPIC_API_KEY" "claude-sonnet-4-6" \
                     "gemini" "$GEMINI_KEY" "gemini-2.5-flash" "" "gemini"
  fi

  remove_nspec_aliases
  write_aliases "Mode 3 — Sonnet + Gemini Flash" \
    "ANTHROPIC_MODEL=claude-sonnet-4-6 claude" \
    "ANTHROPIC_MODEL=gemini-2.5-flash claude"

  start_ccr
  echo ""
  echo -e "${GREEN}${BOLD}✓ Mode 3 active${RESET}"
  echo "────────────────────────────────────────────────"
  echo -e "  ${BOLD}nspec${RESET}       → Sonnet 4.6"
  echo -e "  ${BOLD}nspec-fast${RESET}  → Gemini 2.5 Flash"
  echo ""
  echo "  Run in your terminal:"
  echo -e "  ${BOLD}source ~/.zshrc && eval \"\$(ccr activate)\"${RESET}"
}

mode_4() {
  echo ""
  echo -e "${BOLD}Mode 4 — DeepSeek-R1 + Gemini Flash${RESET}"
  echo ""

  local DEEPSEEK_KEY="" GEMINI_KEY=""

  if grep -q "^export DEEPSEEK_API_KEY=" "$ZSHRC" 2>/dev/null; then
    echo -e "  ${DIM}✓ DEEPSEEK_API_KEY already in ~/.zshrc${RESET}"
    DEEPSEEK_KEY="$(grep '^export DEEPSEEK_API_KEY=' "$ZSHRC" | head -1 | sed 's/.*="\(.*\)"/\1/')"
  else
    ask_key "DeepSeek API key" "https://platform.deepseek.com/api_keys" DEEPSEEK_KEY
    ensure_key_exported "DEEPSEEK_API_KEY" "$DEEPSEEK_KEY"
  fi

  if grep -q "^export GEMINI_API_KEY=" "$ZSHRC" 2>/dev/null; then
    echo -e "  ${DIM}✓ GEMINI_API_KEY already in ~/.zshrc${RESET}"
    GEMINI_KEY="$(grep '^export GEMINI_API_KEY=' "$ZSHRC" | head -1 | sed 's/.*="\(.*\)"/\1/')"
  else
    ask_key "Gemini API key" "https://aistudio.google.com/apikey  (free tier ok)" GEMINI_KEY
    ensure_key_exported "GEMINI_API_KEY" "$GEMINI_KEY"
  fi

  install_ccr_if_needed

  if [[ -f "$CCR_CONFIG" ]] && grep -q "deepseek-reasoner" "$CCR_CONFIG" && grep -q "gemini-2.5-flash" "$CCR_CONFIG"; then
    echo -e "  ${DIM}✓ ccr config already correct — skipping${RESET}"
  else
    write_ccr_config "deepseek" "$DEEPSEEK_KEY" "deepseek-reasoner" \
                     "gemini" "$GEMINI_KEY" "gemini-2.5-flash" "openai" "gemini"
  fi

  remove_nspec_aliases
  write_aliases "Mode 4 — DeepSeek-R1 + Gemini Flash" \
    "ANTHROPIC_MODEL=deepseek-reasoner claude" \
    "ANTHROPIC_MODEL=gemini-2.5-flash claude"

  start_ccr
  echo ""
  echo -e "${GREEN}${BOLD}✓ Mode 4 active${RESET}"
  echo "────────────────────────────────────────────────"
  echo -e "  ${BOLD}nspec${RESET}       → DeepSeek-R1"
  echo -e "  ${BOLD}nspec-fast${RESET}  → Gemini 2.5 Flash"
  echo ""
  echo "  Run in your terminal:"
  echo -e "  ${BOLD}source ~/.zshrc && eval \"\$(ccr activate)\"${RESET}"
}

mode_5() {
  echo ""
  echo -e "${BOLD}Mode 5 — Custom${RESET}"
  echo ""

  echo -e "  ${BOLD}Primary model ID${RESET} for nspec (reasoning commands):"
  read -rp "  e.g. claude-sonnet-4-6, deepseek-reasoner: " PRIMARY_MODEL
  if [[ -z "$PRIMARY_MODEL" ]]; then
    echo -e "  ${RED}✗ Cannot be empty.${RESET}"; exit 1
  fi

  echo ""
  echo -e "  ${BOLD}Secondary model ID${RESET} for nspec-fast (structured commands):"
  read -rp "  e.g. gemini-2.5-flash, claude-haiku-4-5-20251001: " SECONDARY_MODEL
  if [[ -z "$SECONDARY_MODEL" ]]; then
    echo -e "  ${RED}✗ Cannot be empty.${RESET}"; exit 1
  fi

  stop_ccr
  remove_nspec_aliases
  write_aliases "Mode 5 — Custom" \
    "ANTHROPIC_MODEL=${PRIMARY_MODEL} claude" \
    "ANTHROPIC_MODEL=${SECONDARY_MODEL} claude"

  echo ""
  echo -e "${YELLOW}  Configure claude-code-router manually if your models require an external provider.${RESET}"
  echo ""
  echo -e "${GREEN}${BOLD}✓ Mode 5 active${RESET}"
  echo "────────────────────────────────────────────────"
  echo -e "  ${BOLD}nspec${RESET}       → ${PRIMARY_MODEL}"
  echo -e "  ${BOLD}nspec-fast${RESET}  → ${SECONDARY_MODEL}"
  echo -e "  Run ${BOLD}source ~/.zshrc${RESET} to apply."
}

# ── Menu ──────────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}nSpec — Model mode manager${RESET}"
echo "────────────────────────────────────────────────"
echo ""
echo -e "  Current mode: ${CYAN}${BOLD}Mode ${CURRENT_MODE}${RESET}"
echo ""
echo "  1 — Single model         (active Claude session, no setup)"
echo "  2 — Sonnet + Haiku       (Anthropic only, no gateway)"
echo "  3 — Sonnet + Gemini Flash      (claude-code-router)"
echo "  4 — DeepSeek-R1 + Gemini Flash (claude-code-router)"
echo "  5 — Custom"
echo ""
read -rp "  Choose mode [1-5]: " CHOICE

case "$CHOICE" in
  1) mode_1 ;;
  2) mode_2 ;;
  3) mode_3 ;;
  4) mode_4 ;;
  5) mode_5 ;;
  *) echo -e "${RED}Invalid option.${RESET}"; exit 1 ;;
esac

echo ""
