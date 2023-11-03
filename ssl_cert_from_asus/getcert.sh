#!/bin/bash
rm -f /ssl/cert_key.tar
curl -c ./cookie.txt 'https://router.asus.com:1443/login.cgi' --insecure \
  -H 'Connection: keep-alive' \
  -H 'Cache-Control: max-age=0' \
  -H 'Origin: https://router.asus.com:1443' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36 Edg/119.0.0.0' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
  -H 'Referer: https://router.asus.com:1443/Main_Login.asp' \
  -H 'Accept-Language: en-US,en;q=0.9' \
   --data-raw 'group_id=&action_mode=&action_script=&action_wait=5&current_page=Main_Login.asp&next_page=index.asp&login_authorization=!!!YOURTOKENHERE!!!&login_captcha='
curl -b ./cookie.txt 'https://router.asus.com:1443/cert_key.tar' --insecure \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36 Edg/119.0.0.0' \
  -H 'Referer: https://router.asus.com:1443/Advanced_ASUSDDNS_Content.asp' \
  -o /ssl/cert_key.tar
rm ./cookie.txt
cd /ssl
tar -xf cert_key.tar

