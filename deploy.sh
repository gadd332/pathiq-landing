#!/bin/bash
# deploy.sh — commit local changes, push to GitHub, deploy to DO server
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER="root@152.42.207.232"
SSH_KEY="$HOME/.ssh/pathiq_do"
GIT_KEY="$HOME/.ssh/pathiq_landing_deploy"
REMOTE_PATH="/var/www/pathiq"

MSG="${1:-deploy $(date '+%Y-%m-%d %H:%M')}"

echo "→ Committing..."
cd "$REPO_DIR"
git add .
if git diff --cached --quiet; then
  echo "  nothing to commit"
else
  GIT_SSH_COMMAND="ssh -i $GIT_KEY" git commit -m "$MSG"
  GIT_SSH_COMMAND="ssh -i $GIT_KEY" git push
  echo "  pushed to GitHub"
fi

echo "→ Deploying to server..."
ssh -i "$SSH_KEY" "$SERVER" \
  "cd $REMOTE_PATH && GIT_SSH_COMMAND='ssh -i ~/.ssh/pathiq_landing_deploy' git pull"

echo "✓ Done"
