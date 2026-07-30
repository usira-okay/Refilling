if (-not (. ..\Common.ps1 -CallerPath $PSCommandPath)) { return }

if (-not (Test-Path ..\config.ps1)) {
    Write-Error '找不到 config.ps1，請先複製 config.example.ps1 為 config.ps1 並填入個人資訊'
    exit 1
}
. ..\config.ps1

mkdir "$env:USERPROFILE\.ssh" -Force
cd "$env:USERPROFILE\.ssh"

$sshKeySource = $Config.SshKeySource

# Check if source directory exists
if (Test-Path $sshKeySource) {
    # Get all private key files (usually no extension or specific naming pattern)
    $privateKeys = Get-ChildItem -Path $sshKeySource -File | Where-Object {
        $_.Name -notmatch "\.(pub|ppk|known_hosts|config)$"
    }
    
    # Batch copy private keys to .ssh directory
    foreach ($key in $privateKeys) {
        Write-Host "Copying private key: $($key.Name)" -ForegroundColor Green
        Copy-Item -Path $key.FullName -Destination "$env:USERPROFILE\.ssh\$($key.Name)" -Force
    }
    
    Write-Host "Copied $($privateKeys.Count) private key files" -ForegroundColor Yellow
} else {
    Write-Host "Source directory does not exist: $sshKeySource" -ForegroundColor Red
    Pause
    exit 1
}

# Start SSH Agent service
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"

# Get all private keys in .ssh directory and batch add them to ssh-agent
$localPrivateKeys = Get-ChildItem -Path "$env:USERPROFILE\.ssh" -File | Where-Object {
    $_.Name -notmatch "\.(pub|ppk|known_hosts|config)$"
}

foreach ($key in $localPrivateKeys) {
    Write-Host "Adding private key to ssh-agent: $($key.Name)" -ForegroundColor Green
    try {
        ssh-add "$($key.FullName)"
        Write-Host "Successfully added: $($key.Name)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to add: $($key.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "SSH setup completed!" -ForegroundColor Yellow
Pause
