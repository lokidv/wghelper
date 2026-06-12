#!/bin/bash
sudo apt update && sudo apt upgrade -y
# Install git and make
sudo apt install -y git make

# Clone udp2raw-tunnel repository
git clone https://github.com/wangyu-/udp2raw.git udp2raw-tunnel

# Enter the udp2raw-tunnel directory
cd udp2raw-tunnel

# Install build-essential for compiling
sudo apt install -y build-essential

# Compile udp2raw
make



# Move udp2raw-tunnel directory to /usr/local/bin
sudo mv /root/udp2raw-tunnel/ /usr/local/bin/udp2raw-tunnel
# Make udp2raw executable
sudo chmod uo+x /usr/local/bin/udp2raw-tunnel/udp2raw

# Set capabilities for udp2raw
sudo setcap cap_net_raw+ep /usr/local/bin/udp2raw-tunnel/udp2raw

# Ask user to choose between Iran or Kharej server
echo "Is this for Iran server or Kharej server?"
echo "1. Iran server"
echo "2. Kharej server"
read -p "Enter your choice (1 or 2): " choice

# Part 1: Iran Server Configuration
if [[ $choice == "1" ]]; then
    # Ask for service name
    read -p "Enter the service name: " serviceName

    # Create and edit the service file
    
    # This will open the nano editor where the user can paste the provided service configuration template

    # Ask for Iran and Kharej ports and IP
    read -p "Enter Iran port: " iranPort
    read -p "Enter Kharej port: " kharejPort
    read -p "Enter Kharej IP: " kharejIP

    # Construct the service configuration with provided inputs
    serviceConfig="[Unit]
Description=Tunnel WireGuard with udp2raw
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/udp2raw-tunnel/udp2raw -c -l0.0.0.0:${kharejPort} -r\"${kharejIP}\":${iranPort} -k \"123456\" --raw-mode icmp -a --cipher-mode xor --auth-mode simple
Restart=no

[Install]
WantedBy=multi-user.target"

    # Save the constructed service configuration to the service file
    echo "${serviceConfig}" | sudo tee "/etc/systemd/system/${serviceName}.service" > /dev/null

    # Enable and start the service
    sudo systemctl enable --now "${serviceName}"




elif [[ $choice == "2" ]]; then

   read -p "Enter the service name: " serviceName
   read -p "Enter Iran port: " iranIP
    read -p "Enter Kharej port: " kharejIP

    serviceConfig="[Unit]
Description=Tunnel WireGuard with udp2raw
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/udp2raw-tunnel/udp2raw -s -l0.0.0.0:${iranIP} -r127.0.0.1:${kharejIP} -k \"123456\" --raw-mode icmp -a --cipher-mode xor --auth-mode simple
Restart=no

[Install]
WantedBy=multi-user.target"

    echo "${serviceConfig}" | sudo tee "/etc/systemd/system/${serviceName}.service" > /dev/null
    sudo systemctl enable --now "${serviceName}"


fi
