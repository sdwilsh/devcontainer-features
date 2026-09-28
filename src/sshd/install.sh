#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/sshd.md
# Maintainer: The VS Code and Codespaces Teams
#
# Note: You can change your user's password with "sudo passwd $(whoami)" (or just "passwd" if running as root).

SSHD_PORT="${SSHD_PORT:-"2222"}"
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
START_SSHD="${START_SSHD:-"false"}"
NEW_PASSWORD="${NEW_PASSWORD:-"skip"}"
GATEWAY_PORTS="${GATEWAYPORTS:-"no"}" 

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

# Classify the distro family. ID_LIKE catches derivatives (e.g. Oracle
# Linux: ID=ol, ID_LIKE=fedora) that a hand-listed ID match would miss.
. /etc/os-release
if [ "${ID:-}" = "debian" ] || [[ "${ID_LIKE:-}" == *debian* ]]; then
    ADJUSTED_ID="debian"
elif [ "${ID:-}" = "fedora" ] || [ "${ID:-}" = "rhel" ] || [[ "${ID_LIKE:-}" == *fedora* ]] || [[ "${ID_LIKE:-}" == *rhel* ]]; then
    ADJUSTED_ID="rhel"
else
    ADJUSTED_ID="debian"
fi

# Fedora 41+ dnf is dnf5; RHEL 7 has only yum. Pick whichever exists.
if [ "${ADJUSTED_ID}" = "rhel" ]; then
    if command -v dnf > /dev/null 2>&1; then
        PKG_MGR_CMD="dnf"
    else
        PKG_MGR_CMD="yum"
    fi
fi

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    case "${ADJUSTED_ID}" in
        rhel)
            if ! rpm -q "$@" > /dev/null 2>&1; then
                "${PKG_MGR_CMD}" -y install "$@"
            fi
            ;;
        *)
            if ! dpkg -s "$@" > /dev/null 2>&1; then
                apt_get_update
                apt-get -y install --no-install-recommends "$@"
            fi
            ;;
    esac
}

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Install openssh-server openssh-client. Fedora/RHEL call the client
# package openssh-clients, not openssh-client.
if [ "${ADJUSTED_ID}" = "rhel" ]; then
    check_packages openssh-server openssh-clients lsof
else
    check_packages openssh-server openssh-client lsof
fi

# Fedora's openssh-server package does not generate host keys on install.
# ssh-keygen -A only creates keys that are missing, so existing keys survive.
ssh-keygen -A

# Generate password if new password set to the word "random"
if [ "${NEW_PASSWORD}" = "random" ]; then
    # openssl is not present on the Fedora base image, nor on bare
    # debian/ubuntu images; /dev/urandom has no such dependency.
    NEW_PASSWORD="$(od -An -tx1 -N16 /dev/urandom | tr -d ' \n')"
    EMIT_PASSWORD="true"
elif [ "${NEW_PASSWORD}" != "skip" ]; then
    # If new password not set to skip, set it for the specified user
    echo "${USERNAME}:${NEW_PASSWORD}" | chpasswd
fi

if [ $(getent group ssh) ]; then
  echo "'ssh' group already exists."
else
  echo "adding 'ssh' group, as it does not already exist."
  groupadd ssh
fi

# Add user to ssh group
if [ "${USERNAME}" != "root" ]; then
    usermod -aG ssh ${USERNAME}
fi

# Setup sshd
mkdir -p /var/run/sshd
sed -i 's/session\s*required\s*pam_loginuid\.so/session optional pam_loginuid.so/g' /etc/pam.d/sshd
sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i -E "s/#*\s*Port\s+.+/Port ${SSHD_PORT}/g" /etc/ssh/sshd_config
sed -i "s/#GatewayPorts no/GatewayPorts ${GATEWAY_PORTS}/g" /etc/ssh/sshd_config
# Need to UsePAM so /etc/environment is processed
sed -i -E "s/#?\s*UsePAM\s+.+/UsePAM yes/g" /etc/ssh/sshd_config

# Write out a scripts that can be referenced as an ENTRYPOINT to auto-start sshd and fix login environments
tee /usr/local/share/ssh-init.sh > /dev/null \
<< 'EOF'
#!/usr/bin/env bash
# This script is intended to be run as root with a container that runs as root (even if you connect with a different user)
# However, it supports running as a user other than root if passwordless sudo is configured for that same user.

set -e 

sudoIf()
{
    if [ "$(id -u)" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

EOF
tee -a /usr/local/share/ssh-init.sh > /dev/null \
<< 'EOF'

# ** Start SSH server **
# Debian/Ubuntu ship an init script; Fedora/RHEL do not, so run sshd directly.
# -e logs to stderr instead of syslog, which a container has none of; without
# it, a config, host-key, or sudo-refusal failure here leaves no trace.
if [ -f /etc/init.d/ssh ]; then
    sudoIf /etc/init.d/ssh start 2>&1 | sudoIf tee /tmp/sshd.log > /dev/null
else
    sudoIf /usr/sbin/sshd -e 2>&1 | sudoIf tee /tmp/sshd.log > /dev/null
fi

set +e
exec "$@"
EOF
chmod +x /usr/local/share/ssh-init.sh

# If we should start sshd now, do so
if [ "${START_SSHD}" = "true" ]; then
    /usr/local/share/ssh-init.sh
fi

# Output success details
echo -e "Done!\n\n- Port: ${SSHD_PORT}\n- User: ${USERNAME}"
if [ "${EMIT_PASSWORD}" = "true" ]; then
    echo "- Password: ${NEW_PASSWORD}"
fi

# Clean up
if [ "${ADJUSTED_ID}" = "rhel" ]; then
    rm -rf /var/cache/dnf/* /var/cache/libdnf5/* /var/cache/yum/*
else
    rm -rf /var/lib/apt/lists/*
fi

echo -e "\nForward port ${SSHD_PORT} to your local machine and run:\n\n  ssh -p ${SSHD_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null ${USERNAME}@localhost\n"
