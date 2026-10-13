#!/usr/bin/env bash
# Rewrite commits that exist only on this feature branch so they belong
# to you: author + committer, and drop every Co-authored-by trailer.
#
# Does NOT rewrite origin/main. Hashes on this branch will change.
# Force-push is explicit (--push). Merge to main is explicit too.
#
# Usage (clean working tree, on the feature branch — not main):
#   ./scripts/claim_as_me.sh
#   ./scripts/claim_as_me.sh --push
#   ./scripts/claim_as_me.sh --push --merge-main
#
# Identity (first match wins):
#   CLAIM_NAME / CLAIM_EMAIL
#   else Johan Polsinelli / polsinelli@gmx.com

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
    sed -n '2,22p' "$0"
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

NAME="${CLAIM_NAME:-Johan Polsinelli}"
EMAIL="${CLAIM_EMAIL:-polsinelli@gmx.com}"

git fetch origin main 2>/dev/null || true
if git rev-parse --verify origin/main >/dev/null 2>&1; then
  BASE="$(git merge-base origin/main HEAD)"
elif git rev-parse --verify main >/dev/null 2>&1; then
  BASE="$(git merge-base main HEAD)"
else
  echo "[error] cannot find main"
  exit 1
fi

COUNT="$(git rev-list --count "${BASE}..HEAD")"
if [ "$COUNT" -eq 0 ]; then
  echo "[ok] nothing to rewrite (branch has no commits beyond main)"
  exit 0
fi

echo "Branch:     $BRANCH"
echo "Base:       $BASE"
echo "Commits:    $COUNT"
echo "Identity:   $NAME <$EMAIL>"
echo
echo "This rewrites ${COUNT} commit(s) after main. Hashes will change."
echo

export FILTER_BRANCH_SQUELCH_WARNING=1
export GIT_AUTHOR_NAME="$NAME"
export GIT_AUTHOR_EMAIL="$EMAIL"
export GIT_COMMITTER_NAME="$NAME"
export GIT_COMMITTER_EMAIL="$EMAIL"

git filter-branch -f \
  --env-filter "
    export GIT_AUTHOR_NAME='${NAME}'
    export GIT_AUTHOR_EMAIL='${EMAIL}'
    export GIT_COMMITTER_NAME='${NAME}'
    export GIT_COMMITTER_EMAIL='${EMAIL}'
  " \
  --msg-filter 'grep -v -E "^Co-authored-by:" || true' \
  "${BASE}..HEAD"

git update-ref -d "refs/original/refs/heads/${BRANCH}" 2>/dev/null || true
rm -rf .git/refs/original

echo
echo "[ok] rewritten. Tip of branch:"
git log --format="%h %an <%ae>%n%s" -1
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
