Set-ExecutionPolicy AllSigned
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install googlechrome -y
choco install line -y
choco install teamviewer -y
choco install telegram -y
choco install spotify -y
choco install 7zip -y
choco install adobereader -y
choco install google-backup-and-sync -y
choco install lbry -y
choco install steam -y

choco install filezilla -y
choco install postman -y
choco install vscode -y
choco install fiddler -y
choco install nodejs -y
choco install git -y
choco install sourcetree -y
choco install sql-server-management-studio -y
choco install visualstudio2019community -y
choco install visualstudio2019-workload-netweb -y
choco install visualstudio2019-workload-azure -y
choco install visualstudio2019-workload-visualstudioextension -y
choco install visualstudio2019-workload-data -y
choco install visualstudio2019-workload-netcoretools -y
choco install visualstudio2019-workload-manageddesktop -y
choco install visualstudio2019-workload-databuildtools -y
choco install visualstudio2019-workload-netcorebuildtools -y
choco install visualstudio2019-workload-azurebuildtools -y
choco install visualstudio2019-workload-manageddesktopbuildtools -y
