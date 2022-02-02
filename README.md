# 使用方式

先確定 Windows Update 都更新完，不然裝 SSMS 會失敗

PowerShell.exe -ExecutionPolicy UnRestricted -File {ps1}

## 安裝程式清單

- sqlpackage
- Google Chrome
- Line
- TeamViewer
- Telegram
- 7zip
- AdobeReader(PDF)
- Discord
- Postman
- Visual Studio Code
- Nodejs
- Git
- SourceTree
- Visual Studio 2019 - Community
- SSMS
- PotPlayer
- Teams
- WSL2
- Docker
- PowerToys
- OpenShot
- OBS
- office 365 business
- Zoom
- nuget.commandline

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

```powershell
choco upgrade all
```
