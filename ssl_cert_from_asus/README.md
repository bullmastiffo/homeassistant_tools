# Renew Let's Encrypt Certificate From Asus Router

For people who has Asus router at home and uses Asus DDNS as well as built in Let's Encrypt certificate,
here are some blueprints and configuration to use this certificate for your HomeAssistant via Nginx AddOn as SSL certificate.

AND **automatically update this certificate**

## Concept

Main concept is to use `curl` to fetch certificate from the router when the time of the cert is about to expire.
For automation we check everyday how soon it will expire, as soon as it's less then given number of days - trigger update.
Used this blueprint as an example [blueprint sample](https://community.home-assistant.io/t/blueprint-for-automatic-renewal-of-a-lets-encrypt-certificate/300533)
Update is a bash script, to have write permissions we have to run it via ssh. Thanks to the folks [here](https://community.home-assistant.io/t/shell-command-backup-not-found/273055/9).

## Guide

1. Install the following add-ons:

  1.1. NGINX Home Assistant SSL proxy <https://github.com/home-assistant/addons/tree/master/nginx_proxy>
  
  1.2. Terminal & SSH or Advanced SSH & Web Terminal
  
  With the latter if you want scp to work, then username must be root and you can enable sftp as well.
  Don't forget to add you SSH public key to `authorized_keys`.

2. SSH into your HA instnace and edit your `/config/configuration.yaml`

```bash
ssh root@homeassistant.local
cd /config
nano configuration.yaml
```

add the following configuration  to it:

```YAML
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.33.0/24

shell_command:
  update_ssl_cert: /usr/bin/ssh -o UserKnownHostsFile=/config/shell_scripts/ssh/known_hosts root@localhost -i /config/shell_scripts/ssh/id_rsa /bin/bash /config/shell_scripts/getcert.sh
```

http part is required by NGINX add on to work.
shell_command - is used by blueprint automation to fetch the cert from the router.

Stay in the SSH for next step.

3. Generate SSH key to allow local SSH calls from `shell_command`. Thanks this thread for workaround [thread](https://community.home-assistant.io/t/shell-command-backup-not-found/273055/9)

```bash
cd /config
mkdir shell_scripts
cd shell_scripts
ssh
cd ssh
ssh-keygen
cp -p /root/.ssh/id_rsa id_rsa
ssh root@localhost -i id_rsa # at this step it will suggest to add host as known, press yes
#you will be unauothorized it's ok
cp -p ~/.ssh/known_hosts known_hosts
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
```
You may exit SSH on HA box.

4. Get your ASUS router login credentials, which you will need to update your script to be able to login and fetch the cert.

3.1. Go to your asus login page

3.2. Open dev tools in Edge/Chrome browser (F12), select `Network` tab, tick the checkbox `Preserve log`. Enter login and password and you should login to your asus router panel.

3.3. Now in the list of the requests in `Network` tab choose one of the top most to `login.cgi` (POST request). For this request open `Payload` tab, press `view URL-encoded`, it should look like this:

```text
group_id: 
action_mode: 
action_script: 
action_wait: 5
current_page: Main_Login.asp
next_page: index.asp
login_authorization: THIS_IS_THE_KEY_YOU_NEED%3D
login_captcha: 
```
Copy the value from `login_authorization` field, you will need that for next step.

4. Update script

4.1. Insert the value instead of the string `!!!YOURTOKENHERE!!!` in the line 12 of the provided script `getcert.sh`.

4.2. Replace `https://router.asus.com:1443` in the script in all places with your proper router IP and port and replace `https` with `http` if you don't use SSL.

5. Copy updated script into your HA box

```bash
scp ./getcert.sh root@homeassistant.local:/config/shell_scripts/
```

6. Fully restart HA. (Shell commands and also nginx won't properly pick up otherwise).

7. Run imported `shell_command` to populate the cert for the first time.

Go to `Developer tools` -> `Services`  and Call service via YAML: `service: shell_command.update_ssl_cert`.

that should populate certs into /ssl folder of your HA instance.

8. Configure NGINX. Go to `Settings` -> `Add-ons` -> `NGINX Home Assistant SSL proxy` go to `Configuration` tab

set `Certificate file` to `cert.pem` and `Private key file` to `key.pem`. The rest is fine by deafult.

Restart NGINX and check you can access NGINX instance through your asus DDNS name.

NOT in this tutorial (pre requisite):

- In your asus router make sure fixed IP is always assigned to HA instance.
- Forward some external port, say 9999 to 443 for IP of your HA instance.

THAT should work <https://YOUR_ASUS_DDNS_NAME.asuscomm.com:9999/>

9. Add integration for certification expiration date sensor.

Go to `Settings` -> `Devices & services` then click `+ Add Integration` look for `Certificate expiry`

And add your domain name `YOUR_ASUS_DDNS_NAME.asuscomm.com` and your correct port `9999`.

10. Import blueprint [asus_router_update_ssl.yaml](./asus_router_update_ssl.yaml).

11. Add automation based on the blueprint.

You should be well set-up and ready!
