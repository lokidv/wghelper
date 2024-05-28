#!/bin/bash

# Function to prompt for port and validate input
get_port() {
    local port
    while true; do
        read -p "Enter port number to allow: " port
        if [[ $port =~ ^[0-9]+$ ]] && [ $port -ge 1 ] && [ $port -le 65535 ]; then
            echo $port
            return
        else
            echo "Invalid port number. Please enter a number between 1 and 65535."
        fi
    done
}

# Change SSH port to 6969
sed -i 's/^#Port 22/Port 6969/' /etc/ssh/sshd_config
sed -i 's/^Port 22/Port 6969/' /etc/ssh/sshd_config

# Restart SSH service
systemctl restart sshd

# Apply iptables rules for TCP
iptables -A OUTPUT -p tcp -s 0/0 -d 0.0.0.0/8 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 10.0.0.0/8 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 100.64.0.0/10 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 169.254.0.0/16 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 172.16.0.0/12 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 192.0.0.0/24 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 192.0.2.0/24 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 192.88.99.0/24 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 192.168.0.0/16 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 198.18.0.0/15 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 198.51.100.0/24 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 203.0.113.0/24 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 224.0.0.0/4 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 240.0.0.0/4 -j DROP

# Apply iptables rules for UDP
iptables -A OUTPUT -p udp -s 0/0 -d 0.0.0.0/8 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 10.0.0.0/8 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 100.64.0.0/10 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 169.254.0.0/16 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 172.16.0.0/12 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 192.0.0.0/24 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 192.0.2.0/24 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 192.88.99.0/24 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 192.168.0.0/16 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 198.18.0.0/15 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 198.51.100.0/24 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 203.0.113.0/24 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 224.0.0.0/4 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 240.0.0.0/4 -j DROP

echo "SSH port changed to 6969 and iptables rules applied."

# Install ufw
apt-get update
apt-get install -y ufw

# Enable ufw
ufw enable

# Prompt for ports to allow
port1=$(get_port)
port2=$(get_port)

# Allow the specified ports
ufw allow $port1
ufw allow $port2

echo "Ports $port1 and $port2 are allowed in ufw."
