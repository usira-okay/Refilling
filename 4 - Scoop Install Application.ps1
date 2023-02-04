Write-Host 'Install Applications by Scoop'

Invoke-RestMethod get.scoop.sh | Invoke-Expression

scoop install git
scoop install git-lfs

# add bucket
scoop bucket add extras

# install applications
scoop install autohotkey
scoop install hugo-extended
scoop install starship
scoop install lsd
scoop install screentogif


Pause