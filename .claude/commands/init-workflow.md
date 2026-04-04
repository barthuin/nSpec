# /init-workflow

Sets up the working directory for a new workflow by creating the folder and copying
the appropriate template files.

**Input**: `$ARGUMENTS` — workflow ID (e.g. `WF-001`)
**Output**: `changes/$ARGUMENTS/` folder with the right template(s) ready to fill in

## Process

### Step 0 — Start ccr if configured

Run silently. No output to the user:
```bash
command -v ccr &>/dev/null && (ccr status 2>/dev/null | grep -qi "running" || ccr start)
```

### Step 1 — Validate the ID

1. Check that `$ARGUMENTS` is provided. If not, stop and respond:
   "Usage: `/init-workflow {WF-ID}` — example: `/init-workflow WF-001`"
2. Check if `changes/$ARGUMENTS/` already exists.
   - If it does, stop and respond:
     "`changes/$ARGUMENTS/` already exists. Use `/capture-requirements $ARGUMENTS` or
     `/enrich-workflow-spec $ARGUMENTS` to continue working on it."

### Step 2 — Choose language

Ask the user (always in all three languages simultaneously so they can pick):

> **Language / Idioma / Langue**
>
> **A — Español** — todas las respuestas en español
> **B — English** — all responses in English
> **C — Português** — todas as respostas em português

Map the answer to a code: `A` → `es` · `B` → `en` · `C` → `pt`.
Use this language for all subsequent steps in this command and for all future
commands run on this workflow ID.

### Step 3 — Choose model mode

Run silently:
```bash
grep -q "nspec-fast" ~/.zshrc && echo "DUAL" || echo "SINGLE"
```

If `SINGLE`: skip this step. `model_mode` will be `single`.

If `DUAL`, ask in the chosen language:

> **(es)** ¿Cómo quieres ejecutar los comandos de este workflow?
> **(en)** How do you want to run commands for this workflow?
> **(pt)** Como quer executar os comandos deste workflow?
>
> **A — Sesión única / Single session / Sessão única**
> Todos los comandos en esta sesión con Sonnet. Más simple.
> Usa `/clear` entre fases para liberar contexto.
>
> **B — Sesiones separadas / Dual sessions / Sessões separadas**
> Comandos de razonamiento con `nspec` (Sonnet).
> Comandos estructurados con `nspec-fast` (Haiku / Gemini Flash).
> Ahorra coste en validate, deploy y document.

Map: `A` → `model_mode: single` · `B` → `model_mode: dual`

---

### Step 4 — Choose the flow

Ask in the chosen language which flow applies:

> **(es)** ¿Qué flujo aplica para este workflow?
> **(en)** Which flow applies to this workflow?
> **(pt)** Qual fluxo se aplica a este workflow?
>
> **A — Team / Equipo**: a PO or non-technical person has already written or
> will write the requirements.
> → Copies `templates/requirements.md` → `changes/$ARGUMENTS/requirements.md`
>
> **B — Freelance**: you are talking directly to the client and will capture
> requirements yourself.
> → Copies `templates/client-notes.md` → `changes/$ARGUMENTS/client-notes.md`

### Step 5 — Create folder and config

3. Create the directory `changes/$ARGUMENTS/`
4. Create `changes/$ARGUMENTS/config.md` with:
   ```
   lang: {code}
   model_mode: {mode}
   ```
   where `{code}` is `es`, `en`, or `pt` from Step 2,
   and `{mode}` is `single` or `dual` from Step 3.
5. Based on the chosen flow:

   **Flow A:**
   - Copy `templates/requirements.md` → `changes/$ARGUMENTS/requirements.md`

   **Flow B:**
   - Copy `templates/client-notes.md` → `changes/$ARGUMENTS/client-notes.md`

### Step 6 — Confirm and guide

6. Confirm what was created and tell the user the next step.
   Use the chosen language:

   **Flow A — es:**
   ```
   Listo. Carpeta creada: changes/$ARGUMENTS/
   Archivos: config.md · requirements.md

   Abre changes/$ARGUMENTS/requirements.md y describe el workflow.
   Cuando esté listo, ejecuta: /enrich-workflow-spec $ARGUMENTS
   ```

   **Flow A — en:**
   ```
   Done. Folder created: changes/$ARGUMENTS/
   Files: config.md · requirements.md

   Open changes/$ARGUMENTS/requirements.md and fill in the workflow description.
   When ready, run: /enrich-workflow-spec $ARGUMENTS
   ```

   **Flow A — pt:**
   ```
   Pronto. Pasta criada: changes/$ARGUMENTS/
   Arquivos: config.md · requirements.md

   Abra changes/$ARGUMENTS/requirements.md e descreva o workflow.
   Quando estiver pronto, execute: /enrich-workflow-spec $ARGUMENTS
   ```

   **Flow B — es:**
   ```
   Listo. Carpeta creada: changes/$ARGUMENTS/
   Archivos: config.md · client-notes.md

   Abre changes/$ARGUMENTS/client-notes.md y pega el input del cliente
   (notas de reunión, email, mensajes de WhatsApp — cualquier formato sirve).
   Cuando esté listo, ejecuta: /capture-requirements $ARGUMENTS
   ```

   **Flow B — en:**
   ```
   Done. Folder created: changes/$ARGUMENTS/
   Files: config.md · client-notes.md

   Open changes/$ARGUMENTS/client-notes.md and paste the raw client input
   (meeting notes, email, WhatsApp messages — anything works).
   When ready, run: /capture-requirements $ARGUMENTS
   ```

   **Flow B — pt:**
   ```
   Pronto. Pasta criada: changes/$ARGUMENTS/
   Arquivos: config.md · client-notes.md

   Abra changes/$ARGUMENTS/client-notes.md e cole o input do cliente
   (notas de reunião, e-mail, mensagens de WhatsApp — qualquer formato funciona).
   Quando estiver pronto, execute: /capture-requirements $ARGUMENTS
   ```
