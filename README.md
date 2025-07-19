# 使用方式

- 依照檔案命名順序，除了 Set ExecutionPolicy 需要手動複製貼上外，其他的都是直接以 Powershell 執行

## WLS

- `wsl --install Ubuntu` 會需要手動輸入`使用者名稱`與`密碼`，所以放這邊

```bash
wsl --install

wsl --update

wsl --unregister Ubuntu

wsl --install Ubuntu

wsl --set-default Ubuntu

```

```bash
echo "$USER ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER

sudo apt update && sudo apt upgrade -y

# set timezone to +0800
sudo ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
sudo dpkg-reconfigure --frontend noninteractive tzdata

# 建立自用的執行檔目錄
mkdir -p ~/.local/bin

# Installing essential packages...
sudo apt install -y wslu xdg-utils pulseaudio \
  build-essential net-tools ripgrep jq lftp moreutils btop bat zip zstd gnupg2 \
  ffmpeg 7zip poppler-utils fd-find zoxide imagemagick exiftool

# Install Rust: https://www.rust-lang.org/tools/install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
# Upgrade Rust is you already installed long time ago
rustup update stable


# 將 batcat 建立一個 symbolic link 為 bat，方便日後使用
ln -s /usr/bin/batcat ~/.local/bin/bat

# jq: https://github.com/jqlang/jq
curl -sL https://github.com/jqlang/jq/releases/latest/download/jq-linux64 -o ~/.local/bin/jq && chmod +x ~/.local/bin/jq

# yq: https://github.com/mikefarah/yq
curl -sL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o ~/.local/bin/yq && chmod +x ~/.local/bin/yq

source ~/.profile

curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/$(curl -s "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | jq -r .tag_name)/install.sh | bash
source ~/.bashrc
nvm install 24
nvm use 24
node -v


# profile setup
cat <<'EOF' | tee -a ~/.profile
# 針對暗色背景終端機的明亮色彩配置
export JQ_COLORS="33:93:93:96:92:97:1;97:4;97"
EOF

# bash setup
cat <<'EOF' | tee -a ~/.bashrc
# Enable programmable completion features
shopt -u direxpand
shopt -s no_empty_cmd_completion
EOF

# setup workspace
mkdir -p ~/projects



# Install Starship
curl -sS https://starship.rs/install.sh | sh -s -- -y

# 參考設定 https://starship.rs/config/
mkdir -p ~/.config && touch ~/.config/starship.toml

# 安裝預設主題 https://starship.rs/presets/catppuccin-powerline
starship preset catppuccin-powerline -o ~/.config/starship.toml

# 修改 line_break 設定，啟用換行顯示
sed -i '/^\[line_break\]/,/^\[/ s/disabled = true/disabled = false/' ~/.config/starship.toml

cat <<'EOF' | tee -a ~/.bashrc > /dev/null
eval "$(starship init bash)"
EOF

source ~/.bashrc


# Ubuntu 22.04 預設已經有安裝 fzf，但如果你想要重新安裝最新版本，可以先移除舊版：
sudo apt remove fzf

# 安裝最新版
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

source ~/.bashrc

# git setup
npx -y @willh/git-setup --name '$USER' --email arisuokayokay@gmail.com
git config --global core.autocrlf input
git config --global init.defaultBranch main


npm install -g @google/gemini-cli && gemini -v


npm install -g @anthropic-ai/claude-code

# 設定任務完成的鈴聲
claude config set --global preferredNotifChannel terminal_bell

# 設定暗黑佈景主題
claude config set -g theme dark

# CI 模式必須關閉 verbose
claude config set -g verbose false


curl -LsSf https://astral.sh/uv/install.sh | sh
uv -V


```
