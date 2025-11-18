#!/bin/bash
# KDE Connect Network Discovery Debugging Script
# Created: November 3, 2025
# Purpose: Diagnose why KDE Connect devices cannot find each other

echo "================================================"
echo "KDE Connect Network Discovery Debugging Script"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1"
    fi
}

# 1. Check if KDE Connect is installed
echo "1. Checking KDE Connect Installation..."
echo "----------------------------------------"
which kdeconnectd &>/dev/null
print_status "KDE Connect daemon found"

which kdeconnect-app &>/dev/null
print_status "KDE Connect app found"

echo ""

# 2. Check if KDE Connect daemon is running
echo "2. Checking KDE Connect Service Status..."
echo "----------------------------------------"
if pgrep -x "kdeconnectd" > /dev/null; then
    echo -e "${GREEN}✓${NC} KDE Connect daemon is running"
    echo "   PID: $(pgrep -x kdeconnectd)"
else
    echo -e "${RED}✗${NC} KDE Connect daemon is NOT running"
    echo -e "${YELLOW}→ Try starting it with: kdeconnectd &${NC}"
fi

echo ""

# 3. Network Information
echo "3. Network Information..."
echo "----------------------------------------"
echo "Your IP addresses:"
ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | while read ip; do
    echo "   • $ip"
done

echo ""
echo "Network interfaces:"
ip link show | grep -E '^[0-9]+:' | cut -d: -f2 | tr -d ' ' | grep -v '^lo$' | while read iface; do
    status=$(ip link show $iface | grep -oP '(?<=state )\w+')
    echo "   • $iface: $status"
done

echo ""

# 4. Firewall Status Check
echo "4. Checking Firewall Status..."
echo "----------------------------------------"

# Check if firewall is active
if command -v firewall-cmd &> /dev/null; then
    if firewall-cmd --state 2>/dev/null | grep -q running; then
        echo -e "${YELLOW}⚠${NC} Firewalld is running"
        
        # Check for KDE Connect service
        if firewall-cmd --list-services 2>/dev/null | grep -q kdeconnect; then
            echo -e "${GREEN}✓${NC} KDE Connect service is allowed in firewall"
        else
            echo -e "${RED}✗${NC} KDE Connect service is NOT allowed in firewall"
            echo -e "${YELLOW}→ Add it with: sudo firewall-cmd --add-service=kdeconnect --permanent && sudo firewall-cmd --reload${NC}"
        fi
    else
        echo -e "${GREEN}✓${NC} Firewalld is not running"
    fi
else
    echo "   Firewalld not found, checking iptables..."
    
    # Check iptables for KDE Connect ports
    if command -v iptables &> /dev/null; then
        tcp_rules=$(sudo iptables -L -n 2>/dev/null | grep -E "1714:1764" | wc -l)
        udp_rules=$(sudo iptables -L -n 2>/dev/null | grep -E "udp.*1716" | wc -l)
        
        if [ $tcp_rules -gt 0 ]; then
            echo -e "${GREEN}✓${NC} TCP ports 1714-1764 appear to be allowed"
        else
            echo -e "${YELLOW}⚠${NC} TCP ports 1714-1764 may be blocked"
        fi
        
        if [ $udp_rules -gt 0 ]; then
            echo -e "${GREEN}✓${NC} UDP port 1716 appears to be allowed"
        else
            echo -e "${YELLOW}⚠${NC} UDP port 1716 may be blocked"
        fi
    fi
fi

echo ""

# 5. Port Availability Check
echo "5. Checking Port Availability..."
echo "----------------------------------------"
echo "Checking if KDE Connect ports are in use:"

# Check TCP port 1716
if netstat -tuln 2>/dev/null | grep -q ":1716 "; then
    echo -e "${GREEN}✓${NC} Port 1716 is listening"
else
    echo -e "${YELLOW}⚠${NC} Port 1716 is not listening (KDE Connect might not be running properly)"
fi

echo ""

# 6. mDNS/Avahi Check
echo "6. Checking mDNS/Avahi Service..."
echo "----------------------------------------"
if command -v avahi-browse &> /dev/null; then
    if systemctl is-active --quiet avahi-daemon; then
        echo -e "${GREEN}✓${NC} Avahi daemon is running (mDNS discovery enabled)"
    else
        echo -e "${YELLOW}⚠${NC} Avahi daemon is not running"
        echo -e "${YELLOW}→ Start it with: sudo systemctl start avahi-daemon${NC}"
    fi
else
    echo -e "${YELLOW}⚠${NC} Avahi not installed (optional, but helps with discovery)"
fi

echo ""

# 7. Test Network Connectivity
echo "7. Network Connectivity Test..."
echo "----------------------------------------"
echo "Enter the IP address of your Android device (or press Enter to skip):"
read -r ANDROID_IP

if [ ! -z "$ANDROID_IP" ]; then
    echo "Testing connectivity to $ANDROID_IP..."
    
    # Ping test
    ping -c 1 -W 2 $ANDROID_IP &>/dev/null
    print_status "Ping to Android device"
    
    # Test KDE Connect port
    echo "Testing KDE Connect port..."
    response=$(curl -s --connect-timeout 2 $ANDROID_IP:1716 2>&1)
    
    if echo "$response" | grep -q "Empty reply"; then
        echo -e "${GREEN}✓${NC} KDE Connect port is reachable (device responded)"
    elif echo "$response" | grep -q "Connection refused"; then
        echo -e "${RED}✗${NC} Connection refused (KDE Connect might not be running on Android)"
    elif echo "$response" | grep -q "Connection timed out"; then
        echo -e "${RED}✗${NC} Connection timed out (firewall or network isolation issue)"
    else
        echo -e "${YELLOW}⚠${NC} Unexpected response: $response"
    fi
fi

echo ""

# 8. Generate Summary and Recommendations
echo "================================================"
echo "SUMMARY & RECOMMENDATIONS"
echo "================================================"
echo ""

echo "Quick Fixes to Try:"
echo "-------------------"
echo "1. Restart KDE Connect on both devices:"
echo "   Desktop: killall kdeconnectd && kdeconnectd &"
echo "   Android: Force stop app, then reopen"
echo ""
echo "2. Manually add device by IP (if network test passed):"
echo "   In KDE Connect Settings → Add Device by IP"
echo ""
echo "3. Check router settings:"
echo "   • Disable AP/Client Isolation"
echo "   • Disable Guest Mode if devices on guest network"
echo "   • Enable multicast/broadcast"
echo ""
echo "4. On Android (Xiaomi MIUI):"
echo "   • Disable battery optimization for KDE Connect"
echo "   • Enable autostart"
echo "   • Lock app in recent apps"
echo ""
echo "5. If using NixOS, ensure configuration includes:"
echo "   programs.kdeconnect.enable = true;"
echo "   networking.firewall.allowedTCPPortRanges = [{from=1714; to=1764;}];"
echo "   networking.firewall.allowedUDPPorts = [1716];"
echo ""

echo "For detailed logs, run:"
echo "   journalctl -xe | grep kdeconnect"
echo ""
echo "Script completed. Good luck!"