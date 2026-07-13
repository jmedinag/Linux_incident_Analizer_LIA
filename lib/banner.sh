#!/usr/bin/env bash
#
# LIA Banner
#
# Linux Incident Analyzer
#


print_banner()
{

    local name="$1"
    local version="$2"


    echo -e "${CYAN}${BOLD}"

    cat << "EOF"

      ___                   ___     
     /\__\      ___        /\  \    
    /:/  /     /\  \      /::\  \   
   /:/  /      \:\  \    /:/\:\  \  
  /:/  /       /::\__\  /::\~\:\  \ 
 /:/__/     __/:/\/__/ /:/\:\ \:\__\
 \:\  \    /\/:/  /    \/__\:\/:/  /
  \:\  \   \::/__/          \::/  / 
   \:\  \   \:\__\          /:/  /  
    \:\__\   \/__/         /:/  /   
     \/__/                 \/__/    
                                    
                Javier Medina 2026  
                                    
                                    
EOF

    echo -e "${RESET}"


    echo -e "${WHITE}${BOLD}${name}${RESET}"
    echo -e "${WHITE}Version:${RESET} ${version}"
    echo -e "${WHITE}Mode:${RESET} Incident Analysis"

    echo ""

}
