# 使用方式

先確定 Windows Update 都更新完，不然裝 SSMS 會失敗

## 安裝程式清單

1. tortoisegit
1. sizer
1. sqlpackage
1. brave
1. line
1. teamviewer
1. 7zip
1. adobereader
1. postman
1. vscode
1. nodejs-lts
1. git
1. sourcetree
1. potplayer
1. zoom
1. ngrok
1. filezilla
1. yt-dlp
1. ffmpeg
1. flameshot
1. devtoys
1. coretemp
1. nuget.commandline
1. speedtest-by-ookla
1. sql-server-management-studio
1. visualstudio2019community
1. visualstudio2022community

## 選擇安裝

1. discord
1. openshot
1. obs-studio
1. steam-client

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
