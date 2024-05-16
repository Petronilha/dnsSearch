#!/bin/bash

# Constantes para facilitar a utilização das cores.
RED='\033[31;1m'
GREEN='\033[32;1m'
GREEN_SUB='\033[32;4m'
YELLOW='\033[33;1m'
PURPLE='\033[35;1m'
RED_BLINK='\033[31;5;1m'
END='\033[0m'


if [ "$1" == "" ]
then 
        echo -e "\n\n${YELLOW}       ======== OFFESECURITY - DNSZONE-BRUTE-FORCE ======== ${END}"
        echo " "
        echo -e "${YELLOW}          Use mode: $0 domain listofname.txt ${END}"
        echo -e "${YELLOW}           Example: $0 example.com list.txt ${END}\n\n"
else
        
        echo -e "\n\n${RED} Name Servers: ${END}"
        echo -e "${RED}___________________\n${END}"
        host -t ns $1

        echo -e "\n\n${RED} Host's addresses:${END}" 
        echo -e "${RED}____________________\n${END}"
        echo $1 && host $1 | grep "has address" | cut -d " " -f4

        echo -e "\n\n${RED} Mail Servers:${END}" 
        echo -e "${RED}____________________\n${END}"
        host -t mx $1 | cut -d " " -f7 | sed "s/\.$//" > maildomain
        for domain in $(cat maildomain)
        do
                echo $domain && host $domain | cut -d " " -f4
                rm maildomain
        done
        

        echo -e "\n\n${RED} Trying Zone Transfer: ${END}"
        echo -e "${RED}___________________${END}"
        for server in $(host -t ns $1 | cut -d " " -f4)
        do
                echo -e "\n${GREEN}Trying Zone Transfer for $1 on ${GREEN_SUB}$server\n${END}"
                host -l -a $1 $server
        done
        echo " "

        #for wordlist in $(cat $2)
        #do
        #        host $3 $4 $wordlist.$1 | egrep -v "NXDOMAIN|has no CNAME|communications error" 
        #done
fi