# nSpec — n8n Spec-Driven Development Framework

@.claude/specs/base-standards.mdc

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
