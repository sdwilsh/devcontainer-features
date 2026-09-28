#!/bin/bash

# This test file is executed against the 'fedora' scenario in
# test/wiff/scenarios.json, which uses the Fedora-based devcontainer base
# image: the only base wiff's install.sh knows how to build on.

set -e

source dev-container-features-test-lib

check "wiff binary exists and is executable" test -x /usr/local/bin/wiff
check "wiff reports a version" bash -c "wiff --version | grep -qE 'wiff [0-9]+\.[0-9]+\.[0-9]+'"
check "wiff reads a change from a colocated jj repo" bash -c " \
    set -e; \
    cd \"\$(mktemp -d)\"; \
    jj git init --colocate; \
    echo hello > file.txt; \
    wiff new --no-tui < /dev/null; \
    wiff render --format json | grep -q '\"new_path\": \"file.txt\"' \
"

reportResults
