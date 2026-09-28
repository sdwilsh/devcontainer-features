#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

check "sshd-init-exists" bash -c "ls /usr/local/share/ssh-init.sh"
check "sshd-log-exists" bash -c "ls /tmp/sshd.log"
check "sshd-log-contents" bash -c "cat /tmp/sshd.log | grep 'Starting OpenBSD Secure Shell server'"
check "sshd-log-has-sshd" bash -c "cat /tmp/sshd.log | grep 'sshd'"
check "sshd" bash -c "ps -aux | grep -v grep | grep sshd"
check "sshd_config is valid" sshd -t
check "port took effect" bash -c "sshd -T | grep -q '^port 2222$'"
check "permitrootlogin took effect" bash -c "sshd -T | grep -q '^permitrootlogin yes$'"

# Report result
reportResults
