#!/bin/bash

# This test file is executed against the 'gateway_ports' scenario in
# test/sshd/scenarios.json, which sets gatewayPorts to 'yes'.

set -e

source dev-container-features-test-lib

check "gatewayports took effect" bash -c "sshd -T | grep -q '^gatewayports yes$'"

reportResults
