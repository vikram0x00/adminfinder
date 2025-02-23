#!/bin/bash

# Color and formatting variables
BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# Print ASCII Art
echo -e "${BOLD}${GREEN}"
cat << "EOF"
    ___    ____  __  ________   __   ___________   ______  __________ 
   /   |  / __ \/  |/  /  _/ | / /  / ____/  _/ | / / __ \/ ____/ __ \
  / /| | / / / / /|_/ // //  |/ /  / /_   / //  |/ / / / / __/ / /_/ /
 / ___ |/ /_/ / /  / // // /|  /  / __/ _/ // /|  / /_/ / /___/ _, _/ 
/_/  |_/_____/_/  /_/___/_/ |_/  /_/   /___/_/ |_/_____/_____/_/ |_|  
                                                                      
EOF
echo -e "${RESET}"

# Print credit line
echo -e "\n${BOLD}${GREEN}Built by https://github.com/vikram0x00${RESET}\n"

# Prompt user for URL
read -p "Enter target URL (without http/https): " domain
domain=$(echo "$domain" | sed -E 's/https?:\/\///g')

subdomains_file="subdomains.txt"
paths_file="paths.txt"

check_url() {
    local url=$1
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url")
    
    if [[ $status_code =~ ^(200|401)$ ]]; then
        echo "${BOLD}${GREEN}${status_code}${RESET} ${url} ${BOLD}${GREEN}[FOUND]${RESET}"
    else
        echo "${BOLD}${GREEN}${status_code}${RESET} ${url} ${BOLD}${RED}[NOT FOUND]${RESET}"
    fi
}

# Check subdomains
echo -e "\nChecking subdomains:"
if [[ -f $subdomains_file ]]; then
    while IFS= read -r sub || [[ -n "$sub" ]]; do
        check_url "http://${sub}.${domain}"
        check_url "https://${sub}.${domain}"
    done < "$subdomains_file"
else
    echo "Subdomains file missing!"
fi

# Check paths (fixed section)
echo -e "\nChecking paths:"
if [[ -f $paths_file ]]; then
    while IFS= read -r path || [[ -n "$path" ]]; do
        # Ensure path starts with a slash
        [[ "$path" != /* ]] && path="/$path"
        check_url "http://${domain}${path}"
        check_url "https://${domain}${path}"
    done < "$paths_file"
else
    echo "Paths file missing!"
fi
