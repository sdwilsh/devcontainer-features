#!/bin/bash

# This test file is executed against the 'fedora' scenario in
# test/jj/scenarios.json, which uses the Fedora-based devcontainer base image.

set -e

source dev-container-features-test-lib

check "jj binary exists and is executable" test -x /usr/local/bin/jj
check "jj reports a version" bash -c "jj --version | grep -qE 'jj [0-9]+\.[0-9]+\.[0-9]+'"
check "jj initializes and reads a repo" bash -c " \
    set -e; \
    cd \"\$(mktemp -d)\"; \
    jj git init --colocate; \
    echo hello > file.txt; \
    jj status; \
    jj diff \
"

reportResults
