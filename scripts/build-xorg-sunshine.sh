#!/bin/bash
set -e

# Locate source dir
PKGDIR=$(find . -maxdepth 1 -type d -name "xorg-server-*" | head -n1)
if [ -z "$PKGDIR" ]; then
    echo "Source dir not found."
    exit 1
fi

# Copy our package files
cp debian/* "$PKGDIR/debian/"

# Enter the source dir
cd "$PKGDIR"

# Build ONLY the renamed core package
DH_OPTIONS="-p xserver-xorg-sunshine" dpkg-buildpackage -b -d -us -uc -Pnocheck

# Move artifacts
mkdir -p ../artifacts
mv ../xserver-xorg-sunshine_*.deb ../artifacts/
