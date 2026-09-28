
# SSH server (sshd)

Adds a SSH server into a container so that you can use an external terminal, sftp, or SSHFS to interact with it.

This is a local fork of the upstream [`ghcr.io/devcontainers/features/sshd`](https://github.com/devcontainers/features/tree/main/src/sshd) feature. Upstream's `install.sh` only supports `apt`. This fork adds Fedora/RHEL (`dnf`/`yum`) support with a minimal diff, so it can be upstreamed later.

## Example Usage

```json
"features": {
    "sshd": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Currently unused. | string | latest |
| gatewayPorts | Enable other hosts in the same network to connect to the forwarded ports | string | no |

## Usage

While some services automate SSH setup (e.g., when using the GitHub CLI for GitHub Codespaces), this may not be the case for other tools and services. Follow these directions to connect to the dev container from these other tools:

1. Connect to your dev container using a desktop tool or CLI that supports the dev container spec (e.g., VS Code client).

2. The first time you've started the container, you will want to set a password for your user. If running as a user other than root, and you have `sudo` installed:

    ```bash
    sudo passwd $(whoami)
    ```

    Or if you are running as root:

    ```bash
    passwd
    ```

3. Forward the SSH port (`2222` by default) to your local machine using either the `forwardPorts` property in `devcontainer.json` or the user interface in your tool.

4. Use a **local terminal** (or other tool) to connect to it using the command and password from step 2. e.g.

    ```bash
    ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null vscode@localhost
    ```

    ...where `vscode` above is the user you are running as in the container and `2222` after `-p` is the **local address port** from step 3.

5. Next time you connect to your container, just repeat steps 3 and 4 and use the same password you set in step 2.

### Using SSHFS

[SSHFS](https://en.wikipedia.org/wiki/SSHFS) allows you to mount a remote filesystem to your local machine with nothing but a SSH connection. Here's how to use it with a dev container.

1. Follow the steps in the previous section to ensure you can connect to the dev container using the normal `ssh` client.

2. Install a SSHFS client for your platform.

3. Mount the remote filesystem, e.g. on macOS/Linux:

    ```bash
    mkdir -p ~/sshfs/devcontainer
    sshfs "vscode@localhost:/workspaces" "$HOME/sshfs/devcontainer" -p 2222 -o follow_symlinks -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -C
    ```

## OS Support

This Feature works on Debian/Ubuntu-based distributions with `apt`, and on Fedora/RHEL-based distributions with `dnf` or `yum`.

`bash` is required to execute the `install.sh` script.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
