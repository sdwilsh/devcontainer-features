## Why this exists

`wiff` is a Rust code review tool.  This repo's consuming project is managed
by Jujutsu (`jj`), and needs wiff's jj backend.  Upstream `wez/wiff` has no jj
support and no release carrying one.  The jj backend exists only in the
`sdwilsh/wiff` fork, and that fork has no release either.  This Feature
therefore builds `wiff` from source at a pinned commit.  Once the fork's PR
merges upstream and a release ships it, replace this Feature with a fetch of
that release asset.

## Fetching

The pinned commit is fetched with a shallow `git fetch` by sha, not GitHub's
auto-generated archive tarball.  Those tarballs are not guaranteed byte-stable
across GitHub infrastructure changes, so a pinned sha256 of one can break with
no content change.  A git commit is content-addressed, so fetching the sha is
self-verifying; no separate checksum option is needed, unlike the `jj` and
`yq` Features in this repo.

## Building

Building needs a Rust toolchain and a C compiler for linking.  Both go in only
for the build, and both come back out afterward: `install.sh` deletes the
cloned source, the target directory, and the whole rustup/cargo install in one
`rm -rf` of a temp directory, then removes the compiler package it added.  So
the layer carries no Rust install.

The Rust toolchain is not hand-pinned in this Feature.  The cloned repo carries
its own `rust-toolchain.toml`, and `rustup toolchain install`, run with no
argument inside that repo, reads it and installs the channel it names.

`wiff` is built with `--profile release`, not `dist`.  `dist` turns on
`lto = true` and `codegen-units = 1`, which builds much slower and buys
nothing for a review tool run once per invocation.

## OS support

Fedora/RHEL (`dnf`) only.  Building from source needs a C compiler, and only
`dnf` is wired up here to install one.  This matches the real target this
Feature was written and tested against; it is not the "any distro with curl"
shape of the `jj` and `yq` Features.

Only `x86_64` has been built and run.

`sh` is required to execute `install.sh`.

## Renovate

No Renovate manager tracks `ref`.  A fork with no releases can only be tracked
by branch tip, and auto-bumping to a fork's HEAD on every push is not wanted.
The pin is deliberately manual, and deliberately temporary: it goes away once
this Feature is replaced by an upstream release fetch.
