#!/bin/bash
# Usage: ./scripts/git-cleanup.sh <submodule> <branch>
# Example: ./scripts/git-cleanup.sh frontend feat/shift-grid
set -e

SUBMODULE=$1
BRANCH=$2

if [ -z "$SUBMODULE" ] || [ -z "$BRANCH" ]; then
  echo "Usage: $0 <submodule> <branch>"
  exit 1
fi

echo "--- Cleaning up: $SUBMODULE / $BRANCH ---"

cd "$SUBMODULE"

git push origin --delete "$BRANCH"
echo "Deleted remote branch: origin/$BRANCH"

git switch main
git pull origin main
echo "Switched to main and pulled latest"

git branch -d "$BRANCH"
echo "Deleted local branch: $BRANCH"

echo "--- Done! ---"
