---
type: architecture
date: 2026-04-23
tags: [schema, conventions]
links: []
status: accepted
source: vault-template
---

# Vault Conventions

The rulebook. Every note follows these — agents AND humans.

---

## Frontmatter (required)

Every note has YAML frontmatter at the top:

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

**Types defined:**
- `decision` — "why we chose X over Y" (dated)
- `session` — summary of a work session (dated)
- `entity` — a service, tool, or person (vercel, stripe, supabase)
- `concept` — cross-cutting idea (rate-limiting, webhooks, RAG)
- `architecture` — system design doc
- `design` — UI/UX design decision

**Status transitions:**
```
draft → accepted → (optionally) deprecated
```

Never delete. Deprecated notes stay for history.

---

## Filenames

| Type | Format | Example |
|---|---|---|
| decision | `YYYY-MM-DD-<kebab-slug>.md` | `2026-04-23-use-stripe-webhooks.md` |
| session | `YYYY-MM-DD-<kebab-slug>.md` | `2026-04-23-pricing-build.md` |
| entity | `<kebab-name>.md` | `stripe.md`, `supabase.md` |
| concept | `<kebab-topic>.md` | `rate-limiting.md`, `webhook-security.md` |
| architecture | `<kebab-topic>.md` | `overview.md`, `deploy-flow.md` |
| design | `<feature>-components.md` | `pricing-components.md` |

**Slug rules:**
- Max 5 words
- Kebab-case (`rate-limiting`, not `rateLimiting` or `rate_limiting`)
- Describe content, not action
  - ✅ `auth-choice`
  - ❌ `decided-auth`
  - ❌ `notes-about-auth`

---

## Folder structure

```
vault/
├── index.md
├── _schema/
│   ├── template.md
│   └── conventions.md (this file)
├── architecture/
├── decisions/
├── design/
├── entities/
├── concepts/
└── sessions/
```

**No deeper nesting.** 2 levels max. Use links instead of folders to express relationships.

---

## Links

- Use `[[shortest-path]]` — Obsidian resolves automatically.
- ✅ `[[stripe]]`
- ❌ `[[entities/stripe]]`
- ❌ `[[entities/stripe.md]]`

- **Every note links to at least 2 others.** Isolation = orphan = bad.
- **Bidirectional by default.** `[[stripe]]` in decision auto-creates backlink in stripe note.

---

## Tags

- 2-5 tags per note
- Use existing tags before creating new ones (check `#tag` view in Obsidian)
- Lowercase, kebab-case: `#payments`, `#auth`, `#security`
- Tags are for **discovery**, links are for **structure**. Don't over-tag.

---

## Writing style

- **Atomic notes.** One idea per note. 200-400 lines ideal, 800 max.
- **Human-readable markdown.** Not dense summaries, not JSON. Write for future-you.
- **Context first.** Every note starts with "why this exists" (in ## Context section).
- **Code blocks for code.** Always fence with language: ` ```typescript `
- **No mystery meat.** Don't reference things without linking them: `[[that-concept]]`, not "that concept we talked about".

---

## Deprecation

When a decision is reversed:

1. Old note: change `status: accepted` → `status: deprecated`
2. Add `deprecated_by: [[new-decision-note]]` to frontmatter
3. Add a note at top: `> **Deprecated** — see [[new-decision-note]]`
4. Never delete.

New note references the old one: `## Replaces [[old-decision-note]]`

---

## Examples

See `_schema/` folder for template + this conventions doc.

See `entities/example-service.md` (if exists) for a real-shape example.

---

## When in doubt

- Ask the `archivist` agent — it knows these conventions
- Default to simpler folder, fewer tags, more links
- Human-readability wins ties
