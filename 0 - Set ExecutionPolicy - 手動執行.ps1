Set-Location ([System.IO.Path]::GetDirectoryName($PSCommandPath))

. .\Test-Admin.ps1 -p $PSCommandPath

Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser -Force
