# /init-config

One-time setup for Claude Code model configuration. Run this once before starting
your first workflow. Safe to re-run — it detects existing configuration and skips
steps already done.

> **Claude Code only.** Other agents (Cursor, Copilot, Gemini CLI) do not need this command.

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

### Step 2 — Ask: single or dual model

Ask the user:

> **Claude Code model setup**
>
> How do you want to run nSpec commands?
>
> **A — Single model** — all commands use the same Claude session.
> Simple, no extra setup needed. Recommended if you are just getting started.
>
> **B — Two models** — reasoning commands use Sonnet, structured tasks use a
> faster/cheaper model. Saves cost on validate, deploy and document steps.
> Requires a brief setup.

---

### Step 3A — Single model

Tell the user:

> Single model selected. No extra setup needed.
> Run `/init-workflow {WF-ID}` to start your first workflow.

Stop here.

---

### Step 3B — Two models: choose the second model

Ask:

> Which model do you want for structured tasks (validate, deploy, document)?
>
> **A — Claude Haiku 4.5** (Anthropic) — uses your existing Anthropic API key.
> No extra tools needed.
>
> **B — Gemini 2.5 Flash** (Google) — faster and cheaper than Haiku.
> Requires a Gemini API key and installs `claude-code-router` as a local proxy.

---

### Step 4A — Haiku setup

Add aliases to `~/.zshrc`:

```bash
cat >> ~/.zshrc << 'EOF'

# nSpec aliases (added by /init-config)
alias nspec="claude --model claude-sonnet-4-6"
alias nspec-fast="claude --model claude-haiku-4-5-20251001"
EOF
```

Tell the user:

> Done. Aliases added to `~/.zshrc`:
> - `nspec` → Sonnet (reasoning commands)
> - `nspec-fast` → Haiku (structured commands)
>
> Run `source ~/.zshrc` to activate them in this terminal.
> From now on, use `nspec` instead of `claude` to start your sessions.

Stop here.

---

### Step 4B — Gemini Flash setup

#### 4B.1 — Ask for the API key

> Paste your Gemini API key.
> Get one free at https://aistudio.google.com/apikey

Store the value as `{GEMINI_KEY}`.

#### 4B.2 — Install ccr if not present

Run:
```bash
command -v ccr &>/dev/null && echo "INSTALLED" || npm install -g @musistudio/claude-code-router
```

#### 4B.3 — Create ccr config

Run:
```bash
mkdir -p ~/.claude-code-router
```

Write `~/.claude-code-router/config.json` with this content (replace `{GEMINI_KEY}` with the actual key):

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

#### 4B.4 — Add aliases and API key to ~/.zshrc

```bash
cat >> ~/.zshrc << EOF

# nSpec aliases (added by /init-config)
export GEMINI_API_KEY="{GEMINI_KEY}"
alias nspec="ANTHROPIC_MODEL=claude-sonnet-4-6 claude"
alias nspec-fast="ANTHROPIC_MODEL=gemini-2.5-flash claude"
EOF
```

#### 4B.5 — Start the router

```bash
ccr start && eval "$(ccr activate)"
```

#### 4B.6 — Confirm

Tell the user:

> Done. `claude-code-router` is running.
> Aliases added to `~/.zshrc`:
> - `nspec` → Sonnet (reasoning commands)
> - `nspec-fast` → Gemini 2.5 Flash (structured commands)
>
> Run `source ~/.zshrc` to activate aliases in new terminals.
> From now on, use `nspec` instead of `claude` to start your sessions.
> `ccr` starts automatically with `/init-workflow` on future sessions.
