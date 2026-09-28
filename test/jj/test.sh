#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'jj' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# This test can be run with the following command:
#
#    devcontainer features test \
#                   --features jj       \
#                   --skip-scenarios    \
#                   --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#                   /path/to/this/repo

set -e

source dev-container-features-test-lib

check "jj binary exists and is executable" test -x /usr/local/bin/jj
check "jj reports a version" bash -c "jj --version | grep -qE 'jj [0-9]+\.[0-9]+\.[0-9]+'"

reportResults
