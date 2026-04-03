# nSpec — n8n Spec-Driven Development Framework

@.claude/specs/base-standards.mdc

## Setup inicial (solo Claude Code, solo una vez)

```
/init-config
```

Configura el modelo o modelos a usar. Solo necesario la primera vez.
Ver sección [Configuración de modelos](#configuración-de-modelos-opcional) para detalles.

## Flujo A — Equipo (PO escribe los requirements)

```
requirements.md → /enrich-workflow-spec → /plan-workflow → /build-workflow
                                                                    ↓
                                     /document-workflow ← /deploy-workflow ← /validate-workflow
```

| Step | Command | Input | Output |
|------|---------|-------|--------|
| 1 | `/enrich-workflow-spec {WF-ID}` | `changes/{WF-ID}/requirements.md` | requirements enriquecidos |
| 2 | `/plan-workflow {WF-ID}` | requirements enriquecidos | `changes/{WF-ID}/plan.md` |
| — | `/clear` | — | reset de contexto (descarga skills de planning) |
| 3 | `/build-workflow {WF-ID}` | plan aprobado | `changes/{WF-ID}/workflow.json` |
| — | `/clear` | — | reset de contexto (descarga skills de build) |
| 4 | `/validate-workflow {WF-ID}` | workflow.json | validation report |
| 5 | `/review-workflow {WF-ID}` | workflow.json | review with fixes |
| 6 | `/deploy-workflow {WF-ID}` | validated workflow.json | deployed workflow URL |
| 7 | `/document-workflow {WF-ID}` | todo lo anterior | `changes/{WF-ID}/README.md` |

## Flujo B — Freelance (desarrollador habla directamente con el cliente)

```
client-notes.md → /capture-requirements → /create-ticket → /plan-workflow → /build-workflow
                                                                                    ↓
                                               /document-workflow ← /deploy-workflow ← /validate-workflow
```

| Step | Command | Input | Output |
|------|---------|-------|--------|
| 1 | `/capture-requirements {WF-ID}` | `changes/{WF-ID}/client-notes.md` | `changes/{WF-ID}/requirements.md` |
| 2 | `/create-ticket {WF-ID}` | requirements.md | ticket en Jira / Notion + ID en requirements.md |
| 3 | `/plan-workflow {WF-ID}` | requirements.md | `changes/{WF-ID}/plan.md` |
| — | `/clear` | — | reset de contexto (descarga skills de planning) |
| 4 | `/build-workflow {WF-ID}` | plan aprobado | `changes/{WF-ID}/workflow.json` |
| — | `/clear` | — | reset de contexto (descarga skills de build) |
| 5 | `/validate-workflow {WF-ID}` | workflow.json | validation report |
| 6 | `/review-workflow {WF-ID}` | workflow.json | review with fixes |
| 7 | `/deploy-workflow {WF-ID}` | validated workflow.json | deployed workflow URL |
| 8 | `/document-workflow {WF-ID}` | todo lo anterior | `changes/{WF-ID}/README.md` |

## Maintenance Commands

| Command | Use Case |
|---------|----------|
| `/debug-workflow {WF-ID}` | Workflow falla en producción — diagnosticar y corregir |
| `/iterate-workflow {WF-ID}` | Modificar un workflow ya desplegado |

## Agents

| Agent | Responsibility |
|-------|---------------|
| `workflow-architect` | Diseña la arquitectura — nunca implementa |
| `ai-agent-builder` | Configura AI Agent nodes y sus herramientas |
| `node-developer` | Implementa nodo por nodo desde el plan |
| `integration-specialist` | Diseña conexiones con servicios externos |
| `workflow-reviewer` | Revisa el JSON generado contra todos los estándares |

## Skills disponibles

| Skill | Cuándo cargar | Peso |
|-------|--------------|------|
| `n8n-code-javascript` | **Solo si el workflow tiene Code nodes** | ~18,500 tokens |
| `n8n-workflow-patterns` | Al diseñar arquitectura (plan, capture) | ~18,300 tokens |
| `n8n-mcp-tools-expert` | Siempre en build, validate, deploy, review | ~8,300 tokens |

## Configuración de modelos (opcional)

Ejecuta `/init-config` para configurar esto de forma interactiva.
La tabla y los modos a continuación son la referencia de lo que ese comando configura.

Por defecto todos los comandos usan el modelo activo de la sesión.
Opcionalmente puedes asignar un segundo modelo más ligero a las tareas estructuradas.

### Tipo de tarea por comando

| Comando | Tipo | Modelo |
|---------|------|--------|
| `/capture-requirements` | Razonamiento sobre input ambiguo | principal |
| `/plan-workflow` | Diseño arquitectónico | principal |
| `/build-workflow` | Generación de código | principal |
| `/review-workflow` | Juicio de calidad | principal |
| `/debug-workflow` | Análisis de causa raíz | principal |
| `/iterate-workflow` | Análisis de impacto | principal |
| `/enrich-workflow-spec` | Completitud estructurada | secundario |
| `/create-ticket` | Formateo de documento | secundario |
| `/validate-workflow` | Verificación de checklist | secundario |
| `/deploy-workflow` | Ejecución de herramientas | secundario |
| `/document-workflow` | Síntesis de artefactos | secundario |

### Modos de uso

**Modo 1 — Un solo modelo, sesión única (por defecto, sin setup)**
Sin configuración adicional. Todos los comandos usan el modelo activo en la sesión.
Usa `/clear` entre fases para resetear el contexto.

**Modo 2 — Sonnet + Haiku, múltiples sesiones (sin gateway, solo Anthropic)**
Cada alias abre una sesión separada con el modelo correspondiente.
```bash
# ~/.zshrc
alias nspec="claude --model claude-sonnet-4-6"
alias nspec-fast="claude --model claude-haiku-4-5-20251001"
```

**Modo 3 — Sonnet + [cualquier modelo externo], múltiples sesiones via claude-code-router**
Cada alias abre una sesión separada. Requiere [`claude-code-router`](https://github.com/musistudio/claude-code-router) corriendo como proxy local.
```bash
npm install -g @musistudio/claude-code-router
ccr start && eval "$(ccr activate)"
```
```bash
# ~/.zshrc — sustituye <segundo-modelo> por el que elijas (ej: gemini-2.5-flash)
alias nspec="ANTHROPIC_MODEL=claude-sonnet-4-6 claude"
alias nspec-fast="ANTHROPIC_MODEL=<segundo-modelo> claude"
```

Comandos de tipo `principal` → `nspec`
Comandos de tipo `secundario` → `nspec-fast -p "/<comando> {WF-ID}"`

## Estrategia de contexto (optimización de tokens)

Usar `/clear` entre fases para resetear el contexto sin salir de Claude Code.
El estado persiste en disco (`changes/{WF-ID}/`), no en la conversación.

```
Fase 1 — Spec & Plan      (~15,000 tokens)
  /capture-requirements  →  /create-ticket  →  /plan-workflow
  → /clear

Fase 2 — Build            (~100,000 tokens, la más pesada)
  /build-workflow
  → /clear

Fase 3 — QA & Deploy      (~60,000 tokens)
  /validate-workflow  →  /review-workflow  →  /deploy-workflow  →  /document-workflow
```

**Por qué funciona:** `/build-workflow` carga los dos skills más pesados
(`n8n-mcp-tools-expert` + opcionalmente `n8n-code-javascript`) y genera decenas
de turns con MCP. El `/clear` descarga esos ~27,000 tokens de skills antes de
pasar a QA, donde ya no se necesitan.

**Ahorro estimado:** ~30,000–50,000 tokens en fase 3 respecto a no hacer `/clear`.

## Estructura de changes/

```
changes/
└── {WF-ID}/              # Ej: WF-001 o PROJ-42-lead-qualify
    ├── config.md         # Preferencia de idioma: lang: es | en | pt  (escrito por /init-workflow)
    ├── client-notes.md   # Flujo B: notas crudas del cliente (input de /capture-requirements)
    ├── requirements.md   # Flujo A+B: spec estructurada (input de /plan-workflow)
    ├── plan.md           # Output de /plan-workflow
    ├── workflow.json     # Output de /build-workflow
    ├── review.md         # Output de /review-workflow
    └── README.md         # Output de /document-workflow
```

- Flujo A: usa `templates/requirements.md` como punto de partida
- Flujo B: usa `templates/client-notes.md` como punto de partida
