Param(
    [parameter(Mandatory = $true)]
    [alias("p")]
    [string]
    [ValidateScript( { Test-Path $_ -PathType Leaf } )]
    $ps1Path)


Write-Host 'Test-Administrator'
$user = [Security.Principal.WindowsIdentity]::GetCurrent();

$isAdmin = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) 

if (-not $isAdmin) {

    # 使用當前 PowerShell 執行檔路徑，同時相容 PowerShell 5.1 (powershell.exe) 和 7+ (pwsh.exe)
    $psExe = (Get-Process -Id $PID).Path
    Start-Process $psExe -Verb RunAs -ArgumentList "-NoExit", ". '$ps1Path'"
    break
}