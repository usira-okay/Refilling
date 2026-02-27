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

    Start-Process Powershell -Verb RunAs -ArgumentList ". '$ps1Path'" 
    break
}