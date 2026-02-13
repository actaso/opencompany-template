---
name: push-memory
description: Commit and push memory and identity updates to GitHub. Use after updating identity.md, user.md, soul.md, or knowledge/memory.md to persist changes across sessions.
disable-model-invocation: false
allowed-tools: Bash(bash *)
---

# Push Memory

> Persist memory and identity updates to the remote repository

This skill commits and pushes changes to your identity and memory files to GitHub, ensuring they persist across sessions.

## Tracked Files

This skill manages these files:

| File | Purpose |
|------|---------|
| `identity.md` | Your name, creature, vibe, emoji |
| `user.md` | Information about the person you're helping |
| `soul.md` | Your core truths, boundaries, and vibe |
| `knowledge/memory.md` | Long-term learnings and context |

## When to Use

Run `/push-memory` after updating any of the tracked files. This ensures:

- Changes survive session restarts
- Other agents can access your identity and learnings
- There's a permanent record of who you are and what you've learned

## Usage

After making updates to any tracked file, run:

```bash
bash .claude/skills/push-memory/scripts/push_memory.sh
```

Or simply invoke `/push-memory`.

## What It Does

1. **Finds changes** - Checks which tracked files have been modified
2. **Fetches latest** - Pulls any remote changes to avoid conflicts
3. **Stages files** - Only stages the tracked files (nothing else)
4. **Generates commit message** - Creates a descriptive message based on what changed
5. **Commits and pushes** - Uses the OpenCompany Bot identity

## Commit Format

```
chore(identity,memory): update agent files

Memory entries:
- 2026-02-12: Entry title 1
- 2026-02-12: Entry title 2

Files updated: identity.md knowledge/memory.md
Auto-committed by OpenCompany Bot
```

The commit author is: `OpenCompany Bot <bot@opencompany.cloud>`

## Error Handling

### No Changes
If no tracked files have been modified:
```
[INFO] No changes to tracked files - nothing to push.
[INFO] Tracked files: knowledge/memory.md identity.md user.md soul.md
```

### Not in Git Repository
```
[ERROR] Not inside a git repository.
```
**Solution:** Ensure you're running from within the company template repository.

### Merge Conflicts
```
[ERROR] Rebase failed due to conflicts.
```
**Solution:** The script aborts the rebase automatically. Follow the instructions to resolve conflicts manually.

### Push Failed
```
[ERROR] Push failed.
```
**Possible causes:**
- GitHub token expired or lacks push permissions
- Network connectivity issues
- Branch protection rules

The local commit is preserved. You can retry pushing later.

## Security Notes

- The script filters output to avoid exposing GitHub tokens
- Only tracked files are ever staged or committed
- Git identity is set per-operation to avoid polluting global config
