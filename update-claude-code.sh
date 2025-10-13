#!/usr/bin/env bash
set -euo pipefail

# Script to update Claude Code version in home-manager configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_NIX="$SCRIPT_DIR/home.nix"

echo "Fetching latest Claude Code version from npm..."
LATEST_VERSION=$(curl -s https://registry.npmjs.org/@anthropic-ai/claude-code/latest | jq -r '.version')

if [[ -z "$LATEST_VERSION" ]]; then
    echo "Error: Failed to fetch latest version from npm"
    exit 1
fi

echo "Latest version: $LATEST_VERSION"

# Check current version in home.nix
CURRENT_VERSION=$(grep -A1 'claude-code.overrideAttrs' "$HOME_NIX" | grep 'version =' | sed 's/.*version = "\(.*\)";.*/\1/')

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    echo "Already on latest version ($LATEST_VERSION)"
    exit 0
fi

echo "Current version: $CURRENT_VERSION"
echo "Updating to: $LATEST_VERSION"

# Download tarball and calculate hash
echo "Calculating hash for version $LATEST_VERSION..."
TARBALL_URL="https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${LATEST_VERSION}.tgz"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cd "$TEMP_DIR"
curl -sL "$TARBALL_URL" -o claude-code.tgz

# Calculate SHA256 hash in Nix SRI format
HASH=$(nix-hash --flat --base32 --type sha256 claude-code.tgz)
SRI_HASH="sha256-$(nix-hash --to-sri --type sha256 "$HASH")"

echo "Hash: $SRI_HASH"

# Update home.nix
echo "Updating $HOME_NIX..."

# Create a temporary file with the updated configuration
sed -e "s/version = \"${CURRENT_VERSION}\";/version = \"${LATEST_VERSION}\";/" \
    -e "s|hash = \"sha256-[^\"]*\";|hash = \"${SRI_HASH}\";|" \
    "$HOME_NIX" > "${HOME_NIX}.tmp"

# Move the temporary file to replace the original
mv "${HOME_NIX}.tmp" "$HOME_NIX"

echo ""
echo "✓ Successfully updated Claude Code from $CURRENT_VERSION to $LATEST_VERSION"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff $HOME_NIX"
echo "  2. Build and switch: home-manager switch"
echo "  3. Verify: claude-code --version"
