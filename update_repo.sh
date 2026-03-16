#!/bin/bash
# Bismillah - Update script for the Open Source Repo
REPO_DIR="/home/melikshah/.openclaw/workspace/qwen35-vulkan-rx580-fix"

cd "$REPO_DIR" || exit

echo "--- Current Status ---"
git status -s

echo "Staging changes..."
git add .

echo "Commit message giriniz (bos birakirsanız 'Update' kullanılır):"
read -r msg
if [ -z "$msg" ]; then
    msg="Update: $(date +'%Y-%m-%d %H:%M')"
fi

git commit -m "$msg"

echo "Pushing to GitHub via Deploy Key..."
git push origin master
