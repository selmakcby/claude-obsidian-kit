# QUERY Protocol

Detailed protocol for answering questions from the vault.

## Input

- **Question:** the actual question text
- **Context:** what part of the project is it about?

## Steps

### 1. Read the map

Open `index.md`. See what top-level concepts exist. This is your orientation.

### 2. Search broad, then narrow

```bash
# Cast a wide net first
Grep "<keyword>" across vault

# Then narrow by folder
Grep "<keyword>" decisions/
Grep "<keyword>" entities/
```

**Rule:** don't read every matching note. Pick the 2-5 most relevant.

### 3. Read selectively

Prefer notes in this order:
1. **Decision notes** — they contain reasoning
2. **Entity notes** — factual references
3. **Concept notes** — patterns
4. **Session notes** — only if question is timeline-specific

### 4. Synthesize

**Don't paste.** Combine. Answer the question in your own words, citing sources.

**Good:**
> *"We chose Supabase auth (decision 2026-04-15) because we were already using Supabase for DB. The tradeoff was losing Auth.js's flexibility, but gaining unified RLS policies ([[supabase]])."*

**Bad:**
> *"Here's decisions/2026-04-15-auth.md: [pastes entire note]"*

### 5. Refile the answer (critical)

**If the answer is useful for future questions**, save it as a new note:

```markdown
---
type: concept
date: <today>
tags: [...]
status: accepted
source: synthesized from QUERY
---

# <Topic>

<the synthesized answer>

## Built from
- [[decisions/2026-04-15-auth]]
- [[entities/supabase]]
```

This way, the next time someone asks a similar question, the synthesized concept note exists already.

### 6. Return

```markdown
## Answer
<synthesized answer>

## Sources consulted
- [[<note-1>]]
- [[<note-2>]]
- [[<note-3>]]

## Refiled as
- [[concepts/<new-synthesized-note>]] — *(only if answer was useful for future)*
```

## Anti-patterns

- **Reading everything.** If you read more than 5 notes, the question is too broad — ask for a narrower scope.
- **Pasting raw.** Always synthesize.
- **Not refiling discoveries.** If you did good synthesis, save it. Otherwise future-you redoes the work.
- **Ignoring the index.** `index.md` exists for a reason. Start there.

## Example trace

**Question:** "Why did we use Stripe webhooks over polling?"

```
1. Read index.md
   → Notices `entities/stripe` and `decisions/` folder

2. Grep "webhook" decisions/
   → Hits: 2026-04-20-webhook-vs-polling.md

3. Grep "polling" entities/
   → Hits: stripe.md

4. Read:
   - decisions/2026-04-20-webhook-vs-polling.md
   - entities/stripe.md
   - concepts/webhook-security.md (linked from decision)

5. Synthesize:
   "We chose webhooks because polling caused delayed subscription state
   updates (up to 60s) and hit Stripe's rate limits at scale. Webhook
   signature verification solves the security concern. See [[stripe]]
   and [[webhook-security]] for details."

6. (Not refiling — the existing decision note covers it well)
```
