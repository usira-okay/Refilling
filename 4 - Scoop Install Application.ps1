Write-Host 'Install Applications by Scoop'

Invoke-RestMethod get.scoop.sh | Invoke-Expression

scoop install git
scoop install git-lfs

# add bucket
scoop bucket add extras
scoop bucket add nonportable
scoop bucket add java

# install applications
scoop install autohotkey
scoop install hugo-extended
scoop install starship
scoop install lsd
scoop install screentogif
scoop install brave
scoop install 7zip
scoop install postman
scoop install vscode
scoop install nodejs
scoop install sourcetree
scoop install vlc
scoop install zoom
scoop install ngrok
scoop install filezilla
scoop install yt-dlp
scoop install ffmpeg
scoop install flameshot
scoop install coretemp
scoop install powertoys
scoop install obsidian
scoop install microsoft-jdk
scoop install maven
scoop install docker
scoop install gsudo
scoop install dbeaver
scoop install crystaldiskinfo
scoop install winrar
scoop install speedtest
scoop install devtoys-np
scoop install sql-server-management-studio-np

Pause