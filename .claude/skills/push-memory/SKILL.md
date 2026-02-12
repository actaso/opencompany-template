---
name: push-memory
description: Commit and push long-term memory updates to GitHub. Use after updating knowledge/memory.md to persist learnings across agent sessions.
disable-model-invocation: false
allowed-tools: Bash(bash *)
---

# Push Memory

> Persist long-term memory updates to the remote repository

This skill commits and pushes changes to `knowledge/memory.md` to GitHub, ensuring learnings persist across agent sessions.

## When to Use

Run `/push-memory` after adding entries to your long-term memory (`knowledge/memory.md`). This ensures:

- Memory updates survive session restarts
- Other agents can access your learnings
- There's a permanent record of what was learned

## Usage

After logging a `[LONGTERM-MEMORY-UPDATE]`, run:

```bash
bash .claude/skills/push-memory/scripts/push_memory.sh
```

Or simply invoke `/push-memory`.

## What It Does

1. **Verifies environment** - Ensures we're in a git repository with a memory file
2. **Fetches latest** - Pulls any remote changes to avoid conflicts
3. **Stages memory file** - Only stages `knowledge/memory.md` (nothing else)
4. **Generates commit message** - Extracts new entry titles from the diff
5. **Commits and pushes** - Uses the OpenCompany Bot identity

## Commit Format

```
chore(memory): update long-term memory

- 2026-02-12: Entry title 1
- 2026-02-12: Entry title 2

Auto-committed by OpenCompany Bot
```

The commit author is: `OpenCompany Bot <bot@opencompany.cloud>`

## Error Handling

### No Changes
If `knowledge/memory.md` hasn't been modified, the script exits gracefully:
```
[INFO] No changes to knowledge/memory.md - nothing to push.
```

### Not in Git Repository
```
[ERROR] Not inside a git repository.
```
**Solution:** Ensure you're running from within the company template repository.

### Memory File Not Found
```
[ERROR] Memory file not found: knowledge/memory.md
```
**Solution:** Create the memory file or check you're in the correct repository.

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
- Only `knowledge/memory.md` is ever staged or committed
- Git identity is set per-operation to avoid polluting global config

## Example Workflow

```bash
# 1. Update memory with a new learning
echo "### 2026-02-12: User prefers concise responses

The team confirmed they want responses under 200 words when possible." >> knowledge/memory.md

# 2. Push the memory update
bash .claude/skills/push-memory/scripts/push_memory.sh

# Output:
# [INFO] Preparing to push memory updates on branch: main
# [INFO] Fetching latest changes...
# [INFO] Rebasing on latest changes...
# [INFO] Committing memory updates...
# [INFO] Pushing to origin/main...
# [INFO] Memory updates pushed successfully!
# [INFO] Commit: abc1234
```
