# Retrofit — pointing the kit at a folder you already have

`vault-template/` assumes you are starting clean. Almost nobody is.

The realistic situation is a folder with six months in it: transcripts, drafts, half-finished
projects, exports, three README files that contradict each other, and — if you have done this
before — an older vault somewhere inside that already works. This is the guide for that.

It was written by doing it: a 1.9 GB content folder, ~1,000 text files, an existing mature
sub-vault. Numbers from that run are at the bottom.

---

## The two decisions you make before writing anything

### 1. The vault root is the folder you already have. Move nothing.

The tempting move is to build a clean `vault/` and shovel the old material into `raw/`.
Don't — not on the first pass.

Existing folders have load-bearing paths you cannot see from a file listing: video projects
referencing footage by absolute path, `.git` repos, scripts with hardcoded directories, tool
configs. Reorganising is a separate, reversible-only-with-effort job, and it is not the job
that makes the knowledge searchable.

Open Obsidian on the folder itself and add the wiki layer inside it:

```
your-folder/            ← vault root. Obsidian opens HERE.
├── CLAUDE.md           ← the schema ([template](vault-template/CLAUDE.md))
├── index.md            ← catalogue
├── log.md              ← append-only record
├── wiki/               ← the only thing the agent owns
│   ├── projects/  entities/  concepts/  decisions/  syntheses/  archive/
└── (everything you already had, untouched)
```

You get the payoff immediately: because the vault root contains the raw files, a wiki page can
write `[[transcript-2026-04-12]]` and Obsidian resolves it to the actual file. The wiki becomes
a navigation layer over your real material instead of a parallel copy of it.

Physical reorganisation stays on the table. Do it later, deliberately, with the wiki already
telling you what everything is.

For the schema itself, start from [vault-template/CLAUDE.md](vault-template/CLAUDE.md)
([🇹🇷 Türkçe](CLAUDE.tr.md)) — keep the workflows and prohibitions, and adapt the purpose,
folder table and naming to your domain.

### 2. An existing vault inside is canonical and read-only.

If part of your folder is already a working vault, do not regenerate it. Declare it canonical,
link into it, and never write to it.

Two things make this work:

- **A reserved-name list.** Collect every page name in the existing vault and hand it to the
  ingest agents as "link to these, never create them." Without this, parallel agents cheerfully
  write a second `claude-code.md` and you now have two half-truths.
- **One-way linking.** New pages link into the old vault. You do not need to edit the old pages
  to link back — Obsidian's Backlinks pane shows the reverse direction for free. Surgical beats
  thorough here: every edit to a page you did not write is a chance to break something.

```bash
# the reserved list, in one line
find existing-vault -name '*.md' | sed 's|.*/||; s|\.md$||' | sort -u
```

---

## Map the corpus before you ingest it

Do not point one agent at a thousand files. Spend ten minutes producing a map, because the map
determines how you split the work.

```bash
find . -type f \( -name '*.md' -o -name '*.txt' -o -name '*.html' \) \
  | awk -F/ '{print (NF==1 ? "ROOT" : $2)}' | sort | uniq -c | sort -rn
```

Group the result into **domains** — coherent bodies of work, not folders. One project may be
scattered across the root, an `output/` directory and an assets folder; that is still one
domain. Eight to ten domains is a good target. Fewer and each agent drowns; more and they start
overlapping and writing the same entity pages.

---

## The ingest design that does not collide

The obvious approach — N agents in parallel, each writing whatever pages its domain needs —
fails in a specific and annoying way. Two agents both encounter the same tool, both decide it
deserves an entity page, and both write one. You end up with `hermes.md` and `hermes-agent.md`,
each holding half the truth, each citing the same sources.

The fix is to split by *page type*, not just by domain:

```
Phase 1 — domain agents (parallel)
  Each reads its domain and writes ONLY project and decision pages.
  It references [[entities]] and [[concepts]] freely but writes none of them.
  It returns the list of names it referenced.

           ↓  union + dedupe + deterministic split, in code, not by an agent

Phase 2 — node agents (parallel)
  Each gets a disjoint slice of the entity/concept list and writes those pages.
  Zero overlap is guaranteed by construction, not by instruction.

           ↓

Phase 3 — index + lint (parallel)
  One agent writes index.md and log.md from what is actually on disk.
  One runs the audit.
```

Two rules make phase 1 safe:

- Domain agents never touch `index.md` or `log.md`. Concurrent appends to a shared file lose
  writes. One agent owns those, at the end, reading the disk rather than trusting the manifests.
- Every agent returns structured output (pages written, entities referenced, conflicts found,
  open questions). You need this to build phase 2's work list, and it is also the only honest
  input for the log entry.

**Tell the agents what not to read.** A 40-slide HTML deck and a 60-minute transcript will eat
an agent's whole context and give back a summary you could have guessed. "Scan HTML for title
and structure, extract decisions from transcripts, never open binaries" is worth stating
explicitly.

---

## Then check what you missed

Ingest agents skip things. Run a gap pass before you believe the coverage:

```bash
# folders with real weight that the wiki never mentions
for d in */; do
  n=$(find "$d" -type f | wc -l)
  hits=$(grep -rlF "${d%/}" wiki/ 2>/dev/null | wc -l)
  [ "$n" -gt 20 ] && [ "$hits" -lt 2 ] && echo "gap: $d ($n files, $hits mentions)"
done
```

In the reference run this found a 145-file folder nobody had looked at. It also produced a
useful correction: the second-pass agent determined the folder belonged to a *different* project
than the first pass had assumed, by checking file timestamps instead of guessing from the name.

---

## Audit it, with a tool rather than a vibe

```bash
python3 scripts/vault-lint.py . \
  --notes 'wiki/*' --notes 'index.md' --notes 'log.md'
```

`--notes` is the flag that matters here. It restricts *what gets audited* while links still
resolve against the whole vault — otherwise the linter reports every `[[example]]` inside a
tutorial you saved two years ago.

The check worth running first is `bad_sources`: every path a note cites in its `source:`
frontmatter is verified against the disk. A citation to a file that does not exist is either a
fabricated reference or a file that moved — and you want to know which, early, while you still
remember the material.

---

## Ship the Obsidian config with the vault

The skill tells the agent to flag contradictions with `> [!conflict]`. Obsidian does not know
that callout type, so it renders as a plain grey note and every contradiction you carefully
marked becomes invisible. Copy `obsidian/` into your vault's `.obsidian/` — it colours the graph
by layer and gives `[!conflict]` an actual colour. See [obsidian/README.md](obsidian/README.md).

---

## Reference run

One folder, 1.9 GB, ~1,000 text files, six months of material, one existing 74-page vault inside.
Nine domain agents, three node agents, two synthesis agents.

| | |
|---|---|
| Pages produced | 226 |
| Wikilinks | 3,484 (15.4 per page) |
| Broken links | 0 |
| Orphans | 0 |
| Cited source paths that do not exist | 0 of 225 |
| Contradictions flagged for a human | 55 |
| Health score | 100 / 100 |

Two things worth saying plainly about that run:

**The duplicate-entity problem is real.** It produced `hermes`/`hermes-agent` and `fal`/`fal-ai`
before the phase split above existed. Both pairs were good pages describing the same thing. That
failure is what the design is for.

**Fifty-five flagged contradictions is a healthy number, not a bad one.** They are places where
two sources disagree and the agent refused to pick. `vault-lint.py` reports them and does not
subtract from the score, because the alternative — an agent that quietly chooses — scores
perfectly and lies to you.

---

## The part that does not automate

The wiki is a snapshot. It goes stale the moment you add material without saying "ingest this."
In the reference run a parallel session wrote a new article package twenty minutes after the
build finished, and the wiki had no idea it existed.

There is no fix for this in software. Either ingesting becomes a habit, or the vault becomes
an increasingly confident historical document.
