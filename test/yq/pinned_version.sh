#!/bin/bash

# This test file is executed against the 'pinned_version' scenario in
# test/yq/scenarios.json, which pins version to 4.44.5 with its matching sha256.

set -e

source dev-container-features-test-lib

check "yq reports pinned version" bash -c "yq --version | grep -q '4\.44\.5'"

reportResults
