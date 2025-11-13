#!/bin/bash

set -euo pipefail

# Constants
readonly TOOL_NAME="pwsh"
readonly KEYRING_URL="https://packages.microsoft.com/config/ubuntu"
readonly PACKAGES_DEB="packages-microsoft-prod.deb"

# Configuration (can be overridden by env)
VERSION="${1:-${VERSION:-latest}}"

tempFile=""

log() {
  echo "-> $*" >&2
}

die() {
  echo "X Error: $*" >&2
  exit "${2:-1}"
}

cleanup() {
  if [[ -n "${tempFile}" && -f "${tempFile}" ]]; then
    rm -f "${tempFile}"
  fi
}
trap cleanup EXIT INT TERM

usage() {
  cat <<EOF
Usage: sudo $0 [VERSION]

Positional arguments:
  VERSION           Version to install (default: latest from apt repo)

Environment variables:
  VERSION           Desired version (default: latest)

Note: This script must be run with sudo or as root to install PowerShell system-wide via apt.

Examples:
  sudo $0              # Install latest
  sudo $0 7.4.0        # Install specific version
  VERSION=7.4.0 $0     # Install via env
EOF
}

check_sudo() {
  if [[ "${EUID}" -ne 0 ]]; then
    die "This script must be run as root or with sudo"
  fi
}

# Show help if requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

# Normalize VERSION: empty/whitespace -> "latest"
if [[ -z "${VERSION//[[:space:]]/}" ]]; then
  VERSION="latest"
fi

check_sudo

log "Installing ${TOOL_NAME} (${VERSION}) via apt repository"

# Check dependencies
log "Checking dependencies"
for dep in wget dpkg lsb_release; do
  command -v "${dep}" >/dev/null 2>&1 || die "Missing required dependency: ${dep}"
done

# Install apt transport dependencies
log "Installing apt dependencies"
apt-get update || die "Failed to update apt cache"
apt-get install -y wget apt-transport-https software-properties-common || die "Failed to install apt dependencies"

# Get Ubuntu version
log "Detecting Ubuntu version"
VERSION_ID="$(lsb_release -rs)" || die "Failed to detect Ubuntu version"

if [[ -z "${VERSION_ID}" ]]; then
  die "Unable to determine Ubuntu version"
fi

# Download and register Microsoft repository keys
log "Setting up Microsoft repository"
tempFile="${PACKAGES_DEB}"
if ! wget -q "${KEYRING_URL}/${VERSION_ID}/${PACKAGES_DEB}"; then
  die "Failed to download Microsoft repository configuration"
fi

if ! dpkg -i "${PACKAGES_DEB}"; then
  die "Failed to register Microsoft repository keys"
fi

# Update apt cache after adding repository
log "Updating apt cache"
apt-get update || die "Failed to update apt cache"

# Install PowerShell
log "Installing ${TOOL_NAME} ${VERSION}"
if [[ "${VERSION}" == "latest" ]]; then
  apt-get install -y powershell || die "Failed to install ${TOOL_NAME}"
else
  # Try to install specific version (format: powershell=version)
  apt-get install -y "powershell=${VERSION}-1.deb" || die "Failed to install ${TOOL_NAME} version ${VERSION}"
fi

log "✓ Successfully installed ${TOOL_NAME}"

# Verify installation
"${TOOL_NAME}" -Version || die "Installed binary failed to run"
