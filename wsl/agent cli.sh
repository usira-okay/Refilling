
# 建立 ~/.claude 目錄
mkdir -p ~/.claude
mkdir -p ~/.config/opencode
mkdir -p ~/.copilot


# 檢查 ~/.claude/CLAUDE.md 設定檔是否存在，存在則備份
if [ -f ~/.claude/CLAUDE.md ]; then
    cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)
    echo "已備份現有的 ~/.claude/CLAUDE.md 設定檔"
fi

# 建立 ~/.claude/CLAUDE.md 預設內容
cat <<'EOF' > ~/.claude/CLAUDE.md
**請遵循 constitution.md** 的規範
**Please follow the guidelines in constitution.md**
EOF

echo "已建立 ~/.claude/CLAUDE.md 預設內容"

# 檢查 ~/.config/opencode/AGENTS.md 設定檔是否存在，存在則備份
if [ -f ~/.config/opencode/AGENTS.md ]; then
    cp ~/.config/opencode/AGENTS.md ~/.config/opencode/AGENTS.md.backup.$(date +%Y%m%d_%H%M%S)
    echo "已備份現有的 ~/.config/opencode/AGENTS.md 設定檔"
fi

# 建立 ~/.config/opencode/AGENTS.md 預設內容
cat <<'EOF' > ~/.config/opencode/AGENTS.md
**請遵循 constitution.md** 的規範
**Please follow the guidelines in constitution.md**
EOF

echo "已建立 ~/.config/opencode/AGENTS.md 預設內容"

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
