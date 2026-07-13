#!/usr/bin/env bash
#
# LIA Disk Diagnostic Module
#
# Linux Incident Analyzer
#
# Version: 1.0.0
#
# Purpose:
#   Filesystem and storage health analysis.
#
# Checks:
#   - Filesystem usage
#   - Inode usage
#   - Disk I/O
#   - Large directories
#   - Filesystem errors
#   - Recommendations
#


#######################################
# Filesystem Usage
#######################################

disk_filesystems()
{

    print_subsection "Filesystem Usage"


    df -hP \
    | awk 'NR==1 || $NF=="/" || $NF!~/^\/proc|^\/sys|^\/run/'


    echo


    while read -r filesystem size used avail percent mount
    do

        usage=${percent%\%}


        if [[ "${usage}" =~ ^[0-9]+$ ]]
        then

            if (( usage >= 90 ))
            then

                print_status \
                "CRITICAL" \
                "${mount} filesystem usage above 90%"


            elif (( usage >= 80 ))
            then

                print_status \
                "WARNING" \
                "${mount} filesystem usage above 80%"


            else

                print_status \
                "OK" \
                "${mount} filesystem healthy"

            fi

        fi


    done < <(df -hP | tail -n +2)


    echo

}



#######################################
# Inode Analysis
#######################################

disk_inodes()
{

    print_subsection "Inode Usage"


    df -ihP \
    | awk 'NR==1 || $NF=="/"'


    local inode_usage


    inode_usage=$(df -i / | awk 'NR==2 {print $5}' | tr -d '%')


    if [[ -n "${inode_usage}" ]]
    then

        if (( inode_usage >= 90 ))
        then

            print_status \
            "WARNING" \
            "High inode utilization detected"


        else

            print_status \
            "OK" \
            "Inode utilization normal"

        fi

    fi


    echo

}



#######################################
# Disk I/O Analysis
#######################################

disk_io()
{

    print_subsection "Disk I/O"


    if command -v iostat >/dev/null 2>&1
    then


        iostat \
        -xz 1 2 \
        | tail -20


    else

        print_warning \
        "iostat unavailable. Install sysstat package"

    fi


    echo

}



#######################################
# Largest Directories
#######################################

disk_large_directories()
{

    print_subsection "Largest Directories"


    if command -v du >/dev/null 2>&1
    then


        du -xh / \
        --max-depth=2 \
        2>/dev/null |
        sort -rh |
        head -10


    fi


    echo

}



#######################################
# Filesystem Errors
#######################################

disk_errors()
{

    print_subsection "Filesystem Errors"


    if command -v journalctl >/dev/null 2>&1
    then


        local errors


        errors=$(journalctl \
        -k \
        --no-pager \
        2>/dev/null |
        grep -Ei \
        "filesystem error|I/O error|ext4|xfs|nvme" |
        tail -10 || true)


        if [[ -n "${errors}" ]]
        then

            print_status \
            "WARNING" \
            "Filesystem related errors detected"


            echo "${errors}"


        else

            print_status \
            "OK" \
            "No filesystem errors detected"

        fi


    fi


    echo

}



#######################################
# Recommendations
#######################################

disk_recommendations()
{

    print_subsection "Recommendations"


    print_info \
    "Investigate filesystems above 80% utilization"


    print_info \
    "Review I/O latency when applications are slow"


    print_info \
    "Check large directories before expanding storage"


}



#######################################
# Main Disk Module
#######################################

disk()
{

    print_section "DISK ANALYSIS"


    disk_filesystems

    disk_inodes

    disk_io

    disk_large_directories

    disk_errors

    disk_recommendations

}
