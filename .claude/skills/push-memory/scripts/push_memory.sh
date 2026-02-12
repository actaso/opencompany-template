#!/bin/bash
#
# push_memory.sh - Commit and push long-term memory updates to GitHub
#
# This script commits changes to knowledge/memory.md and pushes them to the
# remote repository. It's designed to be run by Claude agents to persist
# learnings across sessions.
#

set -e

MEMORY_FILE="knowledge/memory.md"
BOT_NAME="OpenCompany Bot"
BOT_EMAIL="bot@opencompany.cloud"

# Colors for output (disabled if not in terminal)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    log_error "Not inside a git repository."
    log_error "This script must be run from within the company template repository."
    exit 1
fi

# Navigate to repository root
cd "$(git rev-parse --show-toplevel)"

# Check if memory file exists
if [ ! -f "$MEMORY_FILE" ]; then
    log_error "Memory file not found: $MEMORY_FILE"
    log_error "Create the memory file first or check you're in the correct repository."
    exit 1
fi

# Check for uncommitted changes to memory file
if ! git diff --quiet "$MEMORY_FILE" 2>/dev/null && ! git diff --cached --quiet "$MEMORY_FILE" 2>/dev/null; then
    : # Has changes, continue
elif git diff --quiet "$MEMORY_FILE" 2>/dev/null && git diff --cached --quiet "$MEMORY_FILE" 2>/dev/null; then
    log_info "No changes to $MEMORY_FILE - nothing to push."
    log_info "Memory is already up to date with the repository."
    exit 0
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
    log_error "Not on a branch (detached HEAD state)."
    log_error "Please checkout a branch before pushing memory updates."
    exit 1
fi

log_info "Preparing to push memory updates on branch: $CURRENT_BRANCH"

# Configure git identity for this operation
git config user.name "$BOT_NAME"
git config user.email "$BOT_EMAIL"

# Fetch latest changes (suppress output to avoid token exposure)
log_info "Fetching latest changes..."
if ! git fetch origin "$CURRENT_BRANCH" 2>&1 | grep -v -E "(https?://[^@]*@|token|credential)"; then
    log_warn "Could not fetch from remote. Proceeding with local commit."
fi

# Try to rebase on latest changes
if git rev-parse "origin/$CURRENT_BRANCH" &>/dev/null; then
    log_info "Rebasing on latest changes..."
    if ! git rebase "origin/$CURRENT_BRANCH" 2>&1 | grep -v -E "(https?://[^@]*@|token|credential)"; then
        log_error "Rebase failed due to conflicts."
        log_error "Aborting rebase..."
        git rebase --abort 2>/dev/null || true
        log_error "Please resolve conflicts manually:"
        log_error "  1. Pull the latest changes: git pull --rebase origin $CURRENT_BRANCH"
        log_error "  2. Resolve any conflicts in $MEMORY_FILE"
        log_error "  3. Run this script again"
        exit 1
    fi
fi

# Extract new entries from diff for commit message
# Look for lines starting with "### YYYY-MM-DD:" pattern
NEW_ENTRIES=$(git diff "$MEMORY_FILE" | grep "^+" | grep -E "^\\+### [0-9]{4}-[0-9]{2}-[0-9]{2}:" | sed 's/^+### /- /' || true)

# Stage only the memory file
git add "$MEMORY_FILE"

# Check if there's actually something to commit after staging
if git diff --cached --quiet "$MEMORY_FILE" 2>/dev/null; then
    log_info "No staged changes to $MEMORY_FILE - nothing to commit."
    exit 0
fi

# Generate commit message
COMMIT_MSG="chore(memory): update long-term memory"

if [ -n "$NEW_ENTRIES" ]; then
    COMMIT_MSG="$COMMIT_MSG

$NEW_ENTRIES"
fi

COMMIT_MSG="$COMMIT_MSG

Auto-committed by OpenCompany Bot"

# Commit
log_info "Committing memory updates..."
git commit -m "$COMMIT_MSG"

# Push (suppress output to avoid token exposure)
log_info "Pushing to origin/$CURRENT_BRANCH..."
if ! git push origin "$CURRENT_BRANCH" 2>&1 | grep -v -E "(https?://[^@]*@|token|credential|password)"; then
    log_error "Push failed."
    log_error "Possible causes:"
    log_error "  - GitHub token may have expired or lacks push permissions"
    log_error "  - Network connectivity issues"
    log_error "  - Branch protection rules preventing direct pushes"
    log_error ""
    log_error "The commit was created locally. You can try pushing manually later."
    exit 1
fi

log_info "Memory updates pushed successfully!"
log_info "Commit: $(git rev-parse --short HEAD)"
