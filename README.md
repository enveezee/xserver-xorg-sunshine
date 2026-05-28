# xserver-xorg-sunshine

Minimal Debian packaging for a headless Xorg server optimized for Sunshine streaming.

This repository provides:
- Debian packaging under `debian/` for `xserver-xorg-sunshine`
- A stripped-down, GPU-accelerated Xorg build targeted at headless streaming
- Build helper scripts in `scripts/`

## Build

1. Place or extract an `xorg-server-*` or `xserver-xorg-core-*` source tree in the repository root.
2. Run:

```bash
scripts/build-xorg-sunshine.sh
```

3. Resulting package files are moved to `artifacts/`.

## Notes

- The package disables desktop-focused features like logind, suid, Xwayland, and nested servers.
- It is intended for use with Sunshine streaming setups.
