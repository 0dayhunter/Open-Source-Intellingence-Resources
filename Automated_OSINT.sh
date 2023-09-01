#!/bin/bash
# 
# Reqirements:    gowitness install  >> $ go install github.com/sensepost/gowitness@latest
#               httprobe  install  >> $ sudo apt install httprobe
#           assetfinder install  >> $ sudo apt install assetfinder
#
# Check for the required argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

domain="$1"
RED="\033[1;31m"
RESET="\033[0m"

info_path="$domain/info"
subdomain_path="$domain/subdomains"
screenshot_path="$domain/screenshots"

# Create necessary directories if they don't exist
mkdir -p "$domain" "$info_path" "$subdomain_path" "$screenshot_path"

# Custom banner
echo -e "${RED}*********************************************************"
echo -e "*     ___      _             _                 _              *"
echo -e "*    / _ \  __| | __ _ _   _| |__  _   _ _ __ | |_ ___ _ __   *"
echo -e "*   | | | |/ _` |/ _` | | | | '_ \| | | | '_ \| __/ _ \ '__|  *"
echo -e "*   | |_| | (_| | (_| | |_| | | | | |_| | | | | ||  __/ |     *"
echo -e "*    \___/ \__,_|\__,_|\__, |_| |_|\__,_|_| |_|\__\___|_|     *"
echo -e "*                                   |___/                     *"
echo -e "*                                                             *"
echo -e "*           Support:https://github.com/0dayhunter/            *"
echo -e "*                                                             *"
echo -e "*                Domain Reconnaissance Script                 *"
echo -e "***************************************************************"
echo -e "Welcome to the Domain Reconnaissance Script!"
echo -e "Running reconnaissance for domain: $domain"
echo -e "${RESET}"

echo -e "${RED} [+] Checking whois information...${RESET}"
whois "$domain" > "$info_path/whois.txt"

echo -e "${RED} [+] Launching subfinder...${RESET}"
subfinder -d "$domain" > "$subdomain_path/found.txt"

echo -e "${RED} [+] Running assetfinder...${RESET}"
assetfinder "$domain" | grep "$domain" >> "$subdomain_path/found.txt"

# Uncomment the following lines if you want to use Amass
# echo -e "${RED} [+] Running Amass. This could take a while...${RESET}"
# amass enum -d "$domain" >> "$subdomain_path/found.txt"

echo -e "${RED} [+] Checking which subdomains are alive...${RESET}"
cat "$subdomain_path/found.txt" | grep "$domain" | sort -u | httprobe -prefer-https | grep https | sed 's/https\?:\/\///' | tee -a "$subdomain_path/alive.txt"

echo -e "${RED} [+] Taking screenshots of live subdomains...${RESET}"
gowitness file -f "$subdomain_path/alive.txt" -P "$screenshot_path/" --no-http

echo -e "${RED} [+] Domain reconnaissance completed.${RESET}"
