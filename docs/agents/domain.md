# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

**Layout: single-context.** One `CONTEXT.md` and one `docs/adr/` at the repo root.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root, or
- **`CONTEXT-MAP.md`** at the repo root if it exists — it points at one `CONTEXT.md` per context. Read each one relevant to the topic.
- **`docs/adr/`** — read ADRs that touch the area you're about to work in.

Both exist in this repo: `CONTEXT.md` at the root is the glossary, and `docs/adr/` holds the decision records.
`docs/DECISIONS.md` was retired in favour of `docs/adr/`; its two entries are now ADR 0001 and 0002. Don't recreate
it, and don't add decisions to it.

A new decision that meets the bar (hard to reverse, surprising without context, the result of a real trade-off)
gets its own numbered ADR. A settled term goes in `CONTEXT.md`, not in an ADR.

## File structure

Single-context repo (most repos):

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

Multi-context repo (presence of `CONTEXT-MAP.md` at the root):

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← system-wide decisions
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← context-specific decisions
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids.

`CONTEXT.md` is the authority, and `AGENTS.md` points at it rather than repeating it. The distinctions that get
broken most often: **assembling** (Terraform) vs **provisioning** (Ansible) vs **deployment** (Capistrano, from the
app's own repo); **stage** (production or staging) vs **environment** (blue or green); **service** (a unit this repo
manages) vs **OAF collection** (one of the five public-facing offerings). Bare "collection" is never used here.

If the concept you need isn't in the glossary yet, that's a signal — either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_
