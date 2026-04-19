#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

GIT_NAME="${GIT_USER_NAME:-arisu}"
GIT_EMAIL="${GIT_USER_EMAIL:-arisuokayokay@gmail.com}"

echo "=== Git 設定 (${GIT_NAME}) ==="

# 載入 NVM 以使用 npx
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

npx -y @willh/git-setup --name "$GIT_NAME" --email "$GIT_EMAIL"

mkdir -p "$HOME/.git-template"
git config --global init.templateDir "$HOME/.git-template"
git config --file "$HOME/.git-template/config" core.filemode false

echo "=== Git 設定完成 ==="
