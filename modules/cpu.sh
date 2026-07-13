#!/usr/bin/env bash
#
# LIA CPU Diagnostic Module
#
# Linux Incident Analyzer
#
# Version: 1.0.0
#
# Purpose:
#   CPU performance analysis for Linux systems.
#
# Checks:
#   - CPU hardware information
#   - CPU topology
#   - Load average
#   - CPU utilization
#   - IO wait
#   - Steal time
#   - Scheduler metrics
#   - Process states
#   - Top CPU consumers
#   - Recommendations
#

#######################################
# CPU Hardware Information
#######################################

cpu_hardware()
{

    print_subsection "CPU Hardware Information"


    if command -v lscpu >/dev/null 2>&1
    then

        local vendor
        local model
        local sockets
        local cores
        local threads


        vendor=$(lscpu | awk -F: '/Vendor ID/ {print $2; exit}' | xargs || true)

        model=$(lscpu | awk -F: '/Model name/ {print $2; exit}' | xargs || true)

        sockets=$(lscpu | awk -F: '/Socket\(s\)/ {print $2; exit}' | xargs || true)

        cores=$(lscpu | awk -F: '/Core\(s\) per socket/ {print $2; exit}' | xargs || true)

        threads=$(nproc 2>/dev/null || echo "Unknown")


        print_key_value "Vendor" "${vendor:-Unknown}"

        print_key_value "Model" "${model:-Unknown}"

        print_key_value "CPU Sockets" "${sockets:-Unknown}"

        print_key_value "Physical Cores/socket" "${cores:-Unknown}"

        print_key_value "Logical CPUs" "${threads}"


    else

        print_warning "lscpu command not available"

    fi


    echo

}



#######################################
# CPU Load Analysis
#######################################

cpu_load()
{

    print_subsection "CPU Load Analysis"


    local load_one
    local load_five
    local load_fifteen
    local cpu_count


    read -r load_one load_five load_fifteen < /proc/loadavg


    cpu_count=$(nproc 2>/dev/null || echo 1)


    print_key_value \
        "Load Average 1m" \
        "${load_one}"


    print_key_value \
        "Load Average 5m" \
        "${load_five}"


    print_key_value \
        "Load Average 15m" \
        "${load_fifteen}"


    print_key_value \
        "Available CPUs" \
        "${cpu_count}"


    if (( $(echo "${load_one} > ${cpu_count}" | bc -l 2>/dev/null || echo 0) ))
    then

        print_status \
            "WARNING" \
            "CPU load exceeds available processors"

    else

        print_status \
            "OK" \
            "CPU load is within capacity"

    fi


    echo

}



#######################################
# CPU Utilization
#######################################

cpu_usage()
{

    print_subsection "CPU Utilization"


    if command -v mpstat >/dev/null 2>&1
    then

        local stats

        stats=$(mpstat 1 1 | awk '/Average/ && $2=="all"' || true)


        if [[ -n "${stats}" ]]
        then

            local user
            local system
            local idle
            local iowait
            local steal


            user=$(echo "${stats}" | awk '{print $3}')

            system=$(echo "${stats}" | awk '{print $5}')

            iowait=$(echo "${stats}" | awk '{print $6}')

            steal=$(echo "${stats}" | awk '{print $9}')

            idle=$(echo "${stats}" | awk '{print $12}')


            print_key_value "User CPU" "${user}%"

            print_key_value "System CPU" "${system}%"

            print_key_value "IO Wait" "${iowait}%"

            print_key_value "Steal Time" "${steal}%"

            print_key_value "Idle CPU" "${idle}%"


            if (( ${iowait%.*} > 20 ))
            then

                print_status \
                "WARNING" \
                "High I/O wait detected"

            fi


            if (( ${steal%.*} > 10 ))
            then

                print_status \
                "WARNING" \
                "High CPU steal detected. Check hypervisor contention"

            fi


        fi


    else

        print_warning \
        "mpstat unavailable. Install sysstat for detailed metrics"

    fi


    echo

}



#######################################
# Scheduler Metrics
#######################################

cpu_scheduler()
{

    print_subsection "Kernel Scheduler"


    if command -v vmstat >/dev/null 2>&1
    then

        local stats

        stats=$(vmstat 1 2 | tail -1 || true)


        local interrupts

        local context_switch


        interrupts=$(echo "${stats}" | awk '{print $11}')

        context_switch=$(echo "${stats}" | awk '{print $12}')


        print_key_value \
            "Interrupts/sec" \
            "${interrupts:-0}"


        print_key_value \
            "Context Switches/sec" \
            "${context_switch:-0}"


    else

        print_warning "vmstat unavailable"

    fi


    echo

}



#######################################
# Process Analysis
#######################################

cpu_processes()
{

    print_subsection "Process Analysis"


    local running
    local blocked
    local zombies


    running=$(ps -eo state | awk '$1=="R"{c++} END{print c+0}')

    blocked=$(ps -eo state | awk '$1=="D"{c++} END{print c+0}')

    zombies=$(ps -eo state | awk '$1=="Z"{c++} END{print c+0}')


    print_key_value \
        "Running Processes" \
        "${running}"


    print_key_value \
        "Blocked Processes" \
        "${blocked}"


    print_key_value \
        "Zombie Processes" \
        "${zombies}"


    if (( blocked > 0 ))
    then

        print_status \
        "WARNING" \
        "${blocked} processes waiting for I/O"

    else

        print_status \
        "OK" \
        "No blocked processes detected"

    fi


    if (( zombies > 0 ))
    then

        print_status \
        "WARNING" \
        "${zombies} zombie processes detected"

    fi


    echo


    print_subsection "Top CPU Consumers"


    (
        echo "PID USER CPU COMMAND"

        ps \
        -eo pid,user,%cpu,comm \
        --sort=-%cpu \
        --no-headers |
        head -5

    ) | column -t || true


    echo

}



#######################################
# Recommendations
#######################################

cpu_recommendations()
{

    print_subsection "Recommendations"


    print_info \
    "Review high CPU consumers if saturation is detected"


    print_info \
    "Investigate high IO Wait with disk diagnostics"


    print_info \
    "For virtual machines review CPU steal and hypervisor contention"


}



#######################################
# CPU Main Entry Point
#######################################

cpu()
{

    print_section "CPU ANALYSIS"


    cpu_hardware

    cpu_load

    cpu_usage

    cpu_scheduler

    cpu_processes

    cpu_recommendations

}
