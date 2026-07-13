#!/usr/bin/env bash
#
# LIA System Information Helpers
#


get_os()
{

    if [[ -f /etc/os-release ]]
    then

        source /etc/os-release

        echo "${PRETTY_NAME}"

    else

        echo "Unknown Linux Distribution"

    fi

}


get_kernel()
{
    uname -r
}


get_hostname()
{
    hostname
}


get_uptime()
{
    uptime
}
