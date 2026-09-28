#!/bin/bash

# This test file is executed against the 'fedora' scenario in
# test/sshd/scenarios.json, which uses a bare Fedora base image.

set -e

source dev-container-features-test-lib

check "openssh-server rpm is installed" rpm -q openssh-server
check "openssh-clients rpm is installed" rpm -q openssh-clients
check "lsof rpm is installed" rpm -q lsof
check "ssh-init.sh exists" bash -c "ls /usr/local/share/ssh-init.sh"
check "sshd is running" bash -c "grep -lx sshd /proc/[0-9]*/comm > /dev/null"
check "sshd_config is valid" sshd -t
check "port took effect" bash -c "sshd -T | grep -q '^port 2222$'"
check "permitrootlogin took effect" bash -c "sshd -T | grep -q '^permitrootlogin yes$'"
check "host keys exist" bash -c "ls /etc/ssh/ssh_host_*_key > /dev/null"

reportResults
