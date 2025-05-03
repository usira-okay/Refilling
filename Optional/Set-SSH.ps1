Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. ..\Test-Admin.ps1 -p $PSCommandPath

mkdir "$env:USERPROFILE\.ssh"
cd "$env:USERPROFILE\.ssh"

$sshKeySource = "Y:\My Drive\keys\ssh\arisu-okay-github-SSH"
Copy-Item -Path $sshKeySource -Destination "$env:USERPROFILE\.ssh\arisu-okay-github-SSH" -Force

Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
# 將 SSH 私鑰交給 ssh-agent 保管
# 這邊會需要輸入一次上面設定的密碼
ssh-add "$env:USERPROFILE\.ssh\arisu-okay-github-SSH"

Pause
