#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

echo "=== 系統基礎設定 ==="

# sudoers（冪等：檢查是否已設定）
if ! sudo grep -q "NOPASSWD:ALL" /etc/sudoers.d/$USER 2>/dev/null; then
    echo "$USER ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
    echo "已設定 sudoers"
else
    echo "sudoers 已設定，跳過"
fi

sudo apt update && sudo apt upgrade -y

# 時區
sudo ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
sudo dpkg-reconfigure --frontend noninteractive tzdata

# 建立自用的執行檔目錄
mkdir -p ~/.local/bin

# 基礎套件
echo "安裝基礎套件..."
sudo apt install -y wslu xdg-utils pulseaudio \
  build-essential net-tools ripgrep lftp moreutils btop bat zip zstd gnupg2 \
  ffmpeg 7zip poppler-utils fd-find zoxide imagemagick exiftool

# batcat symlink（冪等）
if [ ! -L ~/.local/bin/bat ]; then
    ln -s /usr/bin/batcat ~/.local/bin/bat
    echo "已建立 bat symlink"
else
    echo "bat symlink 已存在，跳過"
fi

# jq（冪等）
if ! command -v jq &>/dev/null; then
    echo "安裝 jq..."
    curl -sL https://github.com/jqlang/jq/releases/latest/download/jq-linux64 -o ~/.local/bin/jq && chmod +x ~/.local/bin/jq
else
    echo "jq 已安裝，跳過"
fi

# yq（冪等）
if ! command -v yq &>/dev/null; then
    echo "安裝 yq..."
    curl -sL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o ~/.local/bin/yq && chmod +x ~/.local/bin/yq
else
    echo "yq 已安裝，跳過"
fi

# workspace 目錄
mkdir -p ~/projects

echo "=== 系統基礎設定完成 ==="
