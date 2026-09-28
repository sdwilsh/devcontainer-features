
# yq (yq)

Installs the mikefarah/yq YAML processor from a sha256-pinned binary release. No package manager is used, so it works on any distro with curl.

## Example Usage

```json
"features": {
    "ghcr.io/sdwilsh/devcontainer-features/yq:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| sha256 | sha256 of the yq_linux_amd64 asset for the given version. Must be updated together with version. | string | c5f056448f973ae7d39b5401949648a78f2dc1947d6a8eb65be60d5c504b9385 |
| version | yq version to install, without a leading 'v'. | string | 4.53.6 |

## Why this exists

Most published `yq` Features assume Debian/Ubuntu (`apt-get`/`dpkg`), so they fail on Fedora and other distros. The one Feature found that avoids a package manager does a bare `curl` with no checksum verification.

This Feature does neither: it runs no package manager, and it verifies the downloaded binary against a pinned sha256 before installing it. A checksum mismatch aborts the install.

If you bump `version`, you must also update `sha256` to match, or the install will fail. Get the correct hash from the release page, e.g.:

```bash
curl -fsSL https://github.com/mikefarah/yq/releases/download/v<version>/yq_linux_amd64 | sha256sum
```

## OS Support

This Feature works on any Linux distribution with `curl` and `sha256sum` present (Fedora, Debian/Ubuntu, Alpine, etc). It does not call `dnf`, `apt-get`, `apk`, or any other package manager.

Only `x86_64` is supported, matching the naming of the upstream `yq_linux_amd64` release asset. The install fails loudly on any other architecture rather than installing a binary that cannot run.

`sh` is required to execute the `install.sh` script.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/sdwilsh/devcontainer-features/blob/main/src/yq/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
