sudo apt update && sudo apt upgrade -y

npm install -g @google/gemini-cli
npm install -g @anthropic-ai/claude-code

# 設定暗黑佈景主題
claude config set -g theme dark

# CI 模式必須關閉 verbose
claude config set -g verbose false

# mcp tool context7
claude mcp add context7 -s user -- npx -y @upstash/context7-mcp

# 建立 ~/.claude 目錄（如果不存在）
mkdir -p ~/.claude

# 檢查設定檔是否存在，存在則備份
if [ -f ~/.claude/settings.json ]; then
    cp ~/.claude/settings.json ~/.claude/settings.json.backup.$(date +%Y%m%d_%H%M%S)
    echo "已備份現有的 Claude 設定檔"
fi

# 建立 Claude 設定檔
cat <<'EOF' > ~/.claude/settings.json
{
    "permissions": {
        "allow": [
            "Edit",
            "WebFetch",
            "Bash(dotnet:*)",
            "Bash(ls:*)",
            "Bash(mkdir:*)",
            "Bash(git status)",
            "Bash(git diff:*)",
            "Bash(git log:*)",
            "Bash(git add:*)",
            "Bash(git rm:*)",
            "Bash(git commit:*)",
            "Bash(git push:*)",
            "Bash(git push)",
            "Bash(git tag:*)",
            "Bash(find:*)",
            "Bash(sed:*)",
            "Bash(rg:*)",
            "mcp__context7__resolve-library-id",
            "mcp__context7__get-library-docs"
        ],
        "deny": [],
        "defaultMode": "bypassPermissions"
    }
}
EOF

# # 檢查 ~/.claude.json 設定檔是否存在，存在則備份
# if [ -f ~/.claude.json ]; then
#     cp ~/.claude.json ~/.claude.json.backup.$(date +%Y%m%d_%H%M%S)
#     echo "已備份現有的 ~/.claude.json 設定檔"
# fi

# # 建立或更新 ~/.claude.json 設定檔
# if [ ! -f ~/.claude.json ]; then
#     # 如果檔案不存在，建立新檔案
#     cat <<'EOF' > ~/.claude.json
# {
#     "bypassPermissionsModeAccepted": true
# }
# EOF
#     echo "已建立新的 ~/.claude.json 設定檔，包含 bypassPermissionsModeAccepted: true"
# else
#     # 如果檔案存在，使用 jq 確保 bypassPermissionsModeAccepted 設定為 true
#     jq '.bypassPermissionsModeAccepted = true' ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
#     echo "已更新現有的 ~/.claude.json 設定檔，確保 bypassPermissionsModeAccepted: true"
# fi
