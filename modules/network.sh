#!/usr/bin/env bash
#
# LIA Network Diagnostic Module
#
# Linux Incident Analyzer
#
# Version: 1.0.0
#
# Purpose:
#   Network health analysis for Linux systems.
#
# Checks:
#   - Network interfaces
#   - IP configuration
#   - Routes
#   - DNS
#   - Connectivity
#   - TCP connections
#   - Listening ports
#   - Recommendations
#


#######################################
# Network Interfaces
#######################################

network_interfaces()
{

    print_subsection "Network Interfaces"


    if command -v ip >/dev/null 2>&1
    then

        ip -brief address


    else

        print_warning "ip command unavailable"

    fi


    echo


    if command -v ip >/dev/null 2>&1
    then

        local errors

        errors=$(ip -s link | \
        awk '/RX:|TX:/ {getline; if ($1>0) print}' || true)


        if [[ -n "${errors}" ]]
        then

            print_status \
            "WARNING" \
            "Network interface errors detected"

        else

            print_status \
            "OK" \
            "No interface errors detected"

        fi

    fi


    echo

}



#######################################
# Routing Information
#######################################

network_routes()
{

    print_subsection "Routing Table"


    if command -v ip >/dev/null 2>&1
    then

        ip route


        echo


        local gateway


        gateway=$(ip route | awk '/default/ {print $3; exit}')


        if [[ -n "${gateway}" ]]
        then

            print_status \
            "OK" \
            "Default gateway detected: ${gateway}"

        else

            print_status \
            "WARNING" \
            "No default gateway configured"

        fi


    fi


    echo

}



#######################################
# DNS Analysis
#######################################

network_dns()
{

    print_subsection "DNS Configuration"


    if [[ -f /etc/resolv.conf ]]
    then

        grep -v "^#" /etc/resolv.conf


        local dns


        dns=$(grep nameserver /etc/resolv.conf | wc -l)


        if (( dns > 0 ))
        then

            print_status \
            "OK" \
            "DNS servers configured"

        else

            print_status \
            "WARNING" \
            "No DNS servers configured"

        fi


    fi


    echo

}



#######################################
# Connectivity Test
#######################################

network_connectivity()
{

    print_subsection "Connectivity Test"


    local target="8.8.8.8"


    if command -v ping >/dev/null 2>&1
    then


        if ping -c 2 -W 2 "${target}" >/dev/null 2>&1
        then

            print_status \
            "OK" \
            "External connectivity available"


        else

            print_status \
            "WARNING" \
            "Unable to reach ${target}"

        fi


    else

        print_warning "ping command unavailable"

    fi


    echo

}



#######################################
# TCP Connections
#######################################

network_connections()
{

    print_subsection "Active Connections"


    if command -v ss >/dev/null 2>&1
    then

        ss -tunap \
        | head -20


    else

        print_warning "ss command unavailable"

    fi


    echo

}



#######################################
# Listening Ports
#######################################

network_ports()
{

    print_subsection "Listening Ports"


    if command -v ss >/dev/null 2>&1
    then


        ss -tulnp


    else

        print_warning "ss command unavailable"

    fi


    echo

}



#######################################
# Recommendations
#######################################

network_recommendations()
{

    print_subsection "Recommendations"


    print_info \
    "Investigate interface errors when packet loss occurs"


    print_info \
    "Validate DNS resolution during application failures"


    print_info \
    "Review listening services exposed on unexpected ports"


}



#######################################
# Main Network Module
#######################################

network()
{

    print_section "NETWORK ANALYSIS"


    network_interfaces

    network_routes

    network_dns

    network_connectivity

    network_connections

    network_ports

    network_recommendations

}
