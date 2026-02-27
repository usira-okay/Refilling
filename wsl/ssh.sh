# 先啟動 ssh-agent
eval "$(ssh-agent -s)"

mkdir ~/.ssh
cd ~/.ssh

# TODO: 請將 your_email@example.com 替換為你的 email，your_key_name 替換為你的金鑰名稱
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/your_key_name


ssh-add ~/.ssh/your_key_name

