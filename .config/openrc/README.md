# OpenRC User Services

User-level OpenRC init scripts for Artix Linux, mirroring the systemd user
services in `.config/systemd/user/`.

## Setup

Requires the `openrc-user` package:

```bash
sudo pacman -S openrc-user
```

Enable a service for your user session:

```bash
rc-config add ssh-agent default
```

Services are stored in `init.d/` and follow standard OpenRC init script conventions.
The socket and pidfile are placed in `$XDG_RUNTIME_DIR` (typically `/run/user/1000`).
