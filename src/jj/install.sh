#!/bin/sh
set -eu

echo "Activating feature 'jj'"

# The CLI always passes the option defaults, so no fallback is needed here.
# devcontainer-feature.json is the only place version and sha256 are pinned.
VERSION="${VERSION#v}"

if ! command -v curl > /dev/null 2>&1; then
    echo "jj feature requires curl, and it was not found" >&2
    exit 1
fi

if ! command -v sha256sum > /dev/null 2>&1; then
    echo "jj feature requires sha256sum, and it was not found" >&2
    exit 1
fi

if ! command -v tar > /dev/null 2>&1; then
    echo "jj feature requires tar, and it was not found" >&2
    exit 1
fi

# The upstream release asset is x86_64-only in its naming. Fail loudly
# rather than install a binary that cannot run.
ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64) ;;
    *)
        echo "jj feature only supports x86_64, got '${ARCH}'" >&2
        exit 1
        ;;
esac

DOWNLOAD_DIR="$(mktemp -d)"
trap 'rm -rf "${DOWNLOAD_DIR}"' EXIT

ARCHIVE_NAME="jj-v${VERSION}-x86_64-unknown-linux-musl.tar.gz"
ARCHIVE="${DOWNLOAD_DIR}/${ARCHIVE_NAME}"
URL="https://github.com/jj-vcs/jj/releases/download/v${VERSION}/${ARCHIVE_NAME}"

echo "Downloading jj ${VERSION} from ${URL}"
curl -fsSL -o "${ARCHIVE}" "${URL}"

# Fail closed: a mismatch must abort the install, not just warn.
echo "${SHA256}  ${ARCHIVE}" | sha256sum -c -

# The tarball verified above is the trust boundary. Only the jj binary
# is pulled out of it; the bundled README and LICENSE are not needed.
tar -xzf "${ARCHIVE}" -C "${DOWNLOAD_DIR}" ./jj

# /usr/local/bin, not /usr/bin: a distro package of jj owns files under
# /usr/bin, and a later "dnf install jj" would silently overwrite ours there.
install -m 0755 "${DOWNLOAD_DIR}/jj" /usr/local/bin/jj

echo "jj ${VERSION} installed to /usr/local/bin/jj"
