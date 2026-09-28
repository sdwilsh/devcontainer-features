#!/bin/sh
set -eu

echo "Activating feature 'yq'"

# The CLI always passes the option defaults, so no fallback is needed here.
# devcontainer-feature.json is the only place version and sha256 are pinned.
VERSION="${VERSION#v}"

if ! command -v curl > /dev/null 2>&1; then
    echo "yq feature requires curl, and it was not found" >&2
    exit 1
fi

if ! command -v sha256sum > /dev/null 2>&1; then
    echo "yq feature requires sha256sum, and it was not found" >&2
    exit 1
fi

# The upstream release asset is x86_64-only in its naming. Fail loudly
# rather than install a binary that cannot run.
ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64) ;;
    *)
        echo "yq feature only supports x86_64, got '${ARCH}'" >&2
        exit 1
        ;;
esac

DOWNLOAD_DIR="$(mktemp -d)"
trap 'rm -rf "${DOWNLOAD_DIR}"' EXIT

BINARY="${DOWNLOAD_DIR}/yq_linux_amd64"
URL="https://github.com/mikefarah/yq/releases/download/v${VERSION}/yq_linux_amd64"

echo "Downloading yq ${VERSION} from ${URL}"
curl -fsSL -o "${BINARY}" "${URL}"

# Fail closed: a mismatch must abort the install, not just warn.
echo "${SHA256}  ${BINARY}" | sha256sum -c -

# /usr/local/bin, not /usr/bin: a distro package of yq owns files under
# /usr/bin, and a later "dnf install yq" would silently overwrite ours there.
install -m 0755 "${BINARY}" /usr/local/bin/yq

echo "yq ${VERSION} installed to /usr/local/bin/yq"
