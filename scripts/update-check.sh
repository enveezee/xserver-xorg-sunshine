#!/bin/bash
set -x  # Print every command as it runs

echo "===== DEBUG START ====="
echo "Timestamp: $(date)"
echo "PWD: $(pwd)"
echo "Script path: $0"
echo "User: $(whoami)"
echo "Shell: $SHELL"
echo "Env dump:"
env | sort

echo "----- GITHUB_OUTPUT -----"
echo "GITHUB_OUTPUT='$GITHUB_OUTPUT'"
echo "File exists? $(test -e "$GITHUB_OUTPUT" && echo yes || echo no)"
echo "Writable? $(test -w "$GITHUB_OUTPUT" && echo yes || echo no)"
echo "-------------------------"

FORCE="${FORCE:-false}"
echo "FORCE='$FORCE'"

# Force rebuild
if [ "$FORCE" = "true" ]; then
    echo "FORCE triggered, writing skip=false"
    echo "skip=false" >> "$GITHUB_OUTPUT"
    echo "Github rebuild forced, skipping version update checks."
    echo "===== DEBUG END (FORCE) ====="
    exit 0
fi

echo "Checking for Debian updates of xserver-xorg-core version..."

RAW_DEBIAN_LIST=$(curl -fsS https://packages.debian.org/stable/allpackages?format=txt.gz | gunzip)
echo "RAW_DEBIAN_LIST (first 20 lines):"
echo "$RAW_DEBIAN_LIST" | head -n 20

DEBIAN_VERSION=$(echo "$RAW_DEBIAN_LIST" | perl -nE '/^xserver-xorg-core \((.+)\)/ && say $1')
echo "Extracted DEBIAN_VERSION='$DEBIAN_VERSION'"

# Validate version format
if ! printf '%s' "$DEBIAN_VERSION" | grep -Eq '^[0-9].*[-+][a-zA-Z0-9]'; then
    echo "ERROR: Extracted version string is invalid: '$DEBIAN_VERSION'"
    echo "skip=true" >> "$GITHUB_OUTPUT"
    echo "===== DEBUG END (INVALID DEBIAN VERSION) ====="
    exit 0
fi

echo "Latest Debian version: $DEBIAN_VERSION"

echo "Fetching latest release tag from GitHub API..."
RAW_RELEASE_JSON=$(curl -fsSL https://api.github.com/repos/$REPO/releases/latest)
echo "RAW_RELEASE_JSON:"
echo "$RAW_RELEASE_JSON"

LATEST_TAG=$(echo "$RAW_RELEASE_JSON" | grep '"tag_name"' | cut -d '"' -f 4)
echo "Extracted LATEST_TAG='$LATEST_TAG'"

# No previous release → build
if [ -z "$LATEST_TAG" ]; then
    echo "No previous release found. Forcing initial build."
    echo "skip=false" >> "$GITHUB_OUTPUT"
    echo "===== DEBUG END (NO PREVIOUS RELEASE) ====="
    exit 0
fi

# Validate tag format
if ! printf '%s' "$LATEST_TAG" | grep -Eq '^xorg-'; then
    echo "ERROR: Latest release tag invalid or missing: '$LATEST_TAG'"
    echo "skip=true" >> "$GITHUB_OUTPUT"
    echo "===== DEBUG END (INVALID TAG FORMAT) ====="
    exit 0
fi

LATEST_VERSION=${LATEST_TAG#xorg-}
echo "LATEST_VERSION='$LATEST_VERSION'"

echo "Comparing:"
echo "  DEBIAN_VERSION='$DEBIAN_VERSION'"
echo "  LATEST_VERSION='$LATEST_VERSION'"

if [ "$DEBIAN_VERSION" = "$LATEST_VERSION" ]; then
    echo "Versions match → skip build"
    echo "skip=true" >> "$GITHUB_OUTPUT"
    echo "===== DEBUG END (MATCH) ====="
    exit 0
fi

echo "Versions differ → build required"
echo "skip=false" >> "$GITHUB_OUTPUT"
echo "===== DEBUG END (DIFFER) ====="
exit 0
