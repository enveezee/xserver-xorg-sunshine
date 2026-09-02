#!/bin/bash
set -e

# Locate source dir
PKGDIR=$(find . -maxdepth 1 -type d -name "xorg-server-*" -o -name "xserver-xorg-core-*" | head -n1 )
if [ -z "$PKGDIR" ]; then
    echo "Source dir not found."
    exit 1
fi

# Copy our package files
cp -r debian/* "$PKGDIR/debian/"

# Enter the source dir
cd "$PKGDIR"

# Build the renamed core package
dpkg-buildpackage -b -d -us -uc -Pnocheck

# Move artifacts
mkdir -p ../artifacts
mv ../xserver-xorg-sunshine_*.deb ../artifacts/
