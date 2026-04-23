# LINT Protocol

Detailed protocol for vault health check.

## When to run

- Periodic (weekly recommended)
- On-demand when user asks "is my vault healthy?"
- Before major refactors (to identify debt)

## Checks

### 1. Orphan notes

Notes with **zero incoming links** — disconnected from the graph.

```bash
# For each note, check if any other note links to it
for note in vault/**/*.md; do
  name=$(basename "$note" .md)
  if ! Grep "\[\[$name\]\]" vault/; then
    echo "ORPHAN: $note"
  fi
done
```

**Severity:** MEDIUM. Orphans might be legit (just-added notes) or dead (forgotten).

**Suggestion:** link from a parent concept, or archive.

### 2. Broken links

`[[link-text]]` where the target file doesn't exist.

```bash
# Extract all [[links]], check each target exists
Grep -oP '\[\[[^\]]+\]\]' vault/**/*.md
# For each match, verify file exists
```

**Severity:** HIGH. Broken links = users click, get nothing.

**Suggestion:** create the stub note, or fix the link text.

### 3. Stale notes

Notes where frontmatter `date` is > 90 days and `status` is still `draft` or never updated.

```bash
# Find notes with old dates in frontmatter
for note in vault/**/*.md; do
  date_field=$(grep -m 1 "^date:" "$note" | sed 's/date://')
  # Compare with today - 90 days
done
```

**Severity:** LOW. Not a bug, but often signals forgotten work.

**Suggestion:** review. Either mark `status: accepted` (finalized) or `status: deprecated` (abandoned) or update.

### 4. Missing concept pages

`[[concept-name]]` referenced in multiple notes but no `concepts/concept-name.md` exists.

```bash
# Find links referenced ≥3 times
Grep -oPh '\[\[[^\]]+\]\]' vault/**/*.md | sort | uniq -c | sort -rn
# Filter: count ≥3, file doesn't exist
```

**Severity:** MEDIUM. Referenced concept should have its own page.

**Suggestion:** create `concepts/<name>.md` — archivist can INGEST one based on existing references.

### 5. Contradictions

Two notes with contradicting claims on the same topic.

This is HARD to automate. Heuristic:
- Find notes with overlapping tags
- Read them, look for "not", "instead", "replaced" patterns
- Flag likely contradictions for human review

**Severity:** CRITICAL. Contradictions poison QUERY results.

**Suggestion:** resolve by marking older one `status: deprecated` and updating the newer one to explicitly `[[replaces]]` it.

### 6. Frontmatter violations

Notes missing required frontmatter fields.

```bash
# Every note must have: type, date, status
for note in vault/**/*.md; do
  if ! head -10 "$note" | grep -q "^type:"; then
    echo "MISSING type: $note"
  fi
done
```

**Severity:** MEDIUM. Breaks tooling + QUERY.

**Suggestion:** fix frontmatter.

---

## Report format

```markdown
# Vault Health Report — YYYY-MM-DD

**Total notes:** <count>
**Total links:** <count>
**Health score:** <0-100> (based on defect ratio)

## CRITICAL
<contradictions, if any>

## HIGH
### Broken links (N)
- `<from-file>` → `[[<broken-target>]]`
  - *Suggestion: <fix>*

## MEDIUM
### Orphan notes (N)
- `<path>` — no incoming links
  - *Suggestion: link from <parent> or archive*

### Missing concept pages (N)
- `[[<concept-name>]]` — referenced <count> times, no page
  - *Suggestion: INGEST a concept page synthesizing existing references*

## LOW
### Stale notes (N)
- `<path>` — last updated <date>, status still draft
  - *Suggestion: mark accepted, deprecate, or update*

## Suggestions for next session
- <proactive suggestions from archivist>
```

---

## Health score calculation

```
score = 100
  - (broken_links × 10)
  - (orphans × 3)
  - (stale × 1)
  - (missing_concepts × 5)
  - (contradictions × 20)
  - (frontmatter_violations × 5)

min: 0, max: 100
```

| Score | Status |
|---|---|
| 90-100 | ✅ Healthy |
| 70-89 | ⚠️ Minor debt |
| 50-69 | ⚠️ Needs attention |
| < 50 | 🚨 Cleanup overdue |

---

## Anti-patterns

- **Ignoring the report.** LINT without fixing = useless. Schedule time to address findings.
- **Perfectionism.** Score doesn't need to be 100. Aim for 85+.
- **Deleting orphans blindly.** Some orphans are legit — recent notes, private references. Review, don't auto-delete.
