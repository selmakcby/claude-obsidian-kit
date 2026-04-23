---
name: llm-wiki
description: Obsidian vault operations for AI agents. Use when reading from, writing to, or maintaining a project knowledge graph stored as markdown in a vault. Provides INGEST, QUERY, LINT operations.
---

# LLM-Wiki

The **shared brain pattern** for AI agents. Turn ephemeral agent conversations into persistent, searchable, human-editable knowledge stored as markdown files in an Obsidian vault.

Unlike RAG systems that rediscover context on every query, llm-wiki **accumulates** — the agent reads new sources, integrates them with existing knowledge, updates entity pages, flags contradictions, and maintains cross-references.

---

## Three operations (and which agent runs each)

### 1. INGEST — Absorb new knowledge (runs on `scribe`, haiku)

**When:** A new source arrives (session transcript, decision, doc, finding).

**Flow:**
```
source  →  scribe (haiku) → format + write summary note
                          → update index (one-line append)
                          → cross-link related pages
```

**Why scribe:** running a cheap haiku-backed writer is ~10× cheaper than
having the thinking agent (planner/builder) format its own output.
Separate thinking from writing.

See [[ingest]] for detailed protocol.

### 2. QUERY — Retrieve & synthesize (runs on `archivist`, sonnet)

**When:** Someone asks a factual question about the project.

**Flow:**
```
question  →  archivist (sonnet) → read index (1 file) → grep relevant
                                → read 2-5 notes → synthesize answer
                                → (if useful) recommend refiling
```

**Token rule:** never load more than 5 notes per QUERY. If you need more,
the question is too broad.

See [[query]] for detailed protocol.

### 3. LINT — Vault health (runs on `archivist`, sonnet)

**When:** Periodic check (weekly) or on-demand.

**Flow:**
```
full vault scan → orphans + broken links + stale notes + missing concepts
                → severity-sorted report with fix suggestions
```

**LINT is read-only** — flags issues, doesn't fix them. Human decides.

See [[lint]] for detailed protocol.

---

## Vault structure (standard)

```
vault/
├── index.md              ← entry point, links to all top-level concepts
├── _schema/
│   ├── template.md       ← frontmatter template for new notes
│   └── conventions.md    ← naming, linking, tagging rules
│
├── architecture/         ← how it's built
├── decisions/            ← why we chose X over Y (dated)
├── design/               ← UI decisions, component briefs
├── entities/             ← tools, services, people
├── concepts/             ← cross-cutting ideas
└── sessions/             ← dated session summaries
```

---

## Routing rules (where does a note go?)

| What | Folder |
|---|---|
| "Why we chose X" | `decisions/YYYY-MM-DD-<slug>.md` |
| "Component design for X" | `design/<feature>-components.md` |
| "About <service/tool>" | `entities/<name>.md` |
| "Concept X explained" | `concepts/<topic>.md` |
| "Session summary" | `sessions/YYYY-MM-DD-<slug>.md` |
| "System overview" | `architecture/overview.md` |

---

## Frontmatter (required on every note)

```yaml
---
type: decision | session | entity | concept | architecture | design
date: YYYY-MM-DD
tags: [auth, payments, ...]
links: [[other-note]]
status: draft | accepted | deprecated
---
```

---

## Golden rules

- **Accumulate, don't replace.** New info merges with existing. Never silently delete.
- **Atomic notes.** One idea per note. 200-400 lines ideal, 800 max.
- **Link aggressively.** 200 well-linked notes > 2000 disconnected ones.
- **Human-readable.** Write for future-you. Not JSON, not dense summaries — readable markdown.
- **Shortest path links.** `[[stripe]]` not `[[entities/stripe]]` — Obsidian resolves.
- **Date everything.** Frontmatter `date` mandatory. Decisions/sessions also in filename.
- **Status is a decision log.** Old decisions don't get deleted, they get `status: deprecated`.

---

## When to skip the vault

- Exploratory chat (not a decision yet)
- Sensitive data (PII, secrets, credentials)
- Trivial statements ("ok", "done")
- Duplicates — update existing note instead

---

## See also

- `ingest.md` — INGEST protocol details
- `query.md` — QUERY protocol details
- `lint.md` — LINT protocol details
