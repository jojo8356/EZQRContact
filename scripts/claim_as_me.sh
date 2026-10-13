#!/usr/bin/env bash
# Rewrite commits that exist only on this branch so they are yours:
#   - author + committer = git user.name / user.email
#   - drop "Co-authored-by: arena-agent ..." trailers
#
# Does not rewrite origin/main. You must force-push the feature branch
# afterwards. Merging to main is optional and explicit.
#
# Usage (clean working tree, on the feature branch):
#   ./scripts/claim_as_me.sh
#   ./scripts/claim_as_me.sh --push
#   ./scripts/claim_as_me.sh --push --merge-main
#
# Identity (first match wins):
#   CLAIM_NAME / CLAIM_EMAIL env
#   git config user.name / user.email
#   jojo8356 / polsinelli@gmx.com

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PUSH=0
MERGE_MAIN=0
for arg in "$@"; do
  if [ "$arg" = "--push" ]; then
    PUSH=1
  elif [ "$arg" = "--merge-main" ]; then
    MERGE_MAIN=1
  elif [ "$arg" = "-h" ] || [ "$arg" = "--help" ]; then
    sed -n '2,20p' "$0"
    exit 0
  else
    echo "Unknown flag: $arg" >&2
    exit 2
  fi
done

if [ -n "$(git status --porcelain)" ]; then
  echo "[error] working tree is not clean. Commit or stash first."
  exit 1
fi

BRANCH="$(git branch --show-current)"
if [ -z "$BRANCH" ]; then
  echo "[error] detached HEAD"
  exit 1
fi
if [ "$BRANCH" = "main" ]; then
  echo "[error] refuse to rewrite main in place. Run this on the feature branch."
  exit 1
fi

NAME="${CLAIM_NAME:-$(git config user.name || true)}"
EMAIL="${CLAIM_EMAIL:-$(git config user.email || true)}"
if [ -z "$NAME" ]; then
  NAME="jojo8356"
fi
if [ -z "$EMAIL" ]; then
  EMAIL="polsinelli@gmx.com"
fi

git fetch origin main 2>/dev/null || true
if git rev-parse --verify origin/main >/dev/null 2>&1; then
  BASE="$(git merge-base origin/main HEAD)"
else
  BASE="$(git merge-base main HEAD 2>/dev/null || true)"
fi
if [ -z "$BASE" ]; then
  echo "[error] cannot find merge-base with main"
  exit 1
fi

COUNT="$(git rev-list --count "${BASE}..HEAD")"
echo "Branch:     $BRANCH"
echo "Base:       $BASE"
echo "Commits:    $COUNT"
echo "Identity:   $NAME <$EMAIL>"
echo
echo "This rewrites ${COUNT} commit(s). Hashes will change."
echo

export FILTER_BRANCH_SQUELCH_WARNING=1
if ! git filter-branch -h >/dev/null 2>&1; then
  echo "[error] git filter-branch is not available on this Git."
  exit 1
fi

git filter-branch -f \
  --env-filter "
    export GIT_AUTHOR_NAME='${NAME}'
    export GIT_AUTHOR_EMAIL='${EMAIL}'
    export GIT_COMMITTER_NAME='${NAME}'
    export GIT_COMMITTER_EMAIL='${EMAIL}'
  " \
  --msg-filter 'sed "/Co-authored-by: *arena-agent/d"' \
  -- "${BASE}..HEAD"

git update-ref -d "refs/original/refs/heads/${BRANCH}" 2>/dev/null || true
rm -rf .git/refs/original

echo
echo "[ok] rewritten. Sample:"
git log --format="%h %an <%ae>%n%s%n%b" -1
echo

if [ "$PUSH" -eq 1 ]; then
  echo "[step] git push --force-with-lease origin $BRANCH"
  git push --force-with-lease origin "$BRANCH"
fi

if [ "$MERGE_MAIN" -eq 1 ]; then
  echo "[step] merge $BRANCH into main (local)"
  git checkout main
  git pull --ff-only origin main || true
  git merge --no-ff "$BRANCH" -m "feat: merge ${BRANCH}"
  echo
  echo "main now includes $BRANCH. Push when you are ready:"
  echo "  git push origin main"
  echo
  echo "You are on main. Switch back with: git checkout $BRANCH"
fi
