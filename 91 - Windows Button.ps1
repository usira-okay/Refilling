Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Write-Host 'Turn off shutdown and sleep btn'

reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Start\HideShutDown /t REG_DWORD /v value /d 1 /f
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Start\HideSleep /t REG_DWORD /v value /d 1 /f

Pause
