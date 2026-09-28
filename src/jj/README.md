
# jj (jj)

Installs the jj-vcs/jj Jujutsu VCS from a sha256-pinned tarball release. No package manager is used, so it works on any distro with curl and tar.

## Example Usage

```json
"features": {
    "ghcr.io/sdwilsh/devcontainer-features/jj:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| sha256 | sha256 of the jj-v<version>-x86_64-unknown-linux-musl.tar.gz asset for the given version. Must be updated together with version. | string | f35438350b5d61963aac5dd74ede510b31d6b9690769d1a6268cf058cc825f72 |
| version | jj version to install, without a leading 'v'. | string | 0.45.1 |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/sdwilsh/devcontainer-features/blob/main/src/jj/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
