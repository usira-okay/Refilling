sudo sed -i 's|http://archive.ubuntu.com|http://tw.archive.ubuntu.com|g' /etc/apt/sources.list
sudo sed -i 's|http://security.ubuntu.com|http://tw.archive.ubuntu.com|g' /etc/apt/sources.list

# 2. 啟用 apt 平行下載（加速）
echo 'Acquire::Queue-Mode "host";' | sudo tee /etc/apt/apt.conf.d/99parallel
echo 'Acquire::http::Pipeline-Depth "5";' | sudo tee -a /etc/apt/apt.conf.d/99parallel

# 3. 加入 .NET PPA 並安裝
sudo add-apt-repository ppa:dotnet/backports -y
sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-6.0 dotnet-sdk-8.0 dotnet-sdk-9.0 dotnet-sdk-10.0
