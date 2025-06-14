Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Other install and settings'

Write-Host 'PackageProvider Nuget'
Install-PackageProvider -Name Nuget -Force

Write-Host 'Add Nuget Offical Source'
dotnet nuget add source --name nuget.org https://api.nuget.org/v3/index.json

dotnet tool install --global dotnet-ef

Copy-Item .\AutoHotKey\autohotkey.ahk "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey.ahk"

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\PowerToys.lnk")
$Shortcut.TargetPath = "C:\Users\$env:USERNAME\scoop\apps\powertoys\current\PowerToys.exe"
$Shortcut.Save()

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\flameshot.lnk")
$Shortcut.TargetPath = "C:\Program Files\Flameshot\bin\flameshot.exe"
$Shortcut.Save()

git config --global core.sshCommand C:/Windows/System32/OpenSSH/ssh.exe
git config --global user.name "Ari"
git config --global user.email "arisuokayokay@gmail.com"
git config --global core.autocrlf true
git config --global core.safecrlf true
git config --global push.autoSetupRemote true

# History Autocomplete
Install-Module PSReadLine -Force
Set-PSReadLineOption -PredictionSource History

# Terminal-Icons
Install-Module -Name Terminal-Icons -Repository PSGallery -Force

# 寫 PowerShell_profile
$profilePath = "$env:USERPROFILE\Microsoft.PowerShell_profile.ps1"
New-Item -Path $profilePath -Type File -Force
Set-Content -Path $profilePath -Value @'
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\gmay.omp.json" | Invoke-Expression
Set-PSReadLineOption -PredictionViewStyle ListView
Import-Module Terminal-Icons
'@

# 設定 windows terminal
$path = "$env:userprofile\AppData\Local\Packages"

# 取得以 Microsoft.WindowsTerminal 開頭的資料夾名稱
$termonalName = Get-ChildItem -Path $path -Directory | Where-Object { $_.Name -like "Microsoft.WindowsTerminal*" } | Select-Object -ExpandProperty Name

$settingsPath = Join-Path -Path $path -ChildPath $termonalName
$settingsPath = Join-Path -Path $settingsPath -ChildPath 'LocalState\settings.json'

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
    }
    elseif ($CustProfile.name -eq "PowerShell") {
        $command = "C:\\Program Files\\PowerShell\\7\\pwsh.exe -NoExit -Command `". $profilePath`""
    }
    else {
        continue
    }

    if (-not $CustProfile.PSObject.Properties["commandline"]) {
        $CustProfile | Add-Member -MemberType NoteProperty -Name "commandline" -Value ""
    } 

    $CustProfile.commandline = $command
    
    # 新增或修改 font.face
    if (-not $CustProfile.PSObject.Properties["font"]) {
        $CustProfile | Add-Member -MemberType NoteProperty -Name "font" -Value @{ face = "Maple Mono NF CN" }
    }
    else {
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
$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8

Write-Output "Windows Terminal PowerShell 設定已更新！"

podman machine init
podman machine start

uv venv
uv pip install podman-compose

Pause
