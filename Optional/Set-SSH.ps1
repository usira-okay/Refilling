#requires -Version 5.1
<# .SYNOPSIS 將來源資料夾中可辨識的私鑰交給 Windows OpenSSH，任一步驟失敗即停止。 #>
$repositoryRoot = Split-Path $PSScriptRoot -Parent
if (-not (. (Join-Path $repositoryRoot 'Common.ps1') -CallerPath $PSCommandPath)) { return }

$configPath = Join-Path $repositoryRoot 'config.ps1'
if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    throw '找不到 config.ps1，請先複製 config.example.ps1 為 config.ps1 並填入個人資訊。'
}
. $configPath

$sshKeySource = $Config.SshKeySource
if ([string]::IsNullOrWhiteSpace($sshKeySource) -or
    -not (Test-Path -LiteralPath $sshKeySource -PathType Container)) {
    throw "SshKeySource 必須是存在的資料夾：$sshKeySource"
}

$privateKeyHeader = '^-----BEGIN (?:(?:OPENSSH|RSA|DSA|EC|ENCRYPTED) )?PRIVATE KEY-----$'
$privateKeys = @(Get-ChildItem -LiteralPath $sshKeySource -File | Where-Object {
    $_.Name -notin @('config', 'known_hosts', 'authorized_keys') -and
    $_.Extension -notin @('.pub', '.ppk') -and
    (Get-Content -LiteralPath $_.FullName -TotalCount 1) -cmatch $privateKeyHeader
})
if ($privateKeys.Count -eq 0) {
    throw "SshKeySource 找不到 OpenSSH 或 PEM 格式的私鑰：$sshKeySource"
}

$gitCommand = Get-Command -Name git -CommandType Application -ErrorAction SilentlyContinue
if (-not $gitCommand) {
    throw '找不到 git，請先安裝 Git 並重新開啟終端機。'
}
$openSshDirectory = Join-Path $env:WINDIR 'System32/OpenSSH'
$sshPath = Join-Path $openSshDirectory 'ssh.exe'
$sshAddPath = Join-Path $openSshDirectory 'ssh-add.exe'
foreach ($toolPath in @($sshPath, $sshAddPath)) {
    if (-not (Test-Path -LiteralPath $toolPath -PathType Leaf)) {
        throw "找不到 Windows OpenSSH 工具：$toolPath。請先安裝 OpenSSH 用戶端。"
    }
}
Get-Service -Name ssh-agent | Out-Null

$sshDestination = Join-Path $env:USERPROFILE '.ssh'
New-Item -ItemType Directory -Path $sshDestination -Force | Out-Null
foreach ($key in $privateKeys) {
    Copy-Item -LiteralPath $key.FullName -Destination (Join-Path $sshDestination $key.Name) -Force
}

Set-Service -Name ssh-agent -StartupType Automatic
Start-Service -Name ssh-agent
# Git 與 ssh-add 使用同一套 Windows OpenSSH；shell 單引號避免 5.1 移除內嵌雙引號。
$gitSshCommand = "'{0}'" -f $sshPath.Replace('\', '/').Replace("'", "'\''")
Invoke-ExternalCommand -FilePath $gitCommand.Source -ArgumentList @('config', '--global', 'core.sshCommand', $gitSshCommand)

foreach ($key in $privateKeys) {
    Invoke-ExternalCommand -FilePath $sshAddPath -ArgumentList @((Join-Path $sshDestination $key.Name))
    Write-Host "成功加入私鑰：$($key.Name)" -ForegroundColor Green
}

Write-Host 'SSH 設定完成。' -ForegroundColor Green
Pause
