#!/usr/bin/env bash
#
# Linux Incident Analyzer (LIA)
#
# Main execution controller
#
# Version: 1.0.0
#
# Description:
#   Modular Linux diagnostic framework for SRE incident response.
#
# Author:
#    Javier Medina Gaitan
#
# License:
#   MIT
#

set -Eeuo pipefail

#######################################
# Project Metadata
#######################################

readonly LIA_NAME="Linux Incident Analyzer"
readonly LIA_VERSION="1.0.0"

#######################################
# Resolve Project Directories
#######################################

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly MODULE_DIR="${SCRIPT_DIR}/modules"
readonly REPORT_DIR="${SCRIPT_DIR}/reports"

#######################################
# Load Libraries
#######################################

load_library()
{

    local library="$1"

    if [[ -f "${LIB_DIR}/${library}" ]]
    then
        # shellcheck source=/dev/null
        source "${LIB_DIR}/${library}"
    else
        echo "ERROR: Missing library: ${library}" >&2
        exit 1
    fi

}

load_library "colors.sh"             #Carga codigos de color ANSI para formatear la salida en la terminal.
load_library "common.sh"             #Carga utilidades comunes generales del sistema
load_library "report.sh"             #Carga las funciones encargadas de estructurar y escribir en el archivo de reporte fisico.
load_library "banner.sh"             #Carga la función que dibuja la interfaz visual/texto de bienvenida.
load_library "system-info.sh"        #Carga funciones para extraer metadatos base de la máquina objetivo.
load_library "recommendations.sh"    #Carga el motor logico que genera sugerencias de mitigacion basadas en los hallazgos.

#######################################
# Diagnostic Modules
#######################################     # Declaro arreglo indexado de solo lectura  contiene la lista exacta de los  script individuales de diagnostico
					    # Agregar aca modulos de tu interes ej  security.sh,storage.sh, container.sh, app.sh, database.sh o hardware.sh(ipmitool y el acceso al BMC)
declare -ar MODULES=(
    "system.sh"
    "cpu.sh"
    "memory.sh"
    "disk.sh"
    "network.sh"
    "services.sh"
    "logs.sh"
)

#######################################
# Environment Preparation
#######################################                   #preparando ambiente , crear directorio report si no existe -p  si existe no genera error
prepare_environment()
{

    mkdir -p "${REPORT_DIR}"

    check_dependencies

}

#######################################
# Execute Modules
#######################################                   # contiene las ordenes para  coordinar y arrancar las revisiones(dispatcher)

run_modules()
{

    local module                                          # variables locales limitado al ciclo de vida de la funcion unicamente
    local module_path
    local module_name

    print_section "Starting Linux Incident Analysis"

    for module in "${MODULES[@]}"                         #  inicia el for para el arreglo MODULES 
    do

        module_path="${MODULE_DIR}/${module}"             #

        if [[ ! -f "${module_path}" ]]                    # si el el archivo no exite
        then
            print_warning "Module not found: ${module}"
            continue
        fi

        print_info "Running module: ${module}"           # imprime el nombre del modulo que se esta ejecutando

        # shellcheck source=/dev/null
        source "${module_path}"                          #ejecuta el script dentro  del proceso actual 

        module_name="${module%.sh}"                     # eliminamos .sh para poder hacer el export  


        #
        # Register current module
        #
        export LIA_CURRENT_MODULE="$(echo "${module_name}" | tr '[:lower:]' '[:upper:]')"      # registra la  variable en el entorno de variables globales



        if declare -F "${module_name}" >/dev/null; then                                     #verificamos que exista la funcion(-F) en el  execution enviroment actual(cpu,memory,disk, etc)

             "${module_name}"
 
        else

             print_warning \
            "Module ${module} does not expose execution function"

        fi

    done

}

#######################################
# Main
#######################################

main()
{

    print_banner \
        "${LIA_NAME}" \
        "${LIA_VERSION}"

    prepare_environment

    start_report

    run_modules

    ###################################
    # Executive Summary
    ###################################

    print_summary

    finish_report

    print_completed "Incident analysis completed"

}

#######################################
# Error Handling
#######################################

trap 'print_error "Unexpected error at line ${LINENO}"' ERR

#######################################
# Start
#######################################

main "$@"
