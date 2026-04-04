# /init-config

One-time setup for Claude Code model configuration. Run this once before starting
your first workflow. Safe to re-run — it detects existing configuration and skips
steps already done.

> **Claude Code only.** Other agents (Cursor, Copilot, Gemini CLI) do not need this command.

> **Rate limit?** If you cannot run this command because you've hit Anthropic's rate limit,
> run `bash scripts/nspec-setup.sh` directly in your terminal — no Claude required.
> Shows current mode and lets you switch. Detects what's already configured and skips completed steps.

---

## Convention for updating ~/.zshrc

**Always follow these rules when writing to `~/.zshrc`:**

1. **Remove existing alias lines first** — never duplicate. Use this snippet before appending new aliases:

```bash
python3 -c "
import re, os
zshrc = os.path.expanduser('~/.zshrc')
with open(zshrc, 'r') as f:
    content = f.read()
cleaned = re.sub(r'# nSpec aliases[^\n]*\n', '', content)
cleaned = re.sub(r'^alias nspec=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
cleaned = re.sub(r'^alias nspec-fast=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
with open(zshrc, 'w') as f:
    f.write(cleaned)
"
```

2. **Only add API key exports if not already present** — check before writing:

```bash
grep -q "^export GEMINI_API_KEY=" ~/.zshrc || echo 'export GEMINI_API_KEY="{GEMINI_KEY}"' >> ~/.zshrc
grep -q "^export DEEPSEEK_API_KEY=" ~/.zshrc || echo 'export DEEPSEEK_API_KEY="{DEEPSEEK_KEY}"' >> ~/.zshrc
```

3. **Never delete existing export lines** — API keys are permanent and survive mode switches.

---

## Process

### Step 1 — Check existing configuration

Run:
```bash
grep -q "nspec-fast" ~/.zshrc && echo "CONFIGURED" || echo "NOT_CONFIGURED"
```

If `CONFIGURED`:
> Model configuration already detected in `~/.zshrc`.
> Run `/init-workflow {WF-ID}` to start your first workflow.

Stop here.

---

### Step 2 — Single or two models

Ask the user:

> **Claude Code model setup**
>
> How do you want to run nSpec commands?
>
> **A — Single model** — all commands use the same Claude session.
> Simple, no extra setup needed. Recommended if you are just getting started.
>
> **B — Two models** — reasoning commands use a powerful model, structured tasks
> (validate, deploy, document) use a faster/cheaper model.
> Saves cost on secondary steps. Requires a brief setup.

---

### Step 3A — Single model

Tell the user:

> Single model selected. No extra setup needed.
> Run `/init-workflow {WF-ID}` to start your first workflow.

Stop here.

---

### Step 3B — Choose the model pair

Ask:

> Which model pair do you want?
>
> **1 — Sonnet 4.6 + Haiku** — both Anthropic models, no external API needed.
> Simplest two-model setup.
>
> **2 — Sonnet 4.6 + Gemini Flash** — Gemini Flash for secondary tasks.
> Cheaper than Haiku. Requires a Gemini API key and `claude-code-router`.
>
> **3 — DeepSeek-R1 + Gemini Flash** — DeepSeek-R1 for complex reasoning,
> Gemini Flash for secondary tasks. Best cost/quality for reasoning-heavy workflows.
> Requires API keys for DeepSeek and Gemini, plus `claude-code-router`.
>
> **4 — Custom** — enter any model IDs for `nspec` and `nspec-fast`.

---

### Step 4-1 — Sonnet + Haiku setup

Remove existing alias lines, then add new ones (follow the [convention](#convention-for-updating-zshrc)):

```bash
# 1. Remove existing alias lines
python3 -c "
import re, os
zshrc = os.path.expanduser('~/.zshrc')
with open(zshrc, 'r') as f: content = f.read()
cleaned = re.sub(r'# nSpec aliases[^\n]*\n', '', content)
cleaned = re.sub(r'^alias nspec=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
cleaned = re.sub(r'^alias nspec-fast=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
with open(zshrc, 'w') as f: f.write(cleaned)
"

# 2. Append new aliases
cat >> ~/.zshrc << 'EOF'
# nSpec aliases (Mode 2 — Sonnet + Haiku)
alias nspec="claude --model claude-sonnet-4-6"
alias nspec-fast="claude --model claude-haiku-4-5-20251001"
EOF
```

Tell the user:

> Done. Aliases added to `~/.zshrc`:
> - `nspec` → Sonnet 4.6 (reasoning commands)
> - `nspec-fast` → Haiku (structured commands)
>
> Run `source ~/.zshrc` to activate them in this terminal.
> From now on, use `nspec` instead of `claude` to start your sessions.

Stop here.

---

### Step 4-2 — Sonnet + Gemini Flash setup

Follow **[ccr-gemini]** below with primary = Sonnet.

---

### Step 4-3 — DeepSeek-R1 + Gemini Flash setup

Follow **[ccr-deepseek]** below.

---

### Step 4-4 — Custom setup

Ask:

> Enter the model ID for `nspec` (primary/reasoning commands):

Store as `{PRIMARY_MODEL}`.

> Enter the model ID for `nspec-fast` (secondary/structured commands):

Store as `{SECONDARY_MODEL}`.

Remove existing alias lines, then add new ones (follow the [convention](#convention-for-updating-zshrc)):

```bash
# 1. Remove existing alias lines
python3 -c "
import re, os
zshrc = os.path.expanduser('~/.zshrc')
with open(zshrc, 'r') as f: content = f.read()
cleaned = re.sub(r'# nSpec aliases[^\n]*\n', '', content)
cleaned = re.sub(r'^alias nspec=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
cleaned = re.sub(r'^alias nspec-fast=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
with open(zshrc, 'w') as f: f.write(cleaned)
"

# 2. Append new aliases (replace {PRIMARY_MODEL} and {SECONDARY_MODEL})
cat >> ~/.zshrc << EOF
# nSpec aliases (Mode 5 — Custom)
alias nspec="ANTHROPIC_MODEL={PRIMARY_MODEL} claude"
alias nspec-fast="ANTHROPIC_MODEL={SECONDARY_MODEL} claude"
EOF
```

Tell the user:

> Done. Aliases added to `~/.zshrc`.
> Configure `claude-code-router` manually if any model requires an external provider.
> Run `source ~/.zshrc` to activate aliases in this terminal.

Stop here.

---

## [ccr-gemini] — Sonnet + Gemini Flash via claude-code-router

### Ask for the Gemini API key

> Paste your Gemini API key.
> Get one free at https://aistudio.google.com/apikey

Store the value as `{GEMINI_KEY}`.

### Install ccr if not present

Run:
```bash
command -v ccr &>/dev/null && echo "INSTALLED" || npm install -g @musistudio/claude-code-router
```

### Create ccr config

Run:
```bash
mkdir -p ~/.claude-code-router
```

Write `~/.claude-code-router/config.json` (replace `{GEMINI_KEY}` with the actual key):

```json
{
  "API_TIMEOUT_MS": 600000,
  "LOG": true,
  "LOG_LEVEL": "info",
  "Providers": [
    {
      "name": "anthropic",
      "api_base_url": "https://api.anthropic.com/v1/messages",
      "api_key": "$ANTHROPIC_API_KEY",
      "models": ["claude-sonnet-4-6"]
    },
    {
      "name": "gemini",
      "api_base_url": "https://generativelanguage.googleapis.com/v1beta/models/",
      "api_key": "{GEMINI_KEY}",
      "models": ["gemini-2.5-flash"],
      "transformer": { "use": ["gemini"] }
    }
  ],
  "Router": {
    "default": "anthropic,claude-sonnet-4-6",
    "background": "gemini,gemini-2.5-flash"
  }
}
```

### Add aliases and API key to ~/.zshrc

Follow the [convention](#convention-for-updating-zshrc): remove existing alias lines, add key only if missing, then append aliases.

```bash
# 1. Remove existing alias lines
python3 -c "
import re, os
zshrc = os.path.expanduser('~/.zshrc')
with open(zshrc, 'r') as f: content = f.read()
cleaned = re.sub(r'# nSpec aliases[^\n]*\n', '', content)
cleaned = re.sub(r'^alias nspec=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
cleaned = re.sub(r'^alias nspec-fast=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
with open(zshrc, 'w') as f: f.write(cleaned)
"

# 2. Add API key only if not already present
grep -q "^export GEMINI_API_KEY=" ~/.zshrc || echo 'export GEMINI_API_KEY="{GEMINI_KEY}"' >> ~/.zshrc

# 3. Append new aliases
cat >> ~/.zshrc << 'EOF'
# nSpec aliases (Mode 3 — Sonnet + Gemini Flash)
alias nspec="ANTHROPIC_MODEL=claude-sonnet-4-6 claude"
alias nspec-fast="ANTHROPIC_MODEL=gemini-2.5-flash claude"
EOF
```

### Start the router

```bash
ccr start && eval "$(ccr activate)"
```

### Confirm

Tell the user:

> Done. `claude-code-router` is running.
> Aliases added to `~/.zshrc`:
> - `nspec` → Sonnet 4.6 (reasoning commands)
> - `nspec-fast` → Gemini 2.5 Flash (structured commands)
>
> Run `source ~/.zshrc` to activate aliases in new terminals.
> From now on, use `nspec` instead of `claude` to start your sessions.
> `ccr` starts automatically with `/init-workflow` on future sessions.

Stop here.

---

## [ccr-deepseek] — DeepSeek-R1 + Gemini Flash via claude-code-router

### Ask for API keys

> Paste your DeepSeek API key.
> Get one at https://platform.deepseek.com/api_keys

Store the value as `{DEEPSEEK_KEY}`.

> Paste your Gemini API key.
> Get one free at https://aistudio.google.com/apikey

Store the value as `{GEMINI_KEY}`.

### Install ccr if not present

Run:
```bash
command -v ccr &>/dev/null && echo "INSTALLED" || npm install -g @musistudio/claude-code-router
```

### Create ccr config

Run:
```bash
mkdir -p ~/.claude-code-router
```

Write `~/.claude-code-router/config.json` (replace `{DEEPSEEK_KEY}` and `{GEMINI_KEY}` with actual keys):

```json
{
  "API_TIMEOUT_MS": 600000,
  "LOG": true,
  "LOG_LEVEL": "info",
  "Providers": [
    {
      "name": "deepseek",
      "api_base_url": "https://api.deepseek.com/v1/messages",
      "api_key": "{DEEPSEEK_KEY}",
      "models": ["deepseek-reasoner"],
      "transformer": { "use": ["openai"] }
    },
    {
      "name": "gemini",
      "api_base_url": "https://generativelanguage.googleapis.com/v1beta/models/",
      "api_key": "{GEMINI_KEY}",
      "models": ["gemini-2.5-flash"],
      "transformer": { "use": ["gemini"] }
    }
  ],
  "Router": {
    "default": "deepseek,deepseek-reasoner",
    "background": "gemini,gemini-2.5-flash"
  }
}
```

### Add aliases and API keys to ~/.zshrc

Follow the [convention](#convention-for-updating-zshrc): remove existing alias lines, add keys only if missing, then append aliases.

```bash
# 1. Remove existing alias lines
python3 -c "
import re, os
zshrc = os.path.expanduser('~/.zshrc')
with open(zshrc, 'r') as f: content = f.read()
cleaned = re.sub(r'# nSpec aliases[^\n]*\n', '', content)
cleaned = re.sub(r'^alias nspec=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
cleaned = re.sub(r'^alias nspec-fast=[^\n]*\n', '', cleaned, flags=re.MULTILINE)
with open(zshrc, 'w') as f: f.write(cleaned)
"

# 2. Add API keys only if not already present
grep -q "^export DEEPSEEK_API_KEY=" ~/.zshrc || echo 'export DEEPSEEK_API_KEY="{DEEPSEEK_KEY}"' >> ~/.zshrc
grep -q "^export GEMINI_API_KEY=" ~/.zshrc    || echo 'export GEMINI_API_KEY="{GEMINI_KEY}"' >> ~/.zshrc

# 3. Append new aliases
cat >> ~/.zshrc << 'EOF'
# nSpec aliases (Mode 4 — DeepSeek-R1 + Gemini Flash)
alias nspec="ANTHROPIC_MODEL=deepseek-reasoner claude"
alias nspec-fast="ANTHROPIC_MODEL=gemini-2.5-flash claude"
EOF
```

### Start the router

```bash
ccr start && eval "$(ccr activate)"
```

### Confirm

Tell the user:

> Done. `claude-code-router` is running.
> Aliases added to `~/.zshrc`:
> - `nspec` → DeepSeek-R1 (reasoning commands)
> - `nspec-fast` → Gemini 2.5 Flash (structured commands)
>
> Run `source ~/.zshrc` to activate aliases in new terminals.
> From now on, use `nspec` instead of `claude` to start your sessions.
> `ccr` starts automatically with `/init-workflow` on future sessions.

Stop here.
