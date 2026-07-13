#!/usr/bin/env bash
#
# LIA Memory Diagnostic Module
#
# Checks:
# - RAM usage
# - Available memory
# - Swap usage
# - Top memory consumers
# - OOM events
#

memory()
{

    local memory_used
    local memory_available
    local swap_used
    local oom_events

    print_section "MEMORY ANALYSIS"

    #######################################
    # Memory Summary
    #######################################

    echo "Memory Summary:"
    echo

    if command -v free >/dev/null 2>&1
    then

        free -h

    else

        add_warning "free command not available"
        return

    fi

    #######################################
    # Memory Usage
    #######################################

    echo
    echo "Memory Usage:"
    echo

    memory_used=$(free | awk '/Mem:/ {printf("%.0f",$3/$2*100)}')
    memory_available=$(free | awk '/Mem:/ {printf("%.0f",$7/$2*100)}')

    printf "RAM Used      : %s%%\n" "${memory_used}"
    printf "RAM Available : %s%%\n" "${memory_available}"

    if (( memory_used >= 90 ))
    then

        add_warning "Memory utilization is critically high (${memory_used}%)"

    elif (( memory_used >= 75 ))
    then

        add_warning "Memory utilization is elevated (${memory_used}%)"

    else

        add_ok "Memory utilization is normal (${memory_used}%)"

    fi

    #######################################
    # Swap
    #######################################

    echo
    echo "Swap Status:"
    echo

    if command -v swapon >/dev/null 2>&1
    then

        swapon --show

        swap_used=$(swapon --show --bytes \
            | awk 'NR>1 {sum+=$4} END {print sum+0}')

        if (( swap_used > 0 ))
        then

            add_warning "Swap is currently in use"

        else

            add_ok "Swap is not being used"

        fi

    else

        add_warning "swapon command not available"

    fi

    #######################################
    # Top Memory Consumers
    #######################################

    echo
    echo "Top Memory Consumers:"
    echo

    ps -eo pid,comm,%mem,%cpu --sort=-%mem \
        | head -10 || true

    #######################################
    # OOM Events
    #######################################

    echo
    echo "OOM Events:"
    echo

    if command -v journalctl >/dev/null 2>&1
    then

        oom_events=$(
            journalctl \
                -k \
                --no-pager \
                2>/dev/null \
            | grep -Ei "out of memory|oom|killed process" \
            | tail -5 || true
        )

        if [[ -n "${oom_events}" ]]
        then

            add_warning "Out Of Memory events detected"

            echo "${oom_events}"

        else

            add_ok "No Out Of Memory events detected"

        fi

    else

        add_warning "journalctl command not available"

    fi

}
