#!/bin/bash

FORCE="${FORCE:-false}"

# Force rebuild
if [ "$FORCE" = "true" ]; then
    echo "skip=false" >> "$GITHUB_OUTPUT"
    echo "Github rebuild forced, skipping version update checks."
    exit 0
fi

echo "Checking for Debian updates of xserver-xorg-core version..."

DEBIAN_VERSION=$(
  curl -fsS https://packages.debian.org/stable/allpackages?format=txt.gz \
    | gunzip - \
    | perl -nE '/^xserver-xorg-core \((.+)\)/ && say $1' \
    || true
)

# Validate version format
if ! printf '%s' "$DEBIAN_VERSION" | grep -Eq '^[0-9].*[-+][a-zA-Z0-9]'; then
    echo "ERROR: Extracted version string is invalid: '$DEBIAN_VERSION'"
    echo "skip=true" >> "$GITHUB_OUTPUT"
    exit 0
fi

echo "Latest Debian version: $DEBIAN_VERSION"

# Fetch latest release tag
LATEST_TAG=$(curl -fsSL https://api.github.com/repos/$REPO/releases/latest \
    | grep '"tag_name"' | cut -d '"' -f 4 \
    || true)

# No previous release → build
if [ -z "$LATEST_TAG" ]; then
    echo "No previous release found. Forcing initial build."
    echo "skip=false" >> "$GITHUB_OUTPUT"
    exit 0
fi

# Validate tag format
if ! printf '%s' "$LATEST_TAG" | grep -Eq '^xorg-'; then
    echo "ERROR: Latest release tag invalid or missing: '$LATEST_TAG'"
    echo "skip=true" >> "$GITHUB_OUTPUT"
    exit 0
fi

LATEST_VERSION=${LATEST_TAG#xorg-}

echo "Latest built version: $LATEST_VERSION"

# Compare
if [ "$DEBIAN_VERSION" = "$LATEST_VERSION" ]; then
    echo "skip=true" >> "$GITHUB_OUTPUT"
    exit 0
fi

echo "skip=false" >> "$GITHUB_OUTPUT"
echo "New version $DEBIAN_VERSION detected. Proceeding with build."
exit 0
