#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

NODE_VER="${NODE_VERSION:-24}"

echo "=== Node.js (v${NODE_VER}) ==="

# 安裝 NVM（冪等）
if [ ! -d "$HOME/.nvm" ]; then
    echo "安裝 NVM..."
    source ~/.profile 2>/dev/null || true
    curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/$(curl -s "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | jq -r .tag_name)/install.sh | bash
else
    echo "NVM 已安裝，跳過"
fi

# 載入 NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# 安裝 Node.js
if ! nvm ls "$NODE_VER" &>/dev/null; then
    echo "安裝 Node.js v${NODE_VER}..."
    nvm install "$NODE_VER"
else
    echo "Node.js v${NODE_VER} 已安裝，跳過"
fi

nvm use "$NODE_VER"
echo "Node.js $(node -v) 已啟用"

echo "=== Node.js 完成 ==="
