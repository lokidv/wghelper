##### Beta testing on v3.1
If anyone would love to try out the beta version of v3.1, you can do the following. Let me know if you encountered any issues. ;)
```
sudo apt update && sudo apt upgrade -y
apt install wireguard
apt install python3-pip
wget https://raw.githubusercontent.com/lokidv/wghelper/main/install.sh && chmod +x install.sh && ./install.sh
```

copy this file to server
```
mkdir wg
cd wg
nano wire.py
```
then copy
```
import qrcode
import subprocess

# This program will generate configs for wireguard.
# you will need to install qrcode and pillow in python
# and you need to install wireguard, so that you can call wg from your terminal

# Number of needed clients
clients = int(input("number of clients:"))
pip4 = input("public ipv4 of your relay (domestic server):")
portc = input("port:")


# Set your DNS Server like "1.1.1.1" or empty string "" if not needed
# maybe you want to use a dns server on your server e.g. 192.168.1.1
dns = "1.1.1.1"

# Set your vpn tunnel network (example is for 10.99.99.0/24)
ipnet_tunnel_1 = 172
ipnet_tunnel_2 = 16
ipnet_tunnel_3 = 0
ipnet_tunnel_4 = 0
ipnet_tunnel_cidr = 24


################### Do not edit below this line ##################

wg_priv_keys = []
wg_pub_keys = []


def main():
    # Gen-Keys
    for _ in range(clients+1):
        (privkey, pubkey) = generate_wireguard_keys()
        #psk = generate_wireguard_psk()
        wg_priv_keys.append(privkey)
        wg_pub_keys.append(pubkey)

    ################# Server-Config ##################
    server_config = "[Interface]\n" \
        f"Address =  {ipnet_tunnel_1}.{ipnet_tunnel_2}.{ipnet_tunnel_3}.{ipnet_tunnel_4+1}/{ipnet_tunnel_cidr}\n" \
        f"ListenPort = {portc}\n" \
        f"PrivateKey = {wg_priv_keys[0]}\n" \
        f"PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE\n" \
        f"PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE\n"\
        f"SaveConfig = true\n"


    for i in range(1, clients+1):
        server_config += f"[Peer]\n" \
            f"PublicKey = {wg_pub_keys[i]}\n" \
            f"AllowedIPs = {ipnet_tunnel_1}.{ipnet_tunnel_2}.{ipnet_tunnel_3}.{ipnet_tunnel_4+1+i}/32\n"

    #print("*"*10 + " Server-Conf " + "*"*10)
    #print(server_config)
    #make_qr_code_png(server_config, f"server.png")
    with open(f"server.conf", "wt") as f:
        f.write(server_config)

    ################# Client-Configs ##################
    client_configs = []
    for i in range(1, clients+1):
        client_config = f"[Interface]\n" \
            f"Address = {ipnet_tunnel_1}.{ipnet_tunnel_2}.{ipnet_tunnel_3}.{ipnet_tunnel_4+1+i}/24\n" \
            f"PrivateKey = {wg_priv_keys[i]}\n" \
            f"MTU = 1280\n"

        if dns:
            client_config += f"DNS = {dns}\n"

        client_config += f"[Peer]\n" \
            f"PublicKey = {wg_pub_keys[0]}\n" \
            f"Endpoint = {pip4}:{portc}\n" \
            f"AllowedIPs = 0.0.0.0/0, ::/0\n" \
            f"PersistentKeepalive = 25\n"


        client_configs.append(client_config)

        #print("*"*10 + f" Client-Conf {i} " + "*"*10)
        #print(client_config)
        make_qr_code_png(client_config, f"client_{i}.png")
        with open(f"client_{i}.conf", "wt") as f:
            f.write(client_config)

    #print("*"*10 + " Debugging " + "*"*10 )
    #print("*"*10 + " Priv-Keys " + "*"*10 )
    # print(wg_priv_keys)
    #print("*"*10 + " Pub-Keys " + "*"*10 )
    # print(wg_pub_keys)


def generate_wireguard_keys():
    privkey = subprocess.run(
        "wg genkey", shell=True, capture_output=True).stdout.decode("utf-8").strip()
    pubkey = subprocess.run(
        f"echo {privkey} | wg pubkey", shell=True, capture_output=True).stdout.decode("utf-8").strip()
    return (privkey, pubkey)


def make_qr_code_png(text, filename):
    img = qrcode.make(text)
    img.save(f"{filename}")


if __name__ == "__main__":
    main()
```
then run
```
pip3 install qrcode 
python3 wire.py
```

and enter 1 and ip server iran and port like 12345
 
then copy config file inside content
```
nano server.conf
```
into 
```
nano /etc/wireguard/wg0.conf
```

also enable ipv4 forwarding
```
nano /etc/sysctl.d/99-sysctl.conf
```
and do reboot


after that
```
systemctl enable --now wg-quick@wg0.service
systemctl status wg-quick@wg0
```
if you have error enter
```
apt install net-tools
ifconfig eth0
```

```
git clone -b v1.0.3 https://github.com/lokidv/WGDashboard.git wgdashboard
```

   
2. Open the WGDashboard folder

   ```shell
   cd wgdashboard/src
   ```
   
3. Install WGDashboard

```shell
 apt install gunicorn -y
sudo apt-get -y install python3-pip
pip install -r requirements.txt
apt install net-tools
ifconfig eth0
```
```
sudo chmod u+x wgd.sh
sudo ./wgd.sh install
sudo chmod -R 755 /etc/wireguard
./wgd.sh start
```
   


4. Give read and execute permission to root of the WireGuard configuration folder, you can change the path if your configuration files are not stored in `/etc/wireguard`

   ```shell
   sudo chmod -R 755 /etc/wireguard
   ```

5. Run WGDashboard

   ```shell
   ./wgd.sh start
   ```
   
 extra command 
 
 ```
 rm /root/wgdashboard/src/templates/sidebar.html
 nano /root/wgdashboard/src/templates/sidebar.html
 ```
 
 then copy code in there
 ```
<div class="row">
    <div class="row">
        <nav id="sidebarMenu" class="col-md-3 col-lg-2 d-md-block bg-light sidebar collapse">
            <div class="sidebar-sticky pt-3">
                <ul class="nav flex-column">
                    <li class="nav-item"><a class="nav-link sb-home-url" href="/">Home</a></li>
                    {% if "username" in session %}
                        <li class="nav-item"><a class="nav-link sb-settings-url" href="/settings">Settings</a></li>
                    {% endif %}
                 
                </ul>
                <hr>
                <h6 class="sidebar-heading d-flex justify-content-between align-items-center px-3 mt-4 mb-1 text-muted">
                    <span>Configurations</span>
                </h6>
                <ul class="nav flex-column">
                    {% for i in conf %}
                        <li class="nav-item"><a class="nav-link sb-{{ i['conf'] }}-url"
                                                href="/configuration/{{ i['conf'] }}"><samp>{{ i['conf'] }}</samp></a>
                        </li>
                    {% endfor %}
                </ul>
                <hr>
                <h6 class="sidebar-heading d-flex justify-content-between align-items-center px-3 mt-4 mb-1 text-muted">
                    <span>Tools</span>
                </h6>
                <ul class="nav flex-column">
                    <ul class="nav flex-column">
                        <li class="nav-item"><a class="nav-link" data-toggle="modal" data-target="#ping_modal" href="#">Ping</a>
                        </li>
                        <li class="nav-item"><a class="nav-link" data-toggle="modal" data-target="#traceroute_modal"
                                                href="#">Traceroute</a></li>
                        <li class="nav-item"><a class="nav-link" href="/backup">Backup</a></li>
                    </ul>
                </ul>
                <hr>
                {% if "username" in session %}
                    <ul class="nav flex-column">
                        <li class="nav-item"><a class="nav-link text-danger" href="/signout" style="font-weight: bold">Sign
                            Out</a></li>
                    </ul>
                {% endif %}
                <ul class="nav flex-column">
                   
                </ul>
            </div>
        </nav>
    </div>
</div>
 ```
 

 
 
   **Note**:

   > For [`pivpn`](https://github.com/pivpn/pivpn) user, please use `sudo ./wgd.sh start` to run if your current account does not have the permission to run `wg show` and `wg-quick`.

6. Access dashboard

   Access your server with port `10086` (e.g. http://your_server_ip:10086), using username `admin` and password `admin`. See below how to change port and ip that the dashboard is running with.

## 🪜 Usage

#### Start/Stop/Restart WGDashboard


```shell
cd wgdashboard/src
-----------------------------
./wgd.sh start    # Start the dashboard in background
-----------------------------
./wgd.sh debug    # Start the dashboard in foreground (debug mode)
-----------------------------
./wgd.sh stop     # Stop the dashboard
-----------------------------
./wgd.sh restart  # Restart the dasboard
```

#### Autostart WGDashboard on boot (>= v2.2)

In the `src` folder, it contained a file called `wg-dashboard.service`, we can use this file to let our system to autostart the dashboard after reboot. The following guide has tested on **Ubuntu**, most **Debian** based OS might be the same, but some might not. Please don't hesitate to provide your system if you have tested the autostart on another system.

1. Changing the directory to the dashboard's directory

   ```shell
   cd wgdashboard/src
   ```

2. Get the full path of the dashboard's directory

   ```shell
   pwd
   #Output: /root/wgdashboard/src
   ```

   For this example, the output is `/root/wireguard-dashboard/src`, your path might be different since it depends on where you downloaded the dashboard in the first place. **Copy the the output to somewhere, we will need this in the next step.**

3. Edit the service file, the service file is located in `wireguard-dashboard/src`, you can use other editor you like, here will be using `nano`

   ```shell
   nano wg-dashboard.service
   ```

   You will see something like this:

   ```ini
   [Unit]
   After=network.service
   
   [Service]
   WorkingDirectory=<your dashboard directory full path here>
   ExecStart=/usr/bin/python3 <your dashboard directory full path here>/dashboard.py
   Restart=always
   
   
   [Install]
   WantedBy=default.target
   ```

   Now, we need to replace both `<your dashboard directory full path here>` to the one you just copied from step 2. After doing this, the file will become something like this, your file might be different:

   ```ini
   [Unit]
   After=netword.service
   
   [Service]
   WorkingDirectory=/root/wgdashboard/src
   ExecStart=/usr/bin/python3 /root/wgdashboard/src/dashboard.py
   Restart=always
   
   
   [Install]
   WantedBy=default.target
   ```

   **Be aware that after the value of `WorkingDirectory`, it does not have  a `/` (slash).** And then save the file after you edited it

4. Copy the service file to systemd folder

   ```bash
   $ cp wg-dashboard.service /etc/systemd/system/wg-dashboard.service
   ```

   To make sure you copy the file successfully, you can use this command `cat /etc/systemd/system/wg-dashboard.service` to see if it will output the file you just edited.

5. Enable the service

   ```bash
   sudo chmod 664 /etc/systemd/system/wg-dashboard.service
   sudo systemctl daemon-reload
   sudo systemctl enable wg-dashboard.service
   sudo systemctl start wg-dashboard.service
   reboot
   ```

6. Check if the service run correctly

   ```bash
   sudo systemctl status wg-dashboard.service
   ```

   And you should see something like this

   ```shell
   ● wg-dashboard.service
        Loaded: loaded (/etc/systemd/system/wg-dashboard.service; enabled; vendor preset: enabled)
        Active: active (running) since Tue 2021-08-03 22:31:26 UTC; 4s ago
      Main PID: 6602 (python3)
         Tasks: 1 (limit: 453)
        Memory: 26.1M
        CGroup: /system.slice/wg-dashboard.service
                └─6602 /usr/bin/python3 /root/wgdashboard/src/dashboard.py
   
   Aug 03 22:31:26 ubuntu-wg systemd[1]: Started wg-dashboard.service.
   Aug 03 22:31:27 ubuntu-wg python3[6602]:  * Serving Flask app "WGDashboard" (lazy loading)
   Aug 03 22:31:27 ubuntu-wg python3[6602]:  * Environment: production
   Aug 03 22:31:27 ubuntu-wg python3[6602]:    WARNING: This is a development server. Do not use it in a production deployment.
   Aug 03 22:31:27 ubuntu-wg python3[6602]:    Use a production WSGI server instead.
   Aug 03 22:31:27 ubuntu-wg python3[6602]:  * Debug mode: off
   Aug 03 22:31:27 ubuntu-wg python3[6602]:  * Running on all addresses.
   Aug 03 22:31:27 ubuntu-wg python3[6602]:    WARNING: This is a development server. Do not use it in a production deployment.
   Aug 03 22:31:27 ubuntu-wg python3[6602]:  * Running on http://0.0.0.0:10086/ (Press CTRL+C to quit)
   ```

   If you see `Active:` followed by `active (running) since...` then it means it run correctly. 

7. Stop/Start/Restart the service

   ```bash
   sudo systemctl stop wg-dashboard.service      # <-- To stop the service
   sudo systemctl start wg-dashboard.service     # <-- To start the service
   sudo systemctl restart wg-dashboard.service   # <-- To restart the service
   ```

8. **And now you can reboot your system, and use the command at step 6 to see if it will auto start after the reboot, or just simply access the dashboard through your browser. If you have any questions or problem, please report it in the issue page.**

```
apt install git

apt install make

git clone https://github.com/wangyu-/udp2raw-tunnel.git
cd udp2raw-tunnel

apt install build-essential

make

cd
mv udp2raw-tunnel /usr/local/bin/udp2raw-tunnel
chmod uo+x /usr/local/bin/udp2raw-tunnel/udp2raw
setcap cap_net_raw+ep /usr/local/bin/udp2raw-tunnel/udp2raw
```
then 
```
nano /etc/systemd/system/udp2raw.service
```
and 
```
[Unit]
Description=Tunnel WireGuard with udp2raw
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/udp2raw-tunnel/udp2raw -s -l0.0.0.0:2085 -r 127.0.0.1:12345    -k "123456" --raw-mode icmp -a --cipher-mode xor --auth-mode simple
Restart=no

[Install]
WantedBy=multi-user.target
```
and 
```
systemctl enable --now udp2raw
```
/// 
in iran 
```
/usr/local/bin/udp2raw-tunnel/udp2raw -c -l0.0.0.0:1199  -r"kharej ip":2085  -k "123456" --raw-mode icmp -a --cipher-mode xor --auth-mode simple
```

for ovpn
```
sudo apt update && upgrade -y


curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh


chmod +x openvpn-install.sh


./openvpn-install.sh
```

for crontab

```
export VISUAL=nano; crontab -e

* 12 * * * reboot
0 13 * * * sudo pm2 start /home/bvpn/main.js
0 13 * * * sudo pm2 save

```



configjson

```
{
   "api": {
       "services": [
           "HandlerService",
           "LoggerService",
           "StatsService"
       ],
       "tag": "api"
   },
   "dns": {
       "servers": [
           "4.2.2.4",
           "8.8.8.8"
       ]
   },
   "inbounds": [
       {
           "listen": "127.0.0.1",
           "port": 62789,
           "protocol": "dokodemo-door",
           "settings": {
               "address": "127.0.0.1"
           },
           "tag": "api"
       }
   ],
   "log": {
       "access": "",
       "error": "",
       "loglevel": "warning",
       "dnsLog": false        
   },
   "observatory": {
       "subjectSelector": [
           "proxy-"
       ]
   },
   "outbounds": [
       {
           "protocol": "freedom",
           "settings": {
           },
           "tag": "direct"
       },
       {
           "protocol": "blackhole",
           "settings": {
               "response": {
                   "type": "http"
               }
           },
           "tag": "blocked"
       },
       {
           "protocol": "freedom",
           "settings": {
               "domainStrategy": "UseIPv4"
           },
           "tag": "IPv4"
       },
       {
        "protocol":"vless",
        "settings":{
           "vnext":[
              {
                 "address":"94.141.96.25",
                 "port":443,
                 "users":[
                    {
                       "encryption":"none",
                       "flow":"xtls-rprx-vision",
                       "id":"82f5231b-75da-4fae-942c-a9b607077093",
                       "level":0,
                       "security":"auto"
                    }
                 ]
              }
           ]
        },
        "streamSettings":{
           "network":"tcp",
           "realitySettings":{
              "allowInsecure":false,
              "fingerprint":"chrome",
              "publicKey":"Nm2Umcx2RDmILOK_5jQXfU8KlDGkOMbYrx503cJda1U",
              "serverName":"www.speedtest.net",
              "shortId":"1915c9df",
              "show":false,
              "spiderX":""
           },
           "security":"reality",
           "tcpSettings":{
              "header":{
                 "type":"none"
              }
           }
        },
        "tag":"proxy-1"
     }
   ],
   "policy": {
       "levels": {
           "0": {
               "connIdle": 300,
               "downlinkOnly": 5,
               "handshake": 4,
               "statsUserDownlink": true,
               "statsUserUplink": true,
               "uplinkOnly": 2
           }
       },
       "system": {
           "statsInboundDownlink": true,
           "statsInboundUplink": true,
           "statsOutboundDownlink": true,
           "statsOutboundUplink": true
       }
   },
   "routing": {
       "balancers": [
           {
               "selector": [
                   "proxy-"
               ],
               "strategy": {
                   "type": "random"
               },
               "tag": "loadbalance"
           }
       ],
       "rules": [
           {
               "inboundTag": [
                   "api"
               ],
               "outboundTag": "api",
               "type": "field"
           },
           {
               "ip": [
                   "geoip:private"
               ],
               "outboundTag": "blocked",
               "type": "field"
           },
           {
               "outboundTag": "blocked",
               "protocol": [
                   "bittorrent"
               ],
               "type": "field"
           },
           {
               "balancerTag": "loadbalance",
               "enabled": true,
               "port": "0-65535",
               "type": "field"
           }
       ]
   },
   "stats": {
   }
}
```
wrp

```

curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list

sudo apt-get update && sudo apt-get install cloudflare-warp

warp-cli register

warp-cli add-excluded-route "ip server iran"

warp-cli connect

قبلش هم باید توی کانفیگ وایرگاردت اسم اینترفیسو تغییر بدی به CloudflareWARP (اسم اینترفیس بعد از -o نوشته میشه و معمولا eth0)

```

wgi
```
git clone https://github.com/lokidv/wgi.git WGI && cd WGI && cp WGI.sh /root && cd && chmod +x ./WGI.sh && ./WGI.sh

```
fake wb

```
git clone https://github.com/lokidv/fake.git


apt update -y && apt upgrade -y && apt dist-upgrade -y && apt install curl socat -y && apt install certbot -y
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
sudo certbot certonly --standalone --preferred-challenges http --agree-tos --email alfiemoradi.dw@gmail.com -d account.picofile.online

apt install nginx
apt install unzip
unzip fake/html-20230820T123931Z-001.zip 
 cp -r html /var/www


 nano /etc/nginx/nginx.conf

```
conf

```
worker_processes auto;
events {
	worker_connections 1024;
}
http {
	tcp_nodelay on;
	keepalive_timeout 65;
	ssl_protocols TLSv1.2 TLSv1.3;
	ssl_prefer_server_ciphers on;
	access_log off;
	error_log off;
	
	server {
		listen 443 ssl http2;
		server_name ada1013.cloud;

		index index.html;
		root /var/www/html;
		error_page 404 /404.html;
		ssl_certificate /etc/letsencrypt/live/ada1013.cloud/fullchain.pem;
		ssl_certificate_key /etc/letsencrypt/live/ada1013.cloud/privkey.pem;
		ssl_protocols TLSv1.2 TLSv1.3;
		ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

		location /qrgb357 {
			if ($http_upgrade != "websocket") {
				return 404;
			}
				proxy_pass http://127.0.0.1:3700;
				proxy_redirect off;
				proxy_http_version 1.1;
				proxy_set_header Upgrade $http_upgrade;
				proxy_set_header Connection "upgrade";
				proxy_set_header Host $host;
				proxy_set_header X-Real-IP $remote_addr;
				proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
				proxy_read_timeout 52w;
		}
	}
	server {
        listen 80;
        server_name ada1013.cloud www.ada1013.cloud;
        return 301 https://ada1013.cloud$request_uri;
    }
}

```
then

```
nginx -s reload
```


for transfer user wire
```
sudo apt install openssh-client
```
in server b
```
rm /etc/wireguard/wg0.conf
systemctl stop wg-quick@wg0
systemctl disable wg-quick@wg0
systemctl restart wg-quick@wg0
wgdashboard/src/wgd.sh stop

wg-quick save wg0
wgdashboard/src/wgd.sh start
```
in server a
```
scp /etc/wireguard/wg0.conf root@ip:/etc/wireguard/
scp /root/wgdashboard/src/db/wgdashboard.db root@ip:/root/wgdashboard/src/db/
nano /etc/sysctl.d/99-sysctl.conf
nano /etc/systemd/system/udp2raw.service
```
netscan 
```
wget https://raw.githubusercontent.com/lokidv/wghelper/main/fire.sh && bash fire.sh
```
