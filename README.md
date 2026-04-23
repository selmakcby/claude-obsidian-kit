<div align="center">

# 🧠 claude-obsidian-kit

**Give your Claude Code agents a shared, persistent brain.**

*Turn ephemeral sessions into accumulating knowledge — stored in an Obsidian vault.*
*Built for efficiency: right model for each job, cheap writes, index-first reads.*

```
   ┌─ planner (opus) ─┐
   │ ui-agent (sonnet)│      QUERY / LINT
   │ builder  (sonnet)│ ─────▶ archivist (sonnet · read-only)
   │ reviewer (sonnet)│             │
   └──────────────────┘             ▼
            │                     VAULT
            └────── INGEST ──▶ scribe (haiku · writes)
                                     ▲
                                     │
                               Main Claude
                               (orchestrator)
```

[Install](#install) · [Efficiency](#efficiency) · [FAQ](FAQ.md) · [How it works](#how-it-works)

</div>

---

## What this is

A drop-in kit that extends Claude Code with:

- **Two agents:**
  - `archivist` — vault reader + health guardian (QUERY, LINT)
  - `scribe` — dedicated vault writer (INGEST, runs on haiku for efficiency)
- **One skill** — `llm-wiki` — the INGEST · QUERY · LINT protocols
- **One vault template** — pre-structured Obsidian vault with conventions

After install, your agents read from and write to a shared markdown knowledge graph that **survives sessions**. Yesterday's decisions are tomorrow's context.

---

## The problem this solves

Default Claude Code agents are **stateless**:

```
Monday:  agents plan a feature, build it → close session
Tuesday: new session — "why did we use Stripe webhooks?"
Claude:  "I don't know. Let me re-analyze from scratch..."
```

Every session starts from zero. Context dies with the conversation. The project's **reasoning** evaporates even when the code persists.

**With this kit:**

```
Monday:  agents plan → scribe files to vault/decisions/
Tuesday: "why Stripe webhooks?"
archivist → reads vault/decisions/2026-04-21-stripe-webhooks.md → answers in 1 second with full rationale
```

---

## Install

### Quick

```bash
git clone https://github.com/<your-username>/claude-obsidian-kit ~/claude-obsidian-kit

cd ~/claude-obsidian-kit
./scripts/install.sh ~/my-project
```

Installs:
- `~/my-project/.claude/agents/archivist.md`
- `~/my-project/.claude/agents/scribe.md`
- `~/my-project/.claude/skills/llm-wiki/`
- `~/my-project/vault/` *(if doesn't exist)*

### Final step

Update your project's `CLAUDE.md` with vault permissions:

```json
{
  "permissions": {
    "allow": [
      "Write(vault/**)",
      "Edit(vault/**)",
      "Read(vault/**)"
    ]
  }
}
```

---

## How it works

### The 6-agent team

After this kit, your full team:

| Agent | Role | Model | Why this model |
|---|---|---|---|
| planner | Architecture + planning | opus | Deep reasoning |
| ui-agent | Design + components | sonnet | Balanced |
| builder | Backend implementation | sonnet | Coding quality |
| reviewer | Quality + security | sonnet | Thorough analysis |
| **archivist** | **Vault reads (QUERY, LINT)** | **sonnet** | **Synthesis + audit** |
| **scribe** | **Vault writes (INGEST)** | **haiku** | **Cheap + fast** |

The `scribe` / `archivist` split is **token-efficient by design** — see [EFFICIENCY.md](EFFICIENCY.md).

### Three operations

#### 🟢 INGEST (scribe)

Other agents produce findings. Main Claude passes findings to `scribe`. Scribe formats into proper note + writes to correct folder + updates index.

```
planner: "We should use monthly/annual pricing toggle"
  ↓
main Claude: Task(scribe, finding="...", type=decision)
  ↓
scribe: writes vault/decisions/2026-04-23-pricing-toggle.md
```

#### 🔵 QUERY (archivist)

```
you: "Why did we choose monthly/annual toggle?"
  ↓
archivist: reads index.md → greps "toggle" → reads 2-3 notes → synthesizes answer
```

#### 🟡 LINT (archivist)

```
you: "Check vault health"
  ↓
archivist: scans for orphans, broken links, stale notes, contradictions
archivist: returns severity-sorted report with fix suggestions
```

---

## Efficiency

This kit is **intentionally designed for low token cost**. See [EFFICIENCY.md](EFFICIENCY.md) for all 10 patterns.

**Highlights:**

- **Separate thinking from writing** — opus plans, haiku files (80% cost reduction on writes)
- **Index-first reads** — never grep the whole vault
- **Model tiering** — haiku for scribe, sonnet for reads, opus for architecture
- **Least-privilege tools** — smaller system prompts, fewer wasted calls
- **Parallel when independent** — wall-clock savings

**Rough cost per full feature (plan + design + build + review + 2 ingests):** ~$0.18
**Naive "opus everywhere" alternative:** ~$0.90
**→ 5× cheaper** with proper model routing.

---

## FAQ

Common questions about INGEST, QUERY, LINT, PII, versioning, RAG comparison, and more — see [FAQ.md](FAQ.md).

---

## Vault layout

```
vault/
├── index.md              ← entry point, read first
├── _schema/
│   ├── template.md       ← required frontmatter for all notes
│   └── conventions.md    ← naming, linking, tagging rules
│
├── architecture/         ← how the system is built
├── decisions/            ← why we chose X over Y (dated)
├── design/               ← UI/UX decisions
├── entities/             ← tools, services (stripe, supabase)
├── concepts/             ← cross-cutting ideas
└── sessions/             ← dated session summaries
```

Every note has frontmatter. Every note links to others. Orphans are tech debt.

---

## File structure

```
claude-obsidian-kit/
├── README.md                 ← you are here
├── EFFICIENCY.md             ← token patterns (10 of them)
├── FAQ.md                    ← common questions
├── LICENSE                   ← MIT
├── agents/
│   ├── archivist.md          ← reader/guardian (QUERY + LINT)
│   └── scribe.md             ← dedicated writer (INGEST)
├── skills/
│   └── llm-wiki/
│       ├── SKILL.md          ← main skill manifest
│       ├── ingest.md         ← INGEST protocol detail
│       ├── query.md          ← QUERY protocol detail
│       └── lint.md           ← LINT protocol detail
├── vault-template/
│   ├── index.md              ← vault entry point
│   ├── _schema/
│   │   ├── template.md       ← note template
│   │   └── conventions.md    ← full rulebook
│   ├── architecture/
│   ├── decisions/
│   ├── design/
│   ├── entities/example-service.md
│   ├── concepts/example-concept.md
│   └── sessions/
└── scripts/
    └── install.sh            ← one-command setup
```

---

## Works well with

- **Claude Code** — the primary target
- **Obsidian** — the vault viewer/editor (optional — vault is plain markdown)
- **VS Code, Typora, Bear** — any markdown editor works
- **Previous kit:** [knowledge-pipeline](https://github.com/selmakcby/knowledge-pipeline) — this extends it with the multi-agent efficiency layer

---

## License

MIT

---

## Credits

Built on Claude Code's agent + skill system.

Inspired by:
- [obra/superpowers](https://github.com/obra/superpowers) — skills as methodology
- [anthropics/skills](https://github.com/anthropics/skills) — skill file format
- [wshobson/agents](https://github.com/wshobson/agents) — multi-agent orchestration patterns
- Zettelkasten — atomic notes + aggressive linking
