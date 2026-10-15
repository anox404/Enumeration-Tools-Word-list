#!/bin/bash
# Green color
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
NC='\033[0m'

command -v nmap >/dev/null 2>&1 || { echo -e "${RED}[!] nmap install karo${NC}"; exit 1; }
command -v figlet >/dev/null 2>&1 || { echo -e "${RED}[!] figlet install karo${NC}"; exit 1; }

clear

echo -e "${YELLOW}"
figlet -f slant "SCANNER"
echo -e "${NC}"

echo -e "${GREEN}Version : 1.0${NC}"
echo -e "${RED}MODE${NC}"

echo -e "${BLUE}1. SYN Scan${NC}"  # Stealth SYN scan
echo -e "${BLUE}2. TCP scan${NC}"  # Full TCP connection scan.
echo -e "${BLUE}3. UDP scan${NC} "  # Scans UDP ports.
echo -e "${BLUE}4. Ping scan${NC} " # Checks if the host is online.
echo -e "${BLUE}5. FIN scan${NC} "  # Uses FIN packets to probe ports.
echo -e "${BLUE}6. NULL Scan${NC} " # Sends packets with no TCP flags
echo -e "${BLUE}7. Xmas scan${NC} " # Sends FIN, PSH, and URG flags.
echo -e "${BLUE}8. ACK scan${NC} "  # Detects firewall filtering rules.
echo -e "${BLUE}9. OS Scan${NC} "   # Attempts to detect the operating system.
echo -e "${BLUE}10. Aggressive Scan${NC} " # Attempts to detect the operating system.
echo -e "${BLUE}11. Script Scan${NC} "     # Runs NSE scripts for additional checks.
echo -e "${BLUE}12. Prot scan ${NC} "
echo -e "${RED}00 exit${NC}"

# === ASK TARGET FIRST ===
echo -ne "${PURPLE}Enter target IP/host: ${NC}" && read TARGET
if [[ -z "$TARGET" ]]; then
    echo -e "${RED}[!] No target specified. Exiting.${NC}"
    exit 1
fi

echo -ne "${PURPLE}Enter your SCAN Mode: ${NC}" && read CHOICE

case $CHOICE in
    1)
        echo -e "${GREEN}[+] Running SYN Scan...${NC}"
        sudo nmap -sS -sV -T4 --open -oN syn.txt "$TARGET"
        ;;
    2)
        echo -e "${GREEN}[+] Running TCP Scan...${NC}"
        sudo nmap -sT -sV -T4 --open -oN tcp.txt "$TARGET"
        ;;
    3)
        echo -e "${GREEN}[+] Running UDP Scan...${NC}"
        sudo nmap -sU  --top-ports 100 -T4 --open -oN upd.txt "$TARGET"
        ;;
    4)  
        echo -e "${GREEN}[+] Running PING Scan...${NC}"
        sudo nmap -sn -T4 -oN ping.txt "$TARGET"
        ;;
    5)
        echo -e "${GREEN}[+] Running FIN Scan...${NC}"
        sudo nmap -sF -T4 --open -oN fin.txt "$TARGET"
        ;;
    6)
        echo -e "${GREEN}[+] Running NULL Scan...${NC}"
        sudo nmap -sN -T4 --open -oN Null.txt "$TARGET"
        ;;        
    7)
        echo -e "${GREEN}[+] Running XMAS Scan...${NC}"
        sudo nmap -sX -T4 --open -oN xmas.txt "$TARGET"
        ;;
    8)
        echo -e "${GREEN}[+] Running ACK Scan...${NC}"
        sudo nmap -sA -T4 --open -oN ack.txt "$TARGET"
        ;;
    9)
        echo -e "${GREEN}[+] Running OS Scan...${NC}"
        sudo nmap -O -sV -T4 --open -oN os.txt "$TARGET"
        ;;    
    10)
        echo -e "${GREEN}[+] Running AGGRESSIVE Scan...${NC}"
        sudo nmap -A -T4 --open -oN aggressive.txt "$TARGET"
        ;;
    11)
        echo -e "${GREEN}[+] Running SCRIPT Scan...${NC}"
        sudo nmap -sC -sV -T4 --open -oN script.txt "$TARGET"
        ;;        
     12)
        echo -e "${GREEN}[+] Running PORT&VERSION Scan...${NC}"
        sudo nmap -p 1-65535 -sV -T4 --open -oN port.txt "$TARGET"
        ;;
 00|0)
        echo -e "${YELLOW}[+] Exiting. Goodbye.${NC}"
        exit 0
        ;;
   *)
        echo -e "${RED}[!] Invalid option: $CHOICE${NC}"
        echo -e "${YELLOW}  Choose 1-12 or 00 to exit.${NC}"
        exit 1
        ;;
  esac

echo -e "${GREEN}[✓] Scan complete. Results saved in current directory. ${NC}"
        
