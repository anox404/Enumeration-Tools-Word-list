#!/bin/bash
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
BLUE='\033[1;34m'
NC='\033[0m'

clear

echo -e "${GREEN}"
figlet -f slant "SAFEPASS"
echo -e "                                    
                                              ${BLUE}Version: 1:0 ${NC}"
echo -e "${NC}"


echo -ne "${PURPLE} Enter your password : ${NC}" &&  read password
 
 if [[ ${#password} -ge 8 ]]; then
    if [[ "$password" =~ [a-z] ]]; then
        if [[ "$password" =~ [A-Z] ]]; then
            if [[ "$password" =~ [0-9] ]]; then
                if [[ "$password" =~ [^a-zA-Z0-9] ]]; then
                    echo "Strong password"
                else
                    echo "Special character missing"
                fi
            else
                echo "Number missing"
            fi
        else
            echo "Uppercase missing"
        fi
    else
        echo "Lowercase missing"
    fi
else
    echo "Password too short"
fi
 
 
