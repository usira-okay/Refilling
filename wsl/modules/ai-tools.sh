#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

echo "=== AI 工具安裝 ==="

# 載入 NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# UV（冪等）
if ! command -v uv &>/dev/null; then
    echo "安裝 UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "UV 已安裝，跳過"
fi

# 確保 PATH 包含 cargo/uv
source "$HOME/.cargo/env" 2>/dev/null || true
export PATH="$HOME/.local/bin:$PATH"

sudo apt update && sudo apt upgrade -y

# npm 全域工具（冪等）
for pkg in "@google/gemini-cli" "@openai/codex" "@fission-ai/openspec@latest"; do
    if npm list -g "$pkg" &>/dev/null; then
        echo "$pkg 已安裝，跳過"
    else
        echo "安裝 $pkg..."
        npm install -g "$pkg"
    fi
done

# GitHub Copilot（冪等）
if ! command -v copilot &>/dev/null; then
    echo "安裝 GitHub Copilot..."
    curl -fsSL https://gh.io/copilot-install | bash
else
    echo "GitHub Copilot 已安裝，跳過"
fi

# specify-cli
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git

# bashrc aliases（冪等）
if ! grep -q "alias cpy=" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'EOF'
alias cpy='copilot --yolo'
alias g='gemini --yolo'

EOF
    echo "已加入 CLI aliases"
fi

echo "=== AI 工具安裝完成 ==="
