#!/usr/bin/env bash
#
# LIA Common Functions
#
# Shared functions for Linux Incident Analyzer
#

#######################################
# Findings Engine
#######################################

declare -ag LIA_OK=()
declare -ag LIA_WARNING=()
declare -ag LIA_CRITICAL=()
declare -ag LIA_INFO=()

#######################################
# Dependency Checks
#######################################

check_dependencies()
{

    local dependencies=(
        awk
        grep
        sed
        hostname
        uptime
    )

    local command

    for command in "${dependencies[@]}"
    do
        if ! command -v "${command}" >/dev/null 2>&1
        then
            print_warning "Command not found: ${command}"
        fi
    done

}

#######################################
# Console Formatting
#######################################

print_section()
{

    echo
    echo -e "${BLUE}${BOLD}"
    echo "========================================"
    echo "$1"
    echo "========================================"
    echo -e "${RESET}"

}

print_subsection()
{

    echo
    echo -e "${CYAN}${BOLD}$1${RESET}"
    echo "----------------------------------------"

}

#######################################
# Console Messages
#######################################

#
# Execution message only
#

print_info()
{

    echo -e "${CYAN}[INFO]${RESET} $1"

}

#
# Findings


print_success()
{

    local message="$1"

    echo -e "${GREEN}[ OK ]${RESET} ${message}"

    LIA_OK+=("${message}")

}

print_warning()
{

    local message="$1"

    echo -e "${YELLOW}[WARNING]${RESET} ${message}"

    LIA_WARNING+=("${message}")

}

print_error()
{

    local message="$1"

    echo -e "${RED}[ERROR]${RESET} ${message}"

    LIA_CRITICAL+=("${message}")

}

print_critical()
{

    local message="$1"

    echo -e "${RED}${BOLD}[CRITICAL]${RESET} ${message}"

    LIA_CRITICAL+=("${message}")

}

#######################################
# Findings API
#######################################

add_ok()
{

    local message="$1"


    if [[ -n "${LIA_CURRENT_MODULE:-}" ]]
    then

        print_success \
        "[${LIA_CURRENT_MODULE}] ${message}"

    else

        print_success \
        "${message}"

    fi

}

add_warning()
{

    local message="$1"


    if [[ -n "${LIA_CURRENT_MODULE:-}" ]]
    then

        print_warning \
        "[${LIA_CURRENT_MODULE}] ${message}"

    else

        print_warning \
        "${message}"

    fi

}

add_critical()
{

    local message="$1"


    if [[ -n "${LIA_CURRENT_MODULE:-}" ]]
    then

        print_critical \
        "[${LIA_CURRENT_MODULE}] ${message}"

    else

        print_critical \
        "${message}"

    fi

}

add_info()
{

    local message="$1"


    if [[ -n "${LIA_CURRENT_MODULE:-}" ]]
    then

        message="[${LIA_CURRENT_MODULE}] ${message}"

    fi


    echo -e "${BLUE}[INFO]${RESET} ${message}"

    LIA_INFO+=("${message}")

}
#######################################
# Module Findings API
#######################################

add_module_ok()
{

    local module="$1"
    local message="$2"


    LIA_OK+=(
        "[${module}] ${message}"
    )

}



add_module_warning()
{

    local module="$1"
    local message="$2"


    LIA_WARNING+=(
        "[${module}] ${message}"
    )

}



add_module_critical()
{

    local module="$1"
    local message="$2"


    LIA_CRITICAL+=(
        "[${module}] ${message}"
    )

}



add_module_info()
{

    local module="$1"
    local message="$2"


    LIA_INFO+=(
        "[${module}] ${message}"
    )

}

#######################################
# Data Helpers
#######################################

print_key_value()
{

    local key="$1"
    local value="$2"

    printf "%-20s : %s\n" "${key}" "${value}"

}

print_status()
{

    local status="$1"
    local message="$2"

    case "${status}" in

        OK|ok)
            add_ok "${message}"
            ;;

        WARNING|warning)
            add_warning "${message}"
            ;;

        ERROR|error)
            add_critical "${message}"
            ;;

        CRITICAL|critical)
            add_critical "${message}"
            ;;

        *)
            add_info "${message}"
            ;;

    esac

}

#######################################
# Execution Helpers
#######################################

print_running()
{

    echo -e "${BLUE}[RUNNING]${RESET} $1"

}

print_completed()
{

    echo -e "${GREEN}[COMPLETED]${RESET} $1"

}

#######################################
# Executive Summary
#######################################
#######################################
# Recommendation Engine Integration
#######################################

print_recommendations()
{

    ###################################
    # Validate recommendation engine
    ###################################

    if ! declare -F generate_recommendation >/dev/null
    then

        return

    fi


    ###################################
    # Warning recommendations
    ###################################

    if (( ${#LIA_WARNING[@]} > 0 ))
    then

        echo
        echo "Recommended Actions"
        echo "-------------------"


        local finding


        for finding in "${LIA_WARNING[@]}"
        do

            echo
            echo "Finding:"
            echo "${finding}"


            generate_recommendation "${finding}"


        done


    fi



    ###################################
    # Critical recommendations
    ###################################

    if (( ${#LIA_CRITICAL[@]} > 0 ))
    then

        echo
        echo "Critical Actions"
        echo "----------------"


        local finding


        for finding in "${LIA_CRITICAL[@]}"
        do

            echo
            echo "Finding:"
            echo "${finding}"


            generate_recommendation "${finding}"


        done


    fi


}
print_summary()
{

    print_section "EXECUTIVE SUMMARY"


    ###################################
    # Calculate Risk Score
    ###################################

    local critical_count
    local warning_count
    local ok_count
    local info_count

    local risk_score=0


    critical_count=${#LIA_CRITICAL[@]}
    warning_count=${#LIA_WARNING[@]}
    ok_count=${#LIA_OK[@]}
    info_count=${#LIA_INFO[@]}



    #
    # Risk calculation
    #
    # Critical = 25 points
    # Warning  = 5 points
    #

    risk_score=$((

        (critical_count * 25) +
        (warning_count * 5)

    ))



    if (( risk_score > 100 ))
    then
        risk_score=100
    fi



    ###################################
    # Overall Health
    ###################################

    local health_status
    local assessment


    if (( critical_count > 0 ))
    then

        health_status="CRITICAL"
        assessment="Immediate attention required"


    elif (( warning_count > 0 ))
    then

        health_status="WARNING"
        assessment="Investigation recommended"


    else

        health_status="HEALTHY"
        assessment="System operating normally"

    fi



    echo
    echo "System Health"
    echo "----------------------------------------"


    printf "%-20s : %s\n" \
    "Status" \
    "${health_status}"


    printf "%-20s : %s/100\n" \
    "Risk Score" \
    "${risk_score}"


    printf "%-20s : %s\n" \
    "Assessment" \
    "${assessment}"



    echo



    ###################################
    # Findings Summary
    ###################################

    echo "Findings Summary"
    echo "----------------------------------------"


    printf "%-20s : %d\n" \
    "Critical" \
    "${critical_count}"


    printf "%-20s : %d\n" \
    "Warnings" \
    "${warning_count}"


    printf "%-20s : %d\n" \
    "Healthy Checks" \
    "${ok_count}"


    printf "%-20s : %d\n" \
    "Information" \
    "${info_count}"



    ###################################
    # Critical Findings
    ###################################

    if (( critical_count > 0 ))
    then

        echo
        echo "Critical Findings"
        echo "-----------------"


        printf ' [CRITICAL] %s\n' \
        "${LIA_CRITICAL[@]}"

    fi



    ###################################
    # Warning Findings
    ###################################

    if (( warning_count > 0 ))
    then

        echo
        echo "Priority Findings"
        echo "-----------------"


        printf ' [WARNING] %s\n' \
        "${LIA_WARNING[@]}"

    fi
    ###################################
    # Recommendations
    ###################################

    print_recommendations


    ###################################
    # Successful Checks
    ###################################

    if (( ok_count > 0 ))
    then

        echo
        echo "Successful Checks"
        echo "-----------------"


        printf ' [ OK ] %s\n' \
        "${LIA_OK[@]}"

    fi



    ###################################
    # Information
    ###################################

    if (( info_count > 0 ))
    then

        echo
        echo "Information"
        echo "-----------"


        printf ' [INFO] %s\n' \
        "${LIA_INFO[@]}"

    fi


}
