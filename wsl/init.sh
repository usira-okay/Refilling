#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 載入設定檔
source "$SCRIPT_DIR/config.sh"

echo "=========================================="
echo "  Refilling WSL 環境初始化"
echo "=========================================="
echo ""

# 依序執行各模組
modules=(
    "core"
    "rust"
    "nodejs"
    "shell"
    "git"
    "ai-tools"
    "docker"
)

for module in "${modules[@]}"; do
    module_path="$SCRIPT_DIR/modules/${module}.sh"
    if [ -f "$module_path" ]; then
        echo ""
        echo "▶ 執行模組: ${module}"
        echo "──────────────────────────────────"
        bash "$module_path"
    else
        echo "⚠ 模組不存在: ${module_path}"
    fi
done

echo ""
echo "=========================================="
echo "  初始化完成！請重新開啟終端機。"
echo "=========================================="
