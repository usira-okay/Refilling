#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

echo "=== Rust 工具鏈 ==="

if command -v rustup &>/dev/null; then
    echo "Rust 已安裝，更新至最新版..."
    rustup update stable
else
    echo "安裝 Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

echo "=== Rust 工具鏈完成 ==="
