#!/usr/bin/env bash
set -euo pipefail

REPO="https://faizahmd2.github.io/pinproc-apt"
KEYRING="/etc/apt/keyrings/pinproc-archive.gpg"
SOURCES="/etc/apt/sources.list.d/pinproc.list"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run with sudo:"
    echo "  curl -fsSL ${REPO}/install.sh | sudo bash"
    exit 1
fi

if [[ ! -f /etc/os-release ]]; then
    echo "Cannot determine operating system."
    exit 1
fi

. /etc/os-release

if [[ "${ID}" != "ubuntu" && "${ID}" != "debian" ]]; then
    echo "Unsupported operating system: ${ID}"
    echo "Pinproc currently supports Debian/Ubuntu systems."
    exit 1
fi

ARCH="$(dpkg --print-architecture)"

case "${ARCH}" in
    amd64|arm64)
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        echo "Pinproc currently provides amd64 and arm64 packages."
        exit 1
        ;;
esac

echo "Installing Pinproc APT repository..."
echo "OS:           ${ID}"
echo "Architecture: ${ARCH}"

install -d -m 0755 /etc/apt/keyrings

curl -fsSL "${REPO}/keys/pinproc-archive.asc" \
    | gpg --dearmor \
    > "${KEYRING}"

chmod 0644 "${KEYRING}"

cat > "${SOURCES}" <<SOURCE
deb [signed-by=${KEYRING}] ${REPO} pinproc main
SOURCE

apt-get update
apt-get install -y pinproc

echo
echo "Pinproc installed successfully."
pinproc --version
