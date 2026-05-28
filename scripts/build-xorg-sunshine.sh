#!/bin/bash
set -e

# Locate source dir
PKGDIR=$(find . -maxdepth 1 -type d -name ( -name "xorg-server-*" -o -name "xserver-xorg-core-*" ) | head -n1)
if [ -z "$PKGDIR" ]; then
    echo "Source dir not found."
    exit 1
fi

# Copy our package files
cp -r debian/* "$PKGDIR/debian/"

# Enter the source dir
cd "$PKGDIR"

# Manage permissions of added files
chmod 755 debian/xserver-xorg-sunshine/usr/bin/Xorg-sunshine
chmod 755 debian/xserver-xorg-sunshine/usr/local/bin/update-sunshine-xorg
chmod 755 debian/xserver-xorg-sunshine/usr/local/sbin/xserver-xorg-sunshine-update
chmod 644 debian/xserver-xorg-sunshine/lib/systemd/system/xserver-xorg-sunshine-update.service

# Build the renamed core package
dpkg-buildpackage -b -d -us -uc -Pnocheck

# Move artifacts
mkdir -p ../artifacts
mv ../xserver-xorg-sunshine_*.deb ../artifacts/
