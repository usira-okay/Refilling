$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   

Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

refreshenv