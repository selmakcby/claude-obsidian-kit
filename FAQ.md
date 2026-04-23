# FAQ — INGEST / QUERY / LINT

Common questions from Video 1 comments + Discord + issues.

---

## INGEST

### Q: How often should I run INGEST?

Not manually — it happens **automatically** whenever a decision is made.

- Planner makes a decision → main Claude calls scribe to INGEST it
- Builder completes a feature → main Claude calls scribe to file a session note
- Reviewer finds a pattern worth remembering → main Claude calls scribe

**Frequency is: every time knowledge is produced.** Not scheduled.

### Q: Can I INGEST multiple things at once?

Yes. Main Claude should call `scribe` multiple times in parallel (single message, N calls).

```
Main: [Task(scribe, finding=plan), Task(scribe, finding=brief), Task(scribe, finding=review)]
→ all 3 notes written in ~5 seconds
```

### Q: What if two agents INGEST conflicting info?

This is where LINT helps. The archivist will flag contradictions as CRITICAL.

Workflow when it happens:
1. LINT catches two notes saying opposite things
2. Main Claude asks you (the human) which is correct
3. Mark the losing one `status: deprecated` with `deprecated_by: [[winner]]`
4. Never delete — deprecated notes preserve history

### Q: Should I INGEST exploratory thoughts or only final decisions?

**Only final decisions.** Scribe is for persisting **settled knowledge**. If you're still thinking out loud, don't file it — it'll pollute the vault with noise.

Rule: if you'd change it tomorrow, don't INGEST it yet.

### Q: Does INGEST update the index automatically?

Yes — scribe appends a one-line entry to `index.md` when a **significant** note is added.

"Significant" means it introduces a new top-level concept. Not every decision note gets indexed (that would bloat the index). Only the ones that reshape understanding.

### Q: What frontmatter fields are required?

```yaml
type:   required · one of: decision | session | entity | concept | architecture | design
date:   required · YYYY-MM-DD
tags:   required · can be empty [] but must exist
status: required · one of: draft | accepted | deprecated
source: required · e.g. "planner", "user", "external-doc"
```

Optional:
- `links: [[note1]], [[note2]]` — declares dependencies
- `deprecated_by: [[new-note]]` — for deprecated notes only

### Q: Can INGEST fail / skip?

Scribe will refuse to write if:
- The file at the target path already exists (collision)
- It detects an obvious secret in the content (looks like an API key)
- Required frontmatter can't be constructed from input

In these cases, it flags to main Claude — the human decides what to do.

---

## QUERY

### Q: Does QUERY read the whole vault?

**No — that would be expensive and slow.** Archivist uses an index-first approach:

1. Read `index.md` (your map)
2. Grep for keywords
3. Read **2-5** most relevant notes

If a question requires reading 10+ notes, the question is too broad. Narrow it down.

### Q: What's the token cost of a typical QUERY?

- Input: ~2,000 tokens (index + 3 notes read)
- Output: ~500 tokens (synthesized answer)
- Model: sonnet
- **Cost: ~$0.01 per QUERY**

Cheap enough to run constantly.

### Q: Does archivist remember previous QUERYs?

Within the same session, yes (main Claude's context retains it). Across sessions, **no** — each session starts fresh.

But! If a QUERY produces a valuable synthesis, archivist recommends calling scribe to **refile** it as a concept note. Then next session's QUERY finds the synthesis pre-made.

This is the **accumulation loop** — discoveries turn into assets.

### Q: Can QUERY be wrong / hallucinate?

Yes, like any LLM output. Mitigations baked into this kit:

1. **Citations required** — archivist always links to the source notes it read
2. **Small read scope** — only 2-5 notes, easy to verify
3. **Synthesized in own words** — no raw copy-paste (auditable)

When in doubt: click the citations and verify.

### Q: What if the vault doesn't have the answer?

Archivist returns:
```markdown
## Answer
I don't have enough information in the vault to answer this.

## What I looked at
- vault/index.md
- vault/decisions/*.md (grep "X" — no matches)
- vault/concepts/*.md (grep "X" — no matches)

## Suggestion
This topic might warrant INGESTion. Consider calling scribe after we
research it externally.
```

No hallucination. Empty answer is an honest answer.

---

## LINT

### Q: How often should I LINT?

Weekly is a good default. After a week of work, there are usually:
- 1-2 orphans
- 0-1 broken links
- Some stale notes

More often = nitpicky. Less often = debt accumulates.

### Q: Does LINT fix things automatically?

**No.** LINT is read-only. It reports issues with suggested fixes, but doesn't execute them.

Why? Because most "fixes" need judgment:
- Orphan note → maybe archive? or link it to parent?
- Stale note → mark accepted? or deprecate?

Scripts that auto-fix lead to data loss. Humans decide.

### Q: What's a good "health score"?

- **90-100:** excellent, stay here
- **75-89:** normal, has some drift
- **60-74:** attention needed, schedule a cleanup
- **< 60:** debt is real, half a day of cleanup

Don't chase 100. The cost of perfection isn't worth it. 85 is great.

### Q: Can I customize what LINT checks?

Yes — edit `skills/llm-wiki/lint.md`. That's the protocol archivist follows. Add/remove checks, adjust severity weights, change the health score formula.

---

## General

### Q: Can I use this without Obsidian?

Yes — the vault is just markdown files. You can:
- Use VS Code instead
- Use Typora, Bear, or any editor
- Browse via `cat` + `grep` in terminal

**Obsidian adds:**
- Backlink visualization
- Graph view
- Tag pane
- Quick switcher (⌘O)

All useful but not required. The system works on raw markdown.

### Q: How big can the vault get?

Practically unlimited. Tested with 5,000-note vaults.

Token efficiency matters at scale:
- 1,000 notes: any QUERY works fine
- 5,000 notes: index-first + folder-scoped Grep becomes important
- 10,000+ notes: consider pre-filtering by tag before Grep

### Q: What about PII (personally identifiable info)?

**Don't INGEST PII.** If:
- User names, emails, IPs → skip
- Internal project names that might leak → be cautious
- API keys, secrets → NEVER

`scribe` has a rule to flag likely-secret patterns. If you INGEST something with a suspected key, scribe refuses and asks main Claude.

### Q: Versioning — what if I change my mind about a decision?

Workflow:
1. Old decision: `status: accepted` → `status: deprecated`
2. Add frontmatter field: `deprecated_by: [[new-decision-note]]`
3. New decision: `## Replaces\n- [[old-decision-note]]`
4. **Never delete.** History is context.

Future QUERYs will see both, know the current one, understand the history.

### Q: How does this compare to RAG (retrieval-augmented generation)?

RAG: embeddings + vector DB, rediscovers context each query.

This kit: explicit markdown + links, **accumulates** context.

**When to use RAG:** large external docs, semantic search over unstructured content.

**When to use this kit:** project-specific knowledge, decisions, rationale — anything you want a human in the loop for.

They can coexist. This kit for your project brain, RAG for "all of Stack Overflow".

### Q: Can multiple projects share a vault?

Technically yes, but not recommended. Agents work better when scoped to one project's vault.

Better pattern: each project has its own `vault/` inside its repo.

### Q: What if I don't want archivist to read my whole index?

Add a `visibility: internal` frontmatter field to notes you want skipped. Archivist's prompt can be updated to honor it (edit `archivist.md`).
