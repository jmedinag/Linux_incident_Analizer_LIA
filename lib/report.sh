#!/usr/bin/env bash
#
# LIA Report Engine
#


REPORT_FILE=""


#######################################
# Start report
#######################################

start_report()
{

    local timestamp

    timestamp=$(date +"%Y%m%d-%H%M%S")


    REPORT_FILE="${REPORT_DIR}/incident-${timestamp}.txt"


    touch "${REPORT_FILE}"


    exec > >(tee -a "${REPORT_FILE}") 2>&1


    echo
    echo "Linux Incident Analyzer Report"
    echo "Generated: $(date)"
    echo

}



#######################################
# Finish report
#######################################

finish_report()
{

    echo
    echo "================================="
    echo "Report completed"
    echo "Location:"
    echo "${REPORT_FILE}"
    echo "================================="

}
