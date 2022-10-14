# 使用方式

先確定 Windows Update 都更新完，不然裝 SSMS 會失敗

PowerShell.exe -ExecutionPolicy UnRestricted -File {ps1}

## 安裝程式清單

- tortoisegit
- linqpad7
- sqlpackage
- googlechrome
- line
- teamviewer
- telegram
- 7zip
- adobereader
- discord
- postman
- vscode
- nodejs-lts
- git
- sourcetree
- potplayer
- microsoft-teams
- openshot
- obs-studio
- zoom
- steam-client
- ngrok
- filezilla
- yt-dlp
- ffmpeg
- flameshot
- devtoys
- dropbox
- coretemp
- speedtest
- nuget.commandline
- sql server management studio
- visualstudio 2019 community
- visualstudio 2022 community

## 選擇安裝

### docker 預留 port

```ps
dism.exe /Online /Disable-Feature:Microsoft-Hyper-V
netsh int ipv4 add excludedportrange protocol=tcp startport=1433 numberofports=1
dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All
```

### Angular

```powershell
npm install -g @angular/cli
```

### VSCode

```powershell
# 同步設定
# alt + shift + U -> 上傳設定
# clt + shift + D -> 下載設定
code --install-extension "shan.code-settings-sync"

# 保哥的markdown擴充套件包
code --install-extension "doggy8088.markdown-extension-pack"

# 保哥的angular擴充套件包
code --install-extension "doggy8088.angular-extension-pack"
```

### Nswag

```powershell
npm i -g nswag
```

### chocolately 更新

```powershell
choco upgrade all -y
```
