#!/usr/bin/env bash
#
# Linux Incident Analyzer (LIA)
#
# Module:
#   Logs Analysis
#
# Purpose:
#   Analyze operating system logs looking for conditions
#   that may explain or contribute to an incident.
#
# Checks
#   • Critical journal events
#   • Kernel warnings/errors
#   • Out Of Memory (OOM)
#   • Authentication failures
#
# Version:
#   1.0.0
#

#######################################
# Critical Journal Events
#######################################

logs_system_errors()
{

    print_subsection "System Critical Errors"

    if ! command -v journalctl >/dev/null 2>&1
    then

        add_module_info \
        "LOGS" \
        "journalctl unavailable"

        echo

        return

    fi


    local errors
    local count


    errors=$(
        journalctl \
            -p warning \
            -xb \
            --no-pager \
            2>/dev/null
    )


    count=$(echo "${errors}" | grep -cv '^$')


    if (( count > 0 ))
    then

        add_module_warning \
        "LOGS" \
        "${count} critical journal events detected"

        echo
        echo "Recent Events"
        echo "-------------"

        echo "${errors}" | tail -10

    else

        add_module_ok \
        "LOGS" \
        "No critical system errors detected"

    fi

    echo

}
#######################################
# Kernel Messages
#######################################

logs_kernel_messages()
{

    print_subsection "Kernel Messages"

    if ! command -v dmesg >/dev/null 2>&1
    then

        add_module_info \
        "LOGS" \
        "dmesg unavailable"

        echo

        return

    fi


    local kernel_errors
    local count


    kernel_errors=$(
        dmesg \
            --level=warn,err,crit,alert,emerg \
            2>/dev/null
    )


    count=$(echo "${kernel_errors}" | grep -cv '^$')


    if (( count > 0 ))
    then

        add_module_warning \
        "LOGS" \
        "${count} kernel warning/error events detected"

        echo
        echo "Recent Kernel Events"
        echo "--------------------"

        echo "${kernel_errors}" | tail -10

    else

        add_module_ok \
        "LOGS" \
        "Kernel messages clean"

    fi

    echo

}
#######################################
# Out Of Memory Events
#######################################

logs_oom_events()
{

    print_subsection "Out Of Memory Events"

    if ! command -v journalctl >/dev/null 2>&1
    then

        add_module_info \
        "LOGS" \
        "journalctl unavailable"

        echo

        return

    fi


    local oom_events
    local count
    local killed_process


    oom_events=$(
    journalctl \
        -k \
        --no-pager \
        2>/dev/null |
    grep -Ei \
        "out of memory|oom-killer|killed process|oom" \
        || true
    )


    if [[ -z "${oom_events}" ]]
    then

        count=0

    else

    count=$(
        printf "%s\n" "${oom_events}" |
        grep -cv '^$'
    )

fi


    if (( count > 0 ))
    then

        add_module_critical \
        "LOGS" \
        "${count} Out Of Memory events detected"


        killed_process=$(
            echo "${oom_events}" |
            grep -Ei "Killed process" |
            tail -1
        )


        echo
        echo "Recent OOM Events"
        echo "-----------------"

        echo "${oom_events}" | tail -10


        if [[ -n "${killed_process}" ]]
        then

            echo
            echo "Last Killed Process"
            echo "-------------------"

            echo "${killed_process}"

        fi

    else

        add_module_ok \
        "LOGS" \
        "No Out Of Memory events detected"

    fi

    echo

}
#######################################
# Authentication Failures
#######################################

logs_authentication()
{

    print_subsection "Authentication Failures"

    local auth_errors=""
    local count=0


    if [[ -f /var/log/auth.log ]]
    then

        auth_errors=$(
            grep -Ei \
            "failed password|authentication failure|invalid user" \
            /var/log/auth.log \
            || true
        )

    elif command -v journalctl >/dev/null 2>&1
    then

        auth_errors=$(
            journalctl \
                -u ssh.service \
                -u sshd.service \
                --no-pager \
                2>/dev/null |
            grep -Ei \
            "failed|invalid" \
            || true
        )

    fi


    count=$(
    printf "%s\n" "${auth_errors}" |
    awk 'NF{c++} END{print c+0}'
    )


    if (( count > 0 ))
    then

        add_module_warning \
        "LOGS" \
        "${count} failed authentication attempts detected"

        echo
        echo "Recent Authentication Failures"
        echo "------------------------------"

        echo "${auth_errors}" | tail -10

    else

        add_module_ok \
        "LOGS" \
        "No authentication failures detected"

    fi

    echo

    echo
    echo "DEBUG: logs_authentication terminó"
    echo
}

#######################################
# Operational Guidance
#######################################

logs_recommendations()
{

    print_subsection "Operational Guidance"

    add_module_info \
    "LOGS" \
    "Correlate journal events with the incident timeline"

    add_module_info \
    "LOGS" \
    "Investigate repeated kernel warnings before rebooting"

    add_module_info \
    "LOGS" \
    "Review authentication failures for possible brute-force activity"

    add_module_info \
    "LOGS" \
    "Correlate OOM events with CPU, Memory and Disk utilization"

    add_module_info \
    "LOGS" \
    "Escalate immediately if production services were terminated by OOM Killer"

    echo

}

#######################################
# Main Module
#######################################

logs()
{

    print_section "LOG ANALYSIS"

    logs_system_errors

    logs_kernel_messages

    logs_oom_events

    logs_authentication

    logs_recommendations

}
