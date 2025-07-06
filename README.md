# 使用方式

- 依照檔案命名順序，除了 Set ExecutionPolicy 需要手動複製貼上外，其他的都是直接以 Powershell 執行

## WLS

- `wsl --install Ubuntu` 會需要手動輸入`使用者名稱`與`密碼`，所以放這邊

```bash
wsl --update
wsl --install Ubuntu
wsl --set-default Ubuntu
```

```bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y --no-install-recommends \
git \
procps \
fzf \
zsh \
unzip \
man-db \
gnupg2 \
gh \
iptables \
ipset \
iproute2 \
dnsutils \
aggregate \
jq \
ca-certificates \
curl

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo bash -
sudo apt-get install -y nodejs

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

npm install -g @google/gemini-cli

echo 'npm update -g @google/gemini-cli' >> ~/.zshrc
```

## 安裝程式清單

> 懶得列了
