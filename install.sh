#!/usr/bin/env bash
#
# Linux Incident Analyzer (LIA)
#
# Installation Script
#
# Copyright (c) 2026 Javier Medina
#
# Licensed under the MIT License.
#

set -euo pipefail

################################################################################
# Configuration
################################################################################

APP_NAME="lia"
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
    error "Please run this installer as root (sudo)."
fi

################################################################################
# Banner
################################################################################

echo
echo "=========================================="
echo " Linux Incident Analyzer (LIA)"
echo " Installation"
echo "=========================================="
echo

################################################################################
# Verify project files
################################################################################

[[ -f "VERSION" ]] || error "VERSION file not found."
[[ -f "lia.sh" ]] || error "lia.sh not found."
[[ -d "lib" ]] || error "lib directory not found."
[[ -d "modules" ]] || error "modules directory not found."

################################################################################
# Create directories
################################################################################

info "Creating directories..."

mkdir -p "$INSTALL_DIR"
mkdir -p "$REPORT_DIR"

success "Directories created."

################################################################################
# Copy files
################################################################################

info "Installing application..."

cp -R lia.sh "$INSTALL_DIR/"
cp -R lib "$INSTALL_DIR/"
cp -R modules "$INSTALL_DIR/"
cp VERSION "$INSTALL_DIR/"

if [[ -d docs ]]; then
    cp -R docs "$INSTALL_DIR/"
fi

success "Files copied."

################################################################################
# Permissions
################################################################################

chmod +x "$INSTALL_DIR/lia.sh"

find "$INSTALL_DIR/lib" -type f -name "*.sh" -exec chmod +x {} \;

find "$INSTALL_DIR/modules" -type f -name "*.sh" -exec chmod +x {} \;

success "Permissions configured."

################################################################################
# Symbolic Link
################################################################################

info "Creating executable..."

ln -sf "$INSTALL_DIR/lia.sh" "$BIN_LINK"

success "Executable created."

################################################################################
# Final Message
################################################################################

echo
echo "=========================================="
echo " Installation completed successfully"
echo "=========================================="
echo
echo "Command:"
echo
echo "    lia"
echo
echo "Reports:"
echo
echo "    $REPORT_DIR"
echo
echo "Installation:"
echo
echo "    $INSTALL_DIR"
echo
echo "Version"
echo
cat "$INSTALL_DIR/VERSION"
echo
echo "Enjoy Linux Incident Analyzer!"
echo
