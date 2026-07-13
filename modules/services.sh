#!/usr/bin/env bash
#
# LIA Services Diagnostic Module
#
# Linux Incident Analyzer
#
# Version: 1.0.0
#
# Purpose:
#   Analyze Linux service health.
#
# Checks:
#   - Systemd availability
#   - Failed services
#   - Running services
#   - Enabled services
#   - Service status
#   - Recommendations
#


#######################################
# Systemd Status
#######################################

services_systemd_status()
{

    print_subsection "System Service Manager"


    if command -v systemctl >/dev/null 2>&1
    then

        local state


        state=$(systemctl is-system-running 2>/dev/null || true)


        print_key_value \
        "System State" \
        "${state}"


        case "${state}" in


            running)

                print_status \
                "OK" \
                "Systemd reports healthy state"

                ;;


            degraded)

                print_status \
                "WARNING" \
                "Systemd reports degraded state"

                ;;


            *)

                print_status \
                "WARNING" \
                "System state: ${state}"

                ;;

        esac


    else

        print_warning \
        "systemctl unavailable"

    fi


    echo

}



#######################################
# Failed Services
#######################################

services_failed_units()
{

    print_subsection "Failed Services"


    if command -v systemctl >/dev/null 2>&1
    then


        local failed


        failed=$(systemctl --failed \
        --no-legend \
        2>/dev/null || true)



        if [[ -n "${failed}" ]]
        then

            print_status \
            "WARNING" \
            "Failed system services detected"


            echo "${failed}"


        else

            print_status \
            "OK" \
            "No failed services detected"

        fi


    fi


    echo

}



#######################################
# Running Services
#######################################

services_running()
{

    print_subsection "Running Services"


    if command -v systemctl >/dev/null 2>&1
    then


        local total


        total=$(systemctl list-units \
        --type=service \
        --state=running \
        --no-legend |
        wc -l)



        print_key_value \
        "Running Services" \
        "${total}"


        systemctl list-units \
        --type=service \
        --state=running \
        --no-pager \
        --no-legend |
        head -15


    else

        print_warning \
        "systemctl unavailable"

    fi


    echo

}



#######################################
# Enabled Services
#######################################

services_enabled()
{

    print_subsection "Enabled Services"


    if command -v systemctl >/dev/null 2>&1
    then


        local enabled


        enabled=$(systemctl list-unit-files \
        --type=service \
        --state=enabled \
        --no-legend |
        wc -l)



        print_key_value \
        "Enabled Services" \
        "${enabled}"


    fi


    echo

}



#######################################
# Service Resource Usage
#######################################

services_resource_usage()
{

    print_subsection "Service Resource Usage"


    if command -v systemd-cgtop >/dev/null 2>&1
    then


        systemd-cgtop \
        --iterations=1 \
        --order=cpu \
        2>/dev/null || true


    else

        print_info \
        "systemd-cgtop unavailable"

    fi


    echo

}



#######################################
# Recommendations
#######################################

services_recommendations()
{

    print_subsection "Recommendations"


    print_info \
    "Investigate failed services before restarting production workloads"


    print_info \
    "Review service dependencies during startup failures"


    print_info \
    "Validate enabled services follow operational requirements"


}



#######################################
# Main Services Module
#######################################

services()
{

    print_section "SERVICES ANALYSIS"


    services_systemd_status

    services_failed_units

    services_running

    services_enabled

    services_resource_usage

    services_recommendations

}
