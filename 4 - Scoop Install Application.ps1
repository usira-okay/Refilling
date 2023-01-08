Write-Host 'Install Applications by Scoop'

Invoke-RestMethod get.scoop.sh | Invoke-Expression

# add bucket
scoop bucket add extras
scoop bucket add main

# install applications
scoop install autohotkey
scoop install hugo-extended
scoop install starship
scoop install lsd
scoop install screentogif


Pause