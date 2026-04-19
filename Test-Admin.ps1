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

    # 防止 UAC 拒絕後的無限遞迴
    if ($env:REFILLING_ELEVATED -eq '1') {
        Write-Error '無法取得管理員權限，請以管理員身份執行 PowerShell'
        exit 1
    }

    # 使用當前 PowerShell 執行檔路徑，同時相容 PowerShell 5.1 (powershell.exe) 和 7+ (pwsh.exe)
    $psExe = (Get-Process -Id $PID).Path
    Start-Process $psExe -Verb RunAs -ArgumentList "-NoExit", "-Command", "`$env:REFILLING_ELEVATED='1'; . '$ps1Path'"
    exit
}