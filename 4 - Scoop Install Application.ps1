Write-Host 'Install Applications by Scoop'

Invoke-RestMethod get.scoop.sh | Invoke-Expression

scoop install git
scoop install git-lfs

# add bucket
scoop bucket add extras

# install applications
scoop install autohotkey
scoop install lsd
scoop install screentogif
scoop install brave
scoop install postman
scoop install nodejs
scoop install sourcetree
scoop install ngrok
scoop install filezilla
scoop install yt-dlp
scoop install ffmpeg
scoop install flameshot
scoop install coretemp
scoop install obsidian
scoop install docker
scoop install gsudo
scoop install crystaldiskinfo
scoop install speedtest

Pause