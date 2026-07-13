#!/usr/bin/env bash
#
# LIA System Module
#


system()
{

    print_section "SYSTEM INFORMATION"


    echo "Hostname:"
    hostname


    echo

    echo "Operating System:"
    get_os


    echo

    echo "Kernel:"
    uname -r


    echo

    echo "Uptime:"
    uptime


    echo

    echo "Current Date:"
    date


}
