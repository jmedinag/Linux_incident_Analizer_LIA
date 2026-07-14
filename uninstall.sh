#!/usr/bin/env bash
#
# Linux Incident Analyzer (LIA)
#
# Uninstallation Script
#
# Copyright (c) 2026 Javier Medina
#
# Licensed under the MIT License.
#

set -euo pipefail

################################################################################
# Configuration
################################################################################

INSTALL_DIR="/opt/lia"
BIN_LINK="/usr/local/bin/lia"
REPORT_DIR="/var/log/lia"

################################################################################
# Colors
################################################################################

GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

################################################################################
# Functions
################################################################################

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[ OK ]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[FAIL]${NC} $1"
    exit 1
}

################################################################################
# Root Check
################################################################################

if [[ "$EUID" -ne 0 ]]; then
    error "Please run this script as root (sudo)."
fi

################################################################################
# Banner
################################################################################

echo
echo "=========================================="
echo " Linux Incident Analyzer (LIA)"
echo " Uninstallation"
echo "=========================================="
echo

################################################################################
# Remove executable
################################################################################

if [[ -L "$BIN_LINK" || -f "$BIN_LINK" ]]; then
    info "Removing executable..."
    rm -f "$BIN_LINK"
    success "Executable removed."
else
    warning "Executable not found."
fi

################################################################################
# Remove installation
################################################################################

if [[ -d "$INSTALL_DIR" ]]; then
    info "Removing installation..."
    rm -rf "$INSTALL_DIR"
    success "Installation removed."
else
    warning "Installation directory not found."
fi

################################################################################
# Reports
################################################################################

if [[ -d "$REPORT_DIR" ]]; then

    echo
    read -rp "Do you also want to remove all generated reports? [y/N]: " ANSWER

    case "$ANSWER" in
        y|Y|yes|YES)

            info "Removing reports..."

            rm -rf "$REPORT_DIR"

            success "Reports removed."

            ;;

        *)

            warning "Reports were preserved."

            ;;

    esac

fi

################################################################################
# Finished
################################################################################

echo
echo "=========================================="
echo " LIA has been successfully removed."
echo "=========================================="
echo

echo "Thank you for using Linux Incident Analyzer."
echo
