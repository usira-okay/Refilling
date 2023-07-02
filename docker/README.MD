# 架設一些 Server

- docker compose up -d
  > linux 需要加上 sudo

## 步驟

- 需要先將 docker 資料夾整個複製到 ~/docker，並且設定好 env 資料夾中的環境變數
  > `cp ./docker ~/docker -r`
- docker-compose.yml 需要設定 rustdesk 中 hbbs 的 domain
  - 對外的 port 是 21116 那組，需要開確定系統及 router 防火牆有沒有開，tcp 與 udp 都需要開
