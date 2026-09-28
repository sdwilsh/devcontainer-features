#!/bin/bash

# This test file is executed against the 'pinned_version' scenario in
# test/jj/scenarios.json, which pins version to 0.44.0 with its matching sha256.

set -e

source dev-container-features-test-lib

check "jj reports pinned version" bash -c "jj --version | grep -q '0\.44\.0'"

reportResults
