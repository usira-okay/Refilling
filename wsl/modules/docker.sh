#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

echo "=== Docker 安裝 ==="

if command -v docker &>/dev/null; then
    echo "Docker 已安裝，跳過"
    docker --version
else
    echo "移除舊版 Docker..."
    sudo apt-get remove docker docker-engine docker.io containerd runc -y 2>/dev/null || true

    echo "安裝必要套件..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg

    echo "Docker 基礎套件已安裝，請依官方文件完成剩餘設定"
fi

echo "=== Docker 安裝完成 ==="
