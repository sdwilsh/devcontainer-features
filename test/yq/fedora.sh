#!/bin/bash

# This test file is executed against the 'fedora' scenario in
# test/yq/scenarios.json, which uses the Fedora-based devcontainer base image.

set -e

source dev-container-features-test-lib

check "yq binary exists and is executable" test -x /usr/local/bin/yq
check "yq reports a version" bash -c "yq --version | grep -qE 'v[0-9]+\.[0-9]+\.[0-9]+'"
check "yq parses YAML" bash -c "echo 'a: {b: 1}' | yq '.a.b' | grep -q '^1$'"

reportResults
