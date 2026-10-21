#requires -Version 7.0
<# .SYNOPSIS 使用目前 PowerShell 7 執行檔提權，並以檔案參數傳遞腳本路徑。 #>
param(
    [Parameter(Mandatory = $true)]
    [Alias('p')]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string] $Ps1Path
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ScriptHelpers.ps1')
if (Test-IsAdministrator) { return $true }

$psExe = (Get-Process -Id $PID).Path
# Windows 檔名不允許雙引號；用 -File 避免把單引號等合法路徑字元當成程式碼。
$arguments = @('-NoLogo', '-NoProfile', '-NoExit', '-File', ('"{0}"' -f $Ps1Path))
Start-Process -FilePath $psExe -Verb RunAs -ArgumentList $arguments -WorkingDirectory (Split-Path -LiteralPath $Ps1Path)
return $false
