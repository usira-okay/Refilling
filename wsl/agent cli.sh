
mkdir -p ~/.copilot

# 檢查 ~/.copilot/copilot-instructions.md 設定檔是否存在，存在則備份
if [ -f ~/.copilot/copilot-instructions.md ]; then
    cp ~/.copilot/copilot-instructions.md ~/.copilot/copilot-instructions.md.backup.$(date +%Y%m%d_%H%M%S)
    echo "已備份現有的 ~/.copilot/copilot-instructions.md 設定檔"
fi

# 建立 ~/.copilot/copilot-instructions.md 預設內容
cat <<'EOF' > ~/.copilot/copilot-instructions.md
**請遵循 constitution.md** 的規範
**Please follow the guidelines in constitution.md**
EOF

echo "已建立 ~/.copilot/copilot-instructions.md 預設內容"
