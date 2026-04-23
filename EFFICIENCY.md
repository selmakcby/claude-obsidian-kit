# Efficiency Patterns

Running multi-agent systems is **easy**. Running them **cost-efficiently** is the actual skill. This doc covers the patterns baked into this kit.

---

## The problem

Naive multi-agent setups burn tokens fast:

- Every agent reloads shared context (CLAUDE.md, rules, skills)
- Expensive models do cheap work (opus formatting a note)
- Agents read far more than they need ("let me read the whole vault first")
- Work gets duplicated (planner plans, builder re-plans, reviewer re-plans)

A 10-decision project can easily cost 10x what it should.

---

## Pattern 1 — Separate thinking from writing

The single biggest token saving.

**Before (expensive):**
```
planner → analyzes + formats + writes note to vault
(opus the whole time — ~3000 tokens in, 1500 tokens out)
```

**After (efficient):**
```
planner → analyzes, returns raw finding (opus, short output)
  ↓
scribe → formats + writes (haiku, tiny prompt + cheap model)

Cost: ~80% less on the writing step.
```

**Baked into this kit:** `scribe` agent. Always delegate writes to it.

---

## Pattern 2 — Model tiering

Match the model to the job. Don't use a supercar to deliver pizza.

| Agent | Model | Why |
|---|---|---|
| planner | **opus** | Deep reasoning, architecture |
| ui-agent | **sonnet** | Balanced, design decisions |
| builder | **sonnet** | Coding quality matters |
| reviewer | **sonnet** | Thorough analysis |
| archivist (QUERY/LINT) | **sonnet** | Synthesis + pattern-matching |
| scribe (writes) | **haiku** | Formatting only, speed matters |

Set in each agent's `model:` frontmatter. Claude Code respects it.

**Rule of thumb:**
- **Thinking** → opus/sonnet
- **Formatting / filing / routing** → haiku
- **Simple checks** → haiku

---

## Pattern 3 — Index-first reads

Never grep the whole vault. Start narrow.

**Bad:**
```
Grep "webhook" ~/vault/ --recursive
→ returns 30 matches across 12 files
→ agent reads all 12 files (~15,000 tokens)
```

**Good:**
```
1. Read vault/index.md (1 file, ~500 tokens)
2. Identify 2-3 likely folders
3. Grep within those folders only
4. Read top 3 matches (~2,500 tokens)
```

**Rule:** if an agent is reading more than 5 notes for a single query, the query is too broad. Ask for narrower scope.

---

## Pattern 4 — Parallel when independent

From Video 1:

```
Independent tasks → parallel (single Task() message with N calls)
Dependent tasks → sequential
```

**Independent examples:**
- Analyzing auth module + analyzing payments module (different code)
- Reviewing for quality + reviewing for security (different lenses, same code)
- QUERYing 3 unrelated topics from vault

**Not independent:**
- Plan → Design → Build (each depends on previous)

Parallelism = wall-clock savings, NOT token savings. But it makes debugging easier (clear separation of concerns).

---

## Pattern 5 — Context handoff discipline

When main Claude passes info between agents, pass **summaries**, not raw context.

**Bad:**
```
Main → ui-agent: "[pastes entire 2000-token plan from planner]"
```

**Good:**
```
Main → ui-agent: "Planner decided: 3-tier pricing with monthly/annual toggle.
                  Stack: Next.js 15, Stripe. Build the component brief."
```

Main Claude is the compressor. Each handoff is a boundary where context should shrink.

---

## Pattern 6 — Least-privilege tools

Each agent has minimum tools. Why this saves tokens:

- Agents with fewer tools have shorter system prompts (tool descriptions are loaded)
- Less chance of wasted tool calls (agent can't wander into unrelated operations)
- Faster decisions (less search space)

Baked into this kit — see each agent's `tools:` line. `scribe` can write but not run bash. `archivist` can't write at all.

---

## Pattern 7 — Batch related operations

**Bad:**
```
Session has 3 decisions to file
→ call scribe 3 times sequentially (3 round-trips)
```

**Good:**
```
Main Claude collects 3 findings
→ calls scribe 3 times IN PARALLEL (1 round-trip)
```

Pattern: collect → batch-call → proceed. Especially valuable for scribe operations.

---

## Pattern 8 — Incremental writes

`index.md` is the vault's most-read file. Don't rewrite it on every INGEST.

**Bad:**
```
scribe rewrites entire index.md every time a note is added
```

**Good:**
```
scribe uses Edit (not Write) to append a single line under the right section
```

Baked into `scribe.md`'s process. Uses `Edit` for updates, `Write` only for new files.

---

## Pattern 9 — Short agent prompts

System prompts get included in EVERY call to that agent. Bloated prompts = token waste at scale.

**Bad (our archivist v1, ~280 lines):**
```
# Archivist — The Vault Guardian
<200 lines of examples, edge cases, philosophy>
```

**Good (archivist v2, ~90 lines):**
```
# Archivist — Reader & Guardian
<minimum instructions, link to detailed protocols>
```

**Rule:** if a rule is applied 1% of the time, link to it in a separate doc instead of inlining.

---

## Pattern 10 — Stateless reads, cached context

Agents don't have persistent memory (that's why we need Obsidian).

But **within a single session**, main Claude's context accumulates. Don't re-ask things you just learned.

**Bad:**
```
T+0: ui-agent reads vault/entities/stripe.md
T+5: builder reads vault/entities/stripe.md again (main Claude already has it!)
```

**Good:**
```
T+0: ui-agent reads vault/entities/stripe.md
      returns brief mentioning Stripe capabilities
T+5: builder receives brief including stripe info
      doesn't need to re-read stripe.md
```

Main Claude is your session-level cache. Use it.

---

## Measuring

Token costs vary by model. Rough guide per operation:

| Operation | Agent | Model | Input | Output | Cost estimate |
|---|---|---|---|---|---|
| Plan a feature | planner | opus | 1.5k | 1k | ~$0.08 |
| Design UI | ui-agent | sonnet | 2k | 800 | ~$0.02 |
| Build feature | builder | sonnet | 3k | 2k | ~$0.04 |
| Review code | reviewer | sonnet | 4k | 1k | ~$0.03 |
| QUERY vault | archivist | sonnet | 2k | 500 | ~$0.01 |
| File note | scribe | haiku | 500 | 400 | ~$0.0005 |
| LINT vault | archivist | sonnet | 5k | 1k | ~$0.03 |

**A full feature (plan + design + build + review + 2 files):** ~$0.18

**Same flow running opus everywhere (naive):** ~$0.90

**5× cost savings** by just picking the right models.

---

## TL;DR

1. **Scribe for writes** — cheap haiku, focused prompt
2. **Archivist for reads** — sonnet, index-first
3. **Opus where reasoning matters** — planner only
4. **Parallel independent calls** — save wall clock
5. **Summaries across boundaries** — main Claude compresses
6. **Least privilege** — agents get minimum tools
7. **Short system prompts** — link out to details

Apply these and a project that would cost $20/month in tokens costs $3.
