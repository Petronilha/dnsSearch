#!/bin/bash

################################################################################
# Titulo    : DNS SERVER                                                       #
# Versao    : 1.0                                                              #
# Data      : 17/05/2024                                                       #
# GitHub  : https://github.com/Petronilha/dnsSearch                            #
# Tested on : Ubuntu/Linux                                                     #
# -----------------------------------------------------------------------------#
# Description:                                                                 #
#   This program has the function of searching for all links that can be       #
#   considered useful for analysis, and check which of them are active         #
#                                                                              #
################################################################################

# ==============================================================================
# Constants
# ==============================================================================

# Constants to facilitate the use of colors
RED='\033[31;1m'
GREEN='\033[32;1m'
GREEN_SUB='\033[32;4m'
YELLOW='\033[33;1m'
YELLOW_BLINK='\033[33;5;1m'
PURPLE='\033[35;1m'
RED_BLINK='\033[31;5;1m'
END='\033[0m'

# Constants created using argument values
# Passed, to avoid losing values
ARG01="${1}"
ARG02="${2}"
ARG03="${3}"
ARG04="${4}"

# Constant used to store the program version
VERSION='1.1'

# ==============================================================================
#                           Banner of program
# ------------------------------------------------------------------------------
# Function responsible for just showing the program banner along with some
# Basic options.
# ==============================================================================
__Banner__() {
        echo -e "
        ${YELLOW_BLINK}
        ################################################################################
        #                                                                              #
        #                             DNS SEARCH                                       #
        #                             Version ${VERSION}                                      #
        #                                                                              #
        ################################################################################
        ${END}

        Usage   : ${GREEN}${0}${END} [OPTION] [URL]
        Example : ${GREEN}${0}${END} [OPTION] www.site.com

        Try ${GREEN}${0} -h${END} for more options.\n\n"
}

__initial__() {
        echo -e "${GREEN}
    ###################################################################################    
    #             ____  _   _ ____    ____  _____    _    ____   ____ _   _           #  
    #            |  _ \| \ | / ___|  / ___|| ____|  / \  |  _ \ / ___| | | |          #  
    #            | | | |  \| \___ \  \___ \|  _|   / _ \ | |_) | |   | |_| |          #
    #            | |_| | |\  |___) |  ___) | |___ / ___ \|  _ <| |___|  _  |          #
    #            |____/|_| \_|____/  |____/|_____/_/   \_\_| \_\\____ |_| |_|          #
    #            ____________________________________________________________         #                                 
    ###################################################################################${END}"
}
# ==============================================================================
#                                Help menu
# ------------------------------------------------------------------------------
# Function responsible for explaining to the user the purpose of the program and how
# it works, showing all your options.
# ==============================================================================

__Help__() {
        echo -e "
    NAME
        ${0} - DNS mapping software.

    SYNOPSIS
        ${0} [Options] [URL]

    DESCRIPTION
        ${0} is used to map all host areas, Mail Servers, Name Servers, IP mapping, etc.

    OPTIONS
        -h, --help
            Shows the help menu.

        -v, --version
            Shows the program version.

        -a, --address
            Show host IP.
                Ex: ${0} exemplo.com --address

        -m, --mailserver
            Show e-mail subdomain.
        
        -n, --nameserver
            Shows server names.
                Ex: ${0} exemplo.com --nameserver

        -z, --zonetransfer
            Searches for information on servers and domains associated with
            the main domain.
                Ex: s{0} exemplo.com --zonetransfer
                
        -all, --allcommand
            Executes all previous commands.
                Ex: s{0} exemplo.com -all \n"

}

# Searching host address
__HostAddress__() {

        echo -e "\n\n${RED} Host's addresses:${END}"
        echo -e "${RED}____________________\n${END}"
        for ip in $(host "${ARG02}" | grep "has address" | cut -d " " -f4); do
                echo -e "${ARG02} -----> ${YELLOW}"${ip}"${END}\n"
        done
}

# Searching names servers
__NameServer__() {

        echo -e "\n\n${RED} Name Servers: ${END}"
        echo -e "${RED}___________________\n${END}"
        host -t ns "${ARG02}"
        echo " "
}

# Searching mail server
__MailServer__() {

        echo -e "\n\n${RED} Mail Servers:${END}"
        echo -e "${RED}____________________\n${END}"
        host -t mx "${ARG02}" | cut -d " " -f7 | sed "s/\.$//" >maildomain
        for domain in $(cat maildomain); do
                for mailIp in $(host $domain | cut -d " " -f4); do
                        echo -e ""${domain}" -----> ${YELLOW}"${mailIp}"${END}\n"
                done
                rm maildomain
        done
}

# Trying zone transfer
__ZoneTransfer__() {

        echo -e "\n\n${RED} Trying Zone Transfer: ${END}"
        echo -e "${RED}___________________${END}"
        for server in $(host -t ns "${ARG02}" | cut -d " " -f4); do
                echo -e "\n${GREEN}Trying Zone Transfer for "${ARG02}" on ${GREEN_SUB}$server\n${END}"
                host -l -a "${ARG02}" $server | egrep -v "REFUSED"
        done
        echo " "
}

# Make a brute force subdomains.
#__WordList__() {

#for wordlist in $(cat "${ARG02}"); do
#       host "${ARG03}" "${ARG04}" $wordlist."${ARG01}" | egrep -v "NXDOMAIN|has no CNAME|communications error"
#done
#}

__Verification__() {
        if [[ "${ARG01}" == "" ]]; then
                __Banner__
                exit 1
        fi
}

__Main__() {
        __Verification__
        __initial__

        case "${ARG01}" in
        "-v" | "--version")
                echo -e "\nVersion: ${VERSION}\n"
                exit 0
                ;;
        "-h" | "--help")
                __Help__
                exit 0
                ;;
        "-a" | "--address")
                __HostAddress__
                ;;
        "-n" | "--nameserver")
                __NameServer__
                ;;
        "-m" | "--mailserver")
                __MailServer__
                ;;
        "-z" | "--zonetransfer")
                __ZoneTransfer__
                ;;
        "-all" | "--allcommand")
                __HostAddress__
                __MailServer__
                __NameServer__
                __ZoneTransfer__
                ;;
        esac
}

# ==============================================================================
# Start of the program
# ==============================================================================

__Main__
