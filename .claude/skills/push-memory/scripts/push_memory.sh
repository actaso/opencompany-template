#!/bin/bash
#
# push_memory.sh - Commit and push memory and identity updates to GitHub
#
# This script commits changes to memory and identity files and pushes them to
# the remote repository. It's designed to be run by Claude agents to persist
# learnings and identity across sessions.
#

set -e

# Files that this script manages
TRACKED_FILES=(
    "knowledge/memory.md"
    "identity.md"
    "user.md"
    "soul.md"
)

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

# Find which tracked files have changes
CHANGED_FILES=()
for file in "${TRACKED_FILES[@]}"; do
    if [ -f "$file" ]; then
        # Check for unstaged or staged changes
        if ! git diff --quiet "$file" 2>/dev/null || ! git diff --cached --quiet "$file" 2>/dev/null; then
            CHANGED_FILES+=("$file")
        fi
    fi
done

# Exit if no changes
if [ ${#CHANGED_FILES[@]} -eq 0 ]; then
    log_info "No changes to tracked files - nothing to push."
    log_info "Tracked files: ${TRACKED_FILES[*]}"
    exit 0
fi

log_info "Found changes in: ${CHANGED_FILES[*]}"

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
    log_error "Not on a branch (detached HEAD state)."
    log_error "Please checkout a branch before pushing updates."
    exit 1
fi

log_info "Preparing to push updates on branch: $CURRENT_BRANCH"

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
        log_error "  2. Resolve any conflicts"
        log_error "  3. Run this script again"
        exit 1
    fi
fi

# Stage only the changed tracked files
for file in "${CHANGED_FILES[@]}"; do
    git add "$file"
done

# Check if there's actually something to commit after staging
if git diff --cached --quiet 2>/dev/null; then
    log_info "No staged changes after rebase - nothing to commit."
    exit 0
fi

# Determine what type of changes we have for the commit message
HAS_MEMORY=false
HAS_IDENTITY=false
HAS_USER=false
HAS_SOUL=false

for file in "${CHANGED_FILES[@]}"; do
    case "$file" in
        "knowledge/memory.md") HAS_MEMORY=true ;;
        "identity.md") HAS_IDENTITY=true ;;
        "user.md") HAS_USER=true ;;
        "soul.md") HAS_SOUL=true ;;
    esac
done

# Generate commit message based on what changed
COMMIT_TYPES=()
$HAS_MEMORY && COMMIT_TYPES+=("memory")
$HAS_IDENTITY && COMMIT_TYPES+=("identity")
$HAS_USER && COMMIT_TYPES+=("user")
$HAS_SOUL && COMMIT_TYPES+=("soul")

COMMIT_SCOPE=$(IFS=','; echo "${COMMIT_TYPES[*]}")
COMMIT_MSG="chore($COMMIT_SCOPE): update agent files"

# Extract new memory entries from diff if memory changed
if $HAS_MEMORY; then
    NEW_ENTRIES=$(git diff --cached "knowledge/memory.md" | grep "^+" | grep -E "^\\+### [0-9]{4}-[0-9]{2}-[0-9]{2}:" | sed 's/^+### /- /' || true)
    if [ -n "$NEW_ENTRIES" ]; then
        COMMIT_MSG="$COMMIT_MSG

Memory entries:
$NEW_ENTRIES"
    fi
fi

COMMIT_MSG="$COMMIT_MSG

Files updated: ${CHANGED_FILES[*]}
Auto-committed by OpenCompany Bot"

# Commit
log_info "Committing updates..."
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

log_info "Updates pushed successfully!"
log_info "Commit: $(git rev-parse --short HEAD)"
