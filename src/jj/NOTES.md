## Why this exists

No published `jj` Feature exists for Fedora, and devcontainer tooling cannot assume `jj` is baked into a given base image. The review lane needs it: reviewers run `jj diff`, the coder needs it to commit, and a workspace probe runs `jj --no-pager -R <cwd> diff --stat`.

This Feature runs no package manager. It downloads the `jj-v<version>-x86_64-unknown-linux-musl.tar.gz` release tarball, verifies it against a pinned sha256, and extracts only the `jj` binary from it. A checksum mismatch aborts the install.

Upstream does not publish a checksum file alongside the release tarballs, so the pinned `sha256` option is the only verification available. If you bump `version`, you must also update `sha256` to match, or the install will fail. Get the correct hash from the release page, e.g.:

```bash
curl -fsSL https://github.com/jj-vcs/jj/releases/download/v<version>/jj-v<version>-x86_64-unknown-linux-musl.tar.gz | sha256sum
```

## OS Support

This Feature works on any Linux distribution with `curl`, `tar`, and `sha256sum` present (Fedora, Debian/Ubuntu, Alpine, etc). It does not call `dnf`, `apt-get`, `apk`, or any other package manager.

Only `x86_64` is supported, matching the naming of the upstream release asset. The install fails loudly on any other architecture rather than installing a binary that cannot run.

`sh` is required to execute the `install.sh` script.
