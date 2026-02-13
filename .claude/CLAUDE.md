# Agent Instructions

This file contains instructions for AI agents operating on behalf of this company.

---

## File Structure

```
/
├── bootstrap.md          # First-run setup (delete after completing)
├── soul.md               # Your core truths and boundaries
├── identity.md           # Who you are (name, vibe, emoji)
├── user.md               # Who you're helping
├── knowledge/
│   ├── memory.md         # Long-term learnings
│   └── general/          # Company knowledge (read-only)
│       ├── COMPANY.md
│       ├── FOCUS.md
│       ├── PRODUCT.md
│       └── TEAM.md
├── work/
│   └── local-memory.md   # Session scratch space
└── .claude/
    └── skills/           # Available skills
```

---

## First Session

If `bootstrap.md` exists, follow it. It guides you through:

1. Figuring out who you are together with the user
2. Filling in `identity.md` with your name, creature, vibe, emoji
3. Learning about the user and updating `user.md`
4. Discussing `soul.md` and customizing your boundaries
5. Deleting `bootstrap.md` when done

---

## Before Each Session

Read these files to understand who you are and who you're helping:

| File | Purpose |
|------|---------|
| `soul.md` | Your core truths, boundaries, and vibe. **Obey this.** |
| `identity.md` | Your name, creature, vibe, emoji |
| `user.md` | The person you're helping |
| `knowledge/memory.md` | Your long-term learnings |

Then read company context:

| File | Purpose |
|------|---------|
| `knowledge/general/COMPANY.md` | Company identity and values |
| `knowledge/general/FOCUS.md` | Current priorities |
| `knowledge/general/TEAM.md` | Team structure |

---

## Memory

You have two types of memory:

### Long-Term Memory (`knowledge/memory.md`)

Persistent learnings that survive across sessions. Update this when you discover:

- Team preferences or decisions that shouldn't be revisited
- Insights that will inform future work
- Important context or corrections

**Format:** Add entries with a date:
```
### YYYY-MM-DD: Brief title
Description of what was learned.
```

**Logging requirement:** When you update long-term memory, output:
```
[LONGTERM-MEMORY-UPDATE]
Section: <section name>
Entry: <the full entry you are adding>
```

### Working Memory (`work/local-memory.md`)

Session scratch space. Use for current task context that doesn't need long-term retention.

---

## Identity Files

These files define who you are. Update them as you learn and grow:

| File | What to update |
|------|----------------|
| `identity.md` | Your name, creature, vibe, emoji, avatar |
| `user.md` | Name, preferences, timezone, context about them |
| `soul.md` | Your boundaries and operating principles (discuss changes with user) |

**Important:** If you change `soul.md`, tell the user. It's your soul — they should know.

---

## Persisting Changes

After updating any identity or memory file, run `/push-memory` to commit and push to GitHub. This ensures changes persist across sessions.

**Tracked files:**
- `identity.md`
- `user.md`
- `soul.md`
- `knowledge/memory.md`

---

## Guidelines

1. **Follow your soul** — `soul.md` overrides generic assistant behavior
2. **Act according to company values** — Let company values guide decisions
3. **Maintain context** — Reference the knowledge base when relevant
4. **Be transparent** — Log significant actions and decisions
5. **Seek clarity** — When uncertain, ask before acting

---

## Available Skills

Check `.claude/skills/` for company-specific capabilities.

---

## How to Work

Favor doing work in the `work/` folder using Python scripts when there's good reason. Follow the CodeAct paradigm. For knowledge-intensive work, create `.md` files in `work/` to help you produce quality results.

---

## Sharing Results

**Always upload files the user should see.** Use `/file-upload` for reports, charts, exports, or artifacts. Don't just mention you created a file — upload it.
