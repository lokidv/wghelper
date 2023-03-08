##### Beta testing on v3.1
If anyone would love to try out the beta version of v3.1, you can do the following. Let me know if you encountered any issues. ;)
```
sudo apt update && upgrade -y
apt install wireguard
apt install python3-pip
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
git clone https://github.com/lokidv/wgdashboard.git
```
> Please note that I still do push on this branch, and it might crash or not finish yet on some functionality ;)
##### Known issue on WGDashboard `v3.0 - v3.0.6`
- [IPv6 in WireGuard might not fully support.]()
<hr>

<p align="center">
  <img alt="WGDashboard" src="img/logo.png" width="128">
</p>
<h1 align="center">WGDashboard</h1>


<p align="center">
  <img src="http://ForTheBadge.com/images/badges/made-with-python.svg">
</p>

<p align="center">Monitoring WireGuard is not convinient, need to login into server and type <code>wg show</code>. That's why this platform is being created, to view all configurations and manage them in a easier way.</p>
<p align="center"><small>Note: This project is not affiliate to the official WireGuard Project ;)</small></p>

## 📣 What's New: v3.0

- 🎉  **New Features**
  - **Moved from TinyDB to SQLite**: SQLite provide a better performance and loading speed when getting peers! Also avoided crashing the database due to **race condition**.
  - **Added Gunicorn WSGI Server**: This could provide more stable on handling HTTP request, and more flexibility in the future (such as HTTPS support). **BIG THANKS to @pgalonza :heart:**
  - **Add Peers by Bulk:** User can add peers by bulk, just simply set the amount and click add.
  - **Delete Peers by Bulk**: User can delete peers by bulk, without deleting peers one by one.
  - **Download Peers in Zip**: User can download all *downloadable* peers in a zip.
  - **Added Pre-shared Key to peers:** Now each peer can add with a pre-shared key to enhance security. Previously added peers can add the pre-shared key through the peer setting button.
  - **Redirect Back to Previous Page:** The dashboard will now redirect you back to your previous page if the current session got timed out and you need to sign in again.
  - **Added Some [🥘 Experimental Functions](#-experimental-functions)** 
  
  - **And many other bugs provided by our beloved users** :heart:
- **🧐  Other Changes**
  - **Key generating moved to front-end**: No longer need to use the server's WireGuard to generate keys, thanks to the `wireguard.js` from the [official repository]
  - **Peer transfer calculation**: each peer will now show all transfer amount (previously was only showing transfer amount from the last configuration start-up).
  - **UI adjustment on running peers**: peers will have a new style indicating that it is running.
  - **`wgd.sh` finally can update itself**: So now user could update the whole dashboard from `wgd.sh`, with the `update` command.
  - **Minified JS and CSS files**: Although only a small changes on the file size, but I think is still a good practice to save a bit of bandwidth ;)

*And many other small changes for performance and bug fixes! :laughing:*

>  If you have any other brilliant ideas for this project, please shout it in here [#129]

**For users who is using `v2.x.x` please be sure to read [this](#please-note-for-user-who-is-using-v231-or-below) before updating WGDashboard ;)**

<hr>

## Table of Content


- [💡  Features](#-features)
- [📝  Requirement](#-requirement)
- [🛠  Install](#-install)
- [🪜  Usage](#-usage)
  - [Start/Stop/Restart WGDashboard](#startstoprestart-wgdashboard)
  - [Autostart WGDashboard on boot](#autostart-wgdashboard-on-boot--v22)
- [✂️  Dashboard Configuration](#%EF%B8%8F-dashboard-configuration)
  - [Dashboard Configuration file](#dashboard-configuration-file)
  - [Generating QR code and peer configuration file (.conf)](#generating-qr-code-and-peer-configuration-file-conf)
- [❓  How to update the dashboard?](#-how-to-update-the-dashboard)
- [🥘 Experimental Functions](#-experimental-functions)
- [🔍  Screenshot](#-screenshot)
- [⏰  Changelog](#--changelog)
- [🛒  Dependencies](#-dependencies)
- [✨  Contributors](#-contributors)

## 💡 Features

- **No need to re-configure existing WireGuard configuration! It can search for existed configuration files.**
- Easy to use interface, provided username and password protection to the dashboard
- Add peers and edit (Allowed IPs, DNS, Private Key...)
- View peers and configuration real time details (Data Usage, Latest Handshakes...)
- Share your peer configuration with QR code or file download
- Testing tool: Ping and Traceroute to your peer's ip
- **And more functions are coming up!**



- **WireGuard** and **WireGuard-Tools (`wg-quick`)**  are installed.

  > Don't know how? Check this <a href="https://www.wireguard.com/install/">official documentation</a>

- Configuration files under **`/etc/wireguard`**, but please note the following sample

  ```ini
  [Interface]
  ...
  SaveConfig = true
  # Need to include this line to allow WireGuard Tool to save your configuration, 
  # or if you just want it to monitor your WireGuard Interface and don't need to
  # make any changes with the dashboard, you can set it to false.
  
  [Peer]
  PublicKey = abcd1234
  AllowedIPs = 1.2.3.4/32
  # Must have for each peer
  ```

- Python 3.7+ & Pip3

- Browser support CSS3 and ES6

## 🛠 Install
1. Download WGDashboard

   ```shell
   git clone -b v3.0.6 https://github.com/lokidv/pwg.git wgdashboard
   
2. Open the WGDashboard folder

   ```shell
   cd wgdashboard/src
   ```
   
3. Install WGDashboard

   ```shell
   sudo chmod u+x wgd.sh
   sudo ./wgd.sh install
   ```

4. Give read and execute permission to root of the WireGuard configuration folder, you can change the path if your configuration files are not stored in `/etc/wireguard`

   ```shell
   sudo chmod -R 755 /etc/wireguard
   ```

5. Run WGDashboard

   ```shell
   ./wgd.sh start
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
   $ sudo chmod 664 /etc/systemd/system/wg-dashboard.service
   $ sudo systemctl daemon-reload
   $ sudo systemctl enable wg-dashboard.service
   $ sudo systemctl start wg-dashboard.service  # <-- To start the service
   ```

6. Check if the service run correctly

   ```bash
   $ sudo systemctl status wg-dashboard.service
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

## ✂️ Dashboard Configuration

#### Dashboard Configuration file

Since version 2.0, WGDashboard will be using a configuration file called `wg-dashboard.ini`, (It will generate automatically after first time running the dashboard). More options will include in future versions, and for now it included the following configurations:

|                              | Description                                                  | Default                                              | Edit Available |
| ---------------------------- | ------------------------------------------------------------ | ---------------------------------------------------- | -------------- |
| **`[Account]`**              | *Configuration on account*                                   |                                                      |                |
| `username`                   | Dashboard login username                                     | `admin`                                              | Yes            |
| `password`                   | Password, will be hash with SHA256                           | `admin` hashed in SHA256                             | Yes            |
|                              |                                                              |                                                      |                |
| **`[Server]`**               | *Configuration on dashboard*                                 |                                                      |                |
| `wg_conf_path`               | The path of all the Wireguard configurations                 | `/etc/wireguard`                                     | Yes            |
| `app_ip`                     | IP address the dashboard will run with                       | `0.0.0.0`                                            | Yes            |
| `app_port`                   | Port the the dashboard will run with                         | `10086`                                              | Yes            |
| `auth_req`                   | Does the dashboard need authentication to access, if `auth_req = false` , user will not be access the **Setting** tab due to security consideration. **User can only edit the file directly in system**. | `true`                                               | **No**         |
| `version`                    | Dashboard Version                                            | `v3.0.6`                                             | **No**         |
| `dashboard_refresh_interval` | How frequent the dashboard will refresh on the configuration page | `60000ms`                                            | Yes            |
| `dashboard_sort`             | How configuration is sorting                                 | `status`                                             | Yes            |
|                              |                                                              |                                                      |                |
| **`[Peers]`**                | *Default Settings on a new peer*                             |                                                      |                |
| `peer_global_dns`            | DNS Server                                                   | `1.1.1.1`                                            | Yes            |
| `peer_endpoint_allowed_ip`   | Endpoint Allowed IP                                          | `0.0.0.0/0`                                          | Yes            |
| `peer_display_mode`          | How peer will display                                        | `grid`                                               | Yes            |
| `remote_endpoint`            | Remote Endpoint (i.e where your peers will connect to)       | *depends on your server's default network interface* | Yes            |
| `peer_mtu`                   | Maximum Transmit Unit                                        | `1420`                                               |                |
| `peer_keep_alive`            | Keep Alive                                                   | `21`                                                 | Yes            |

#### Generating QR code and peer configuration file (.conf)

Starting version 2.2, dashboard can now generate QR code and configuration file for each peer. Here is a template of what each QR code encoded with and the same content will be inside the file:

```ini
[Interface]
PrivateKey = QWERTYUIOPO234567890YUSDAKFH10E1B12JE129U21=
Address = 0.0.0.0/32
DNS = 1.1.1.1

[Peer]
PublicKey = QWERTYUIOPO234567890YUSDAKFH10E1B12JE129U21=
AllowedIPs = 0.0.0.0/0
Endpoint = 0.0.0.0:51820
```

|                   | Description                                                  | Default Value                                                | Available in Peer setting |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------- |
| **`[Interface]`** |                                                              |                                                              |                           |
| `PrivateKey`      | The private key of this peer                                 | Private key generated by WireGuard (`wg genkey`) or provided by user | Yes                       |
| `Address`         | The `allowed_ips` of your peer                               | N/A                                                          | Yes                       |
| `DNS`             | The DNS server your peer will use                            | `1.1.1.1` - Cloud flare DNS, you can change it when you adding the peer or in the peer setting. | Yes                       |
| **`[Peer]`**      |                                                              |                                                              |                           |
| `PublicKey`       | The public key of your server                                | N/A                                                          | No                        |
| `AllowedIPs`      | IP ranges for which a peer will route traffic                | `0.0.0.0/0` - Indicated a default route to send all internet and VPN traffic through that peer. | Yes                       |
| `Endpoint`        | Your wireguard server ip and port, the dashboard will search for your server's default interface's ip. | `<your server default interface ip>:<listen port>`           | Yes                       |

## ❓ How to update the dashboard?

#### **Please note for user who is using `v2.3.1` or below**

- For user who is using `v2.3.1` or below, please notice that all data that stored in the current database will **not** transfer to the new database. This is hard decision to move from TinyDB to SQLite. But SQLite does provide a thread-safe access and TinyDB doesn't. I couldn't find a safe way to transfer the data, so you need to do them manually... Sorry about that :pensive: . But I guess this would be a great start for future development :sunglasses:.

<hr>

#### Update Method 1 (For `v3.0` or above)

1. Change your directory to `wgdashboard/src`

   ```bash
   cd wgdashboard/src
   ```

2. Update the dashboard with the following

   ```bash
   ./wgd.sh update
   chmod +x ./wgd.sh
   ```

   > If this doesn't work, please use the method below. Sorry about that :(

#### Update Method 2


1. Change your directory to `wgdashboard` 
   
    ```shell
    cd wgdashboard/src
    ```
    
2. Update the dashboard
    ```shell
    git pull https://github.com/donaldzou/WGDashboard.git v3.0.6 --force
    ```

3. Install

   ```shell
   ./wgd.sh install
   ```



Starting with `v3.0`, you can simply do `./wgd.sh update` !! (I hope, lol)

## 🥘 Experimental Functions

#### Progressive Web App (PWA) for WGDashboard

- With `v3.0`, I've added a `manifest.json` into the dashboard, so user could add their dashboard as a PWA to their browser or mobile device.

<img src="img/PWA.gif"/>



## 🔍 Screenshot

![Sign In Page](img/SignIn.png)

![Index Image](img/HomePage.png)

![Configuration](img/Configuration.png)

![Add Peer](img/AddPeer.png)

![Edit Peer](img/EditPeer.png)

![Delete Peer](img/DeleteBulk.png)

![Dashboard Setting](img/DashboardSetting.png)

![Ping](img/Ping.png)

![Traceroute](img/Traceroute.png)

