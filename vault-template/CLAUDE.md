# Vault Constitution (CLAUDE.md)

> This file is the **schema** — the constitution of the vault. Agents read it before
> touching any note. It is a template: copy it to your own vault root and adapt the
> purpose, folders and naming to your domain. Nothing in here is project-specific.

## Purpose

This vault is the persistent, shared knowledge graph for the project. It exists to answer:

- What was this decision, and why was it made that way?
- What is this service / tool / concept, and where is it used?
- What happened in past work sessions that today's session should know?
- What is stale, contradictory, or missing?

## The three layers

| Layer | Where | Rule |
|---|---|---|
| **Raw sources** | The project itself: code, transcripts, exports, docs | **Immutable to agents.** Read-only. Never write, move, rename, or delete. |
| **Wiki** | `vault/` (this folder) + `index.md` + `log.md` | Owned by the agents. Humans read, agents write. |
| **Schema** | This file | Co-evolved. Change it deliberately, log the change. |

## Folder structure

```
vault/
├── CLAUDE.md          ← this constitution
├── index.md           ← catalogue — updated on every ingest
├── _schema/           ← template.md + conventions.md (the detailed rulebook)
├── architecture/      ← system design docs
├── decisions/         ← every "why X over Y", dated, with rationale
├── design/            ← UI/UX design decisions
├── entities/          ← one page per service, tool, or person
├── concepts/          ← cross-cutting ideas (rate-limiting, webhooks, RAG…)
└── sessions/          ← dated summaries of work sessions
```

No deeper nesting — 2 levels max. Use `[[links]]` to express relationships, not folders.

## Page format

Every note carries frontmatter (full spec in [[_schema/template|template]]):

```yaml
---
type: decision | session | entity | concept | architecture | design
date: YYYY-MM-DD
tags: []
links: []
status: draft | accepted | deprecated
source: user | <agent-name> | <external-source>
---
```

Body: `# Title` → `## Context` (why this note exists) → `## Content` (one atomic idea)
→ `## Related` (`[[links]]` with a phrase saying *why* each is related).

## Naming

- Filenames in **kebab-case ASCII**: `rate-limiting.md`, `2026-04-23-auth-choice.md`
- Dated types (`decision`, `session`) get a `YYYY-MM-DD-` prefix
- One canonical page per entity — variants become sections, not new pages
- Full rules: [[_schema/conventions|conventions]]

## Workflow: INGEST (new knowledge arrives)

1. Read the source.
2. Update the relevant page — create it only if none exists.
3. Link every mentioned entity/concept with `[[…]]`; create missing pages in
   `entities/` or `concepts/`.
4. A clear decision goes to `decisions/` **with its rationale and date**.
5. Update `index.md`.
6. On contradiction with an existing page: mark it with a `> [!conflict]` callout
   showing **both** sides — never silently overwrite.
7. Append a line to `log.md`: `## [YYYY-MM-DD] ingest | …`

## Workflow: QUERY (a question arrives)

1. Read `index.md` first; open only the pages it points to.
2. Drop to raw sources only when the wiki cannot answer.
3. Answer with a source reference for every claim.
4. If the answer has lasting value, file it back as an **atomic** page
   (one page = one idea; no "session summary" dumps). Log a `query` line.

## Workflow: LINT (periodic health check)

Check for: contradictions between pages · claims invalidated by newer sources ·
orphan pages (no inbound links) · concepts mentioned but pageless · broken `[[links]]` ·
raw sources with no wiki counterpart.

Report findings in `log.md` with a `lint` line. **Auto-fix only broken links and
missing cross-references.** Content conflicts are reported; a human decides.

## Prohibitions

1. Never write to, move, rename, or delete raw sources — under no circumstances.
2. No claim without a source. Every substantive sentence traces to a file.
3. Never delete a page. Stale pages move to an `archive/` folder; update `index.md`.
4. Never resolve a contradiction by writing one side — show both with `> [!conflict]`.
5. No speculative pages. If no raw source backs it, it doesn't get a page.

## Evolution note

This schema changes. When a rule stops working, update this file and add a `schema`
line to `log.md`. Changes are not applied retroactively — existing pages migrate to
new rules when they are next touched.
