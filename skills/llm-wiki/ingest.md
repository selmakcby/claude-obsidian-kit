# INGEST Protocol

Detailed protocol for absorbing a new source into the vault.

## Input

- **Source type:** transcript | decision | doc | finding
- **Source content:** the actual text to ingest
- **Context:** any metadata about where it came from (user, another agent, file path)

## Steps

### 1. Classify

Read the source. Identify:
- **Primary type** — decision? session? entity? concept?
- **Key facts** — 3-7 bullet points of what's important
- **References** — what other things does it touch?

### 2. Pick the landing spot

Using the routing table in `SKILL.md`, choose the vault folder.

**If ambiguous**, default priority:
1. `decisions/` (if it's a "why" question)
2. `sessions/` (if it's a timeline event)
3. `concepts/` (if it's a reusable pattern)
4. Ask main Claude.

### 3. Generate the filename

- Decisions/sessions: `YYYY-MM-DD-<kebab-slug>.md`
- Concepts/entities: `<kebab-slug>.md`

**Slug rules:**
- Max 5 words
- Describe the content, not the action ("auth-choice" not "decided-auth")
- Lowercase, hyphens only

### 4. Compose the note

Template (always use this):

```markdown
---
type: <type>
date: <YYYY-MM-DD>
tags: [<tag>, <tag>]
links: [[<related>]], [[<related>]]
status: accepted
source: <where this came from>
---

# <Title matching filename>

## Context
<why this note exists, 1-3 sentences>

## Content
<the actual information — atomic, readable>

## Related
- [[<note>]] — <why it's related>
```

### 5. Cross-link

For every `[[link]]` in your note:
- Check the target exists
- If it doesn't exist, create a stub: `<target>.md` with just frontmatter + placeholder
- This prevents broken links

### 6. Update `index.md`

If the new note introduces a top-level concept, add it to `index.md`.

Don't add every decision — only the ones that reshape understanding.

### 7. Log

Append to today's session log (`sessions/YYYY-MM-DD-<slug>.md`):

```markdown
## <HH:MM> — INGEST
- Source: <where>
- Wrote: [[<new-note>]]
- Updated: [[<cross-linked-notes>]]
```

### 8. Return

```markdown
## Ingested
- Wrote: `<path>` (<line-count> lines)
- Updated: `<paths>`
- Cross-linked: `<count>` notes
- Session log updated: `sessions/<today>.md`
```

## Anti-patterns

- **Dumping raw transcripts.** Extract facts, don't copy-paste.
- **Over-categorization.** One note per source, don't fragment into 5.
- **Vague slugs.** "notes-1.md", "thing.md" — useless. Be specific.
- **Unlinked notes.** Every new note must link to at least one existing note.
- **Missing frontmatter.** Non-negotiable. Every note has it.
