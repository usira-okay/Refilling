Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))
. .\config.ps1

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Other install and settings'
$ErrorActionPreference = 'Stop'

# PowerShell 5.1 預設不啟用 TLS 1.2，許多 HTTPS 端點需要 TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

Write-Host 'PackageProvider Nuget'
Install-PackageProvider -Name Nuget -Force

Write-Host 'Add Nuget Offical Source'
dotnet nuget add source --name nuget.org https://api.nuget.org/v3/index.json

dotnet tool install --global dotnet-ef

Copy-Item .\AutoHotKey\autohotkey.ahk "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey.ahk"

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\PowerToys.lnk")
$Shortcut.TargetPath = "$env:USERPROFILE\scoop\apps\powertoys\current\PowerToys.exe"
$Shortcut.Save()

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\flameshot.lnk")
$Shortcut.TargetPath = "C:\Program Files\Flameshot\bin\flameshot.exe"
$Shortcut.Save()

npx -y @willh/git-setup --name $Config.GitName --email $Config.GitEmail
git config --global --add safe.directory '*'
git config --global worktree.useRelativePaths true
git config --global core.longpaths true

# History Autocomplete
Install-Module PSReadLine -Force -SkipPublisherCheck
Set-PSReadLineOption -PredictionSource History

# Terminal-Icons
Install-Module -Name Terminal-Icons -Repository PSGallery -Force

# 寫 PowerShell_profile
$profilePath = "$env:USERPROFILE\Microsoft.PowerShell_profile.ps1"

# 備份現有 Profile
if (Test-Path $profilePath) {
    $backupPath = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $profilePath -Destination $backupPath
    Write-Host "已備份 Profile 至 $backupPath" -ForegroundColor Yellow
}

New-Item -Path $profilePath -Type File -Force
Set-Content -Path $profilePath -Value @'
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\gmay.omp.json" | Invoke-Expression
Set-PSReadLineOption -PredictionViewStyle ListView
Import-Module Terminal-Icons

function de {
    param([string]$container, [string]$shell = "zsh")
    docker exec -it $container $shell
}


function git-work { git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe -F ~/.ssh/config-work" }
function git-default { git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe -F ~/.ssh/config" }

function Invoke-Copse {
    $output = & "git_worktree_copse" @args
    $output | Write-Output
    $cdLine = $output | Select-String '^COPSE_CD:(.+)$' | Select-Object -Last 1
    if ($cdLine) {
        Set-Location $cdLine.Matches.Groups[1].Value
    }
}
Set-Alias -Name wt -Value Invoke-Copse

'@

# 設定 windows terminal
$path = "$env:userprofile\AppData\Local\Packages"

# 取得以 Microsoft.WindowsTerminal 開頭的資料夾名稱
$termonalName = Get-ChildItem -Path $path -Directory | Where-Object { $_.Name -like "Microsoft.WindowsTerminal*" } | Select-Object -ExpandProperty Name

$settingsPath = Join-Path -Path $path -ChildPath $termonalName
$settingsPath = Join-Path -Path $settingsPath -ChildPath 'LocalState\settings.json'

# 備份 Windows Terminal settings.json
if (Test-Path $settingsPath) {
    $backupSettingsPath = "$settingsPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $settingsPath -Destination $backupSettingsPath
    Write-Host "已備份 Terminal settings 至 $backupSettingsPath" -ForegroundColor Yellow
}

# 讀取現有的 settings.json
$settings = Get-Content -Raw -Path $settingsPath | ConvertFrom-Json -ErrorAction SilentlyContinue

# 如果讀取失敗，建立新的設定物件
if (-not $settings) { $settings = @{} }  

# 找到 PowerShell Profile，並修改 commandLine
$CustProfiles = $settings.profiles.list

foreach ($CustProfile in $CustProfiles) {
    $command = ""
    if ($CustProfile.name -eq "Windows PowerShell") {
        $command = "%WINDIR%\System32\WindowsPowerShell\v1.0\powershell.exe -NoExit -Command `". $profilePath`""
    } elseif ($CustProfile.name -eq "PowerShell") {
        $command = "C:\\Program Files\\PowerShell\\7\\pwsh.exe -NoExit -Command `". $profilePath`""
    } else {
        continue
    }

    if (-not $CustProfile.PSObject.Properties["commandline"]) {
        $CustProfile | Add-Member -MemberType NoteProperty -Name "commandline" -Value ""
    } 

    $CustProfile.commandline = $command
    
    # 新增或修改 font.face
    if (-not $CustProfile.PSObject.Properties["font"]) {
        $CustProfile | Add-Member -MemberType NoteProperty -Name "font" -Value @{ face = "Maple Mono NF CN" }
    } else {
        $CustProfile.font.face = "Maple Mono NF CN"
    }  

    # 新增或修改預設的 profile
    if ($CustProfile.name -eq "PowerShell") {
            
        if (-not $settings.PSObject.Properties["defaultProfile"]) {
            $settings | Add-Member -MemberType NoteProperty -Name "defaultProfile" -Value ""
        }
        $settings.defaultProfile = $CustProfile.guid
    }
}

# 將更新後的設定寫回 settings.json
# 使用 .NET 寫入 UTF-8 無 BOM，避免 PowerShell 5.1 的 Set-Content -Encoding UTF8 會加入 BOM
$jsonContent = $settings | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($settingsPath, $jsonContent, [System.Text.UTF8Encoding]::new($false))

Write-Output "Windows Terminal PowerShell 設定已更新！"

# 檢查 Cargo 是否已安裝
if (Get-Command cargo -ErrorAction SilentlyContinue) {
    cargo install git_worktree_copse
} else {
    Write-Warning 'Cargo 未安裝，跳過 git_worktree_copse 安裝'
}

New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

Pause
