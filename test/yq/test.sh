#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'yq' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# This test can be run with the following command:
#
#    devcontainer features test \
#                   --features yq      \
#                   --skip-scenarios    \
#                   --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#                   /path/to/this/repo

set -e

source dev-container-features-test-lib

check "yq binary exists and is executable" test -x /usr/local/bin/yq
check "yq reports a version" bash -c "yq --version | grep -qE 'v[0-9]+\.[0-9]+\.[0-9]+'"
check "yq parses YAML" bash -c "echo 'a: {b: 1}' | yq '.a.b' | grep -q '^1$'"

reportResults
