# Obsidian config

Optional, but it fixes a real gap: the `llm-wiki` skill instructs the agent to flag
contradictions with `> [!conflict]`, and **Obsidian has no `conflict` callout type**. Without
the snippet below, every contradiction the agent carefully marked renders as an anonymous grey
note. The protocol works and you cannot see it.

## Install

```bash
cp obsidian/graph.json           /path/to/vault/.obsidian/graph.json
cp -r obsidian/snippets          /path/to/vault/.obsidian/
```

Then: **Settings → Appearance → CSS snippets → enable `vault-layers`.**

If Obsidian is already open on that vault, press `Cmd/Ctrl+R` ("Reload app without saving")
before quitting — Obsidian writes its in-memory config on exit and will otherwise overwrite
what you just copied.

## What you get

**`graph.json`** — the graph coloured by layer, so structure is visible at a glance:

| Colour | Layer |
|---|---|
| 🟠 terracotta | `architecture/` |
| 🟡 gold | `decisions/` |
| 🌸 rose | `design/` |
| 🟢 teal | `entities/` |
| 🔵 blue | `concepts/` |
| ⚪ grey | `sessions/` |
| 🟣 violet | `_schema/` |

It also sets sane defaults for a vault of any size: attachments hidden (they drown the graph),
orphans shown (that is the point of looking), arrows on (one-way links become visible),
and label fade tuned so you can still read node names when zoomed out.

**`snippets/vault-layers.css`** — the three callouts the kit uses (`conflict`, `resolved`,
`archived`) plus folder colours in the file explorer, matching the graph palette.

## Adapting it

If your folder names differ, edit the `query` fields in `graph.json` (Obsidian search syntax —
`path:`, `tag:`, `file:`) and the `[data-path^="..."]` selectors in the CSS. The palette is
defined once at the top of the snippet as CSS variables; change it there.
