#!/bin/sh
set -eu

echo "Activating feature 'wiff'"

# The CLI always passes the option defaults, so no fallback is needed here.
# devcontainer-feature.json is the only place repo and ref are pinned.

for tool in git curl install; do
    if ! command -v "${tool}" > /dev/null 2>&1; then
        echo "wiff feature requires ${tool}, and it was not found" >&2
        exit 1
    fi
done

# Building from source needs a C compiler for linking. Only dnf-based
# distros are wired up to install one; that matches the real target this
# Feature is built and tested against.
INSTALLED_GCC=0
if ! command -v cc > /dev/null 2>&1; then
    if command -v dnf > /dev/null 2>&1; then
        dnf install -y gcc
        INSTALLED_GCC=1
    else
        echo "wiff feature needs a C compiler to build from source, and only knows how to install one via dnf" >&2
        exit 1
    fi
fi

# This is a from-source build, not a fixed release asset, so there is no
# asset name to key an architecture check off of. The pinned Rust toolchain
# still targets the host's own architecture, and only x86_64 has been built
# and run against.
ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64) ;;
    *)
        echo "wiff feature only supports x86_64, got '${ARCH}'" >&2
        exit 1
        ;;
esac

BUILD_DIR="$(mktemp -d)"
cleanup() {
    # Removing BUILD_DIR takes the Rust toolchain, the cloned source, and the
    # target directory with it, so the layer carries no Rust install.
    rm -rf "${BUILD_DIR}"
    if [ "${INSTALLED_GCC}" = "1" ]; then
        dnf remove -y gcc > /dev/null
        dnf clean all > /dev/null
    fi
}
trap cleanup EXIT

export RUSTUP_HOME="${BUILD_DIR}/rustup"
export CARGO_HOME="${BUILD_DIR}/cargo"

# --default-toolchain none: the cloned repo's rust-toolchain.toml pins the
# real toolchain, installed below by `rustup toolchain install` with no
# argument, which reads that file.
echo "Installing a temporary Rust toolchain"
curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y \
    --no-modify-path --profile minimal --default-toolchain none
PATH="${CARGO_HOME}/bin:${PATH}"

REPO_DIR="${BUILD_DIR}/wiff"
echo "Fetching ${REPO} at ${REF}"
# A shallow fetch of the pinned commit by sha, not an archive tarball.
# GitHub's auto-generated tarballs are not guaranteed byte-stable across
# infrastructure changes, so a pinned sha256 of one can break with no
# content change. A git commit is content-addressed, so fetching the sha
# is self-verifying.
git init -q "${REPO_DIR}"
git -C "${REPO_DIR}" remote add origin "${REPO}"
git -C "${REPO_DIR}" fetch -q --depth 1 origin "${REF}"
git -C "${REPO_DIR}" checkout -q FETCH_HEAD

echo "Installing the toolchain pinned by rust-toolchain.toml"
(cd "${REPO_DIR}" && rustup toolchain install)

# release, not dist: dist turns on lto and codegen-units = 1, which builds
# much slower and buys nothing for a review tool run once per invocation.
echo "Building wiff"
(cd "${REPO_DIR}" && cargo build --locked --profile release -p wiff)

install -m 0755 "${REPO_DIR}/target/release/wiff" /usr/local/bin/wiff

echo "wiff installed to /usr/local/bin/wiff from ${REPO}@${REF}"
