#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

echo "=== Shell 環境設定 ==="

# Starship（冪等）
if ! command -v starship &>/dev/null; then
    echo "安裝 Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "Starship 已安裝，跳過"
fi

# Starship 設定
mkdir -p ~/.config
if [ ! -f ~/.config/starship.toml ] || [ ! -s ~/.config/starship.toml ]; then
    starship preset catppuccin-powerline -o ~/.config/starship.toml
    sed -i '/^\[line_break\]/,/^\[/ s/disabled = true/disabled = false/' ~/.config/starship.toml
    echo "已套用 Starship catppuccin-powerline 主題"
else
    echo "Starship 設定已存在，跳過"
fi

# bashrc: starship init（冪等）
if ! grep -q 'starship init bash' ~/.bashrc 2>/dev/null; then
    cat <<'EOF' >> ~/.bashrc
eval "$(starship init bash)"
EOF
    echo "已加入 Starship 至 bashrc"
fi

# fzf（冪等）
if ! command -v fzf &>/dev/null || [ -d ~/.fzf ]; then
    if [ ! -d ~/.fzf ]; then
        echo "安裝 fzf..."
        sudo apt remove fzf -y 2>/dev/null || true
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi
    ~/.fzf/install --all --no-bash --no-zsh --no-fish 2>/dev/null || ~/.fzf/install --all
else
    echo "fzf 已安裝，跳過"
fi

# profile: JQ_COLORS（冪等）
if ! grep -q 'JQ_COLORS' ~/.profile 2>/dev/null; then
    cat <<'EOF' >> ~/.profile
# 針對暗色背景終端機的明亮色彩配置
export JQ_COLORS="33:93:93:96:92:97:1;97:4;97"
EOF
    echo "已加入 JQ_COLORS 設定"
fi

echo "=== Shell 環境設定完成 ==="
