Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. ..\Test-Admin.ps1 -p $PSCommandPath

mkdir "$env:USERPROFILE\.ssh" -Force
cd "$env:USERPROFILE\.ssh"

$sshKeySource = "E:\Google\keys\ssh"

# Check if source directory exists
if (Test-Path $sshKeySource) {
    # Get all private key files (usually no extension or specific naming pattern)
    $privateKeys = Get-ChildItem -Path $sshKeySource -File | Where-Object { 
        $_.Extension -eq "" -or $_.Name -notmatch "\.(pub|ppk)$" 
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

# Get all private keys in .ssh directory and batch add them to ssh-agent
$localPrivateKeys = Get-ChildItem -Path "$env:USERPROFILE\.ssh" -File | Where-Object { 
    $_.Extension -eq "" -or ($_.Name -notmatch "\.(pub|ppk|known_hosts|config)$" -and $_.Name -notlike "*.pub") 
}

foreach ($key in $localPrivateKeys) {
    Write-Host "Adding private key to ssh-agent: $($key.Name)" -ForegroundColor Green
    try {
        ssh-add "$($key.FullName)"
        Write-Host "Successfully added: $($key.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to add: $($key.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "SSH setup completed!" -ForegroundColor Yellow
Pause
