#!/usr/bin/env bash
set -euo pipefail

# 1. Ensure ~/.local/bin exists and is in PATH
install_dir="$HOME/.local/bin"
mkdir -p "$install_dir"
if ! echo "$PATH" | grep -q "$install_dir"; then
  echo "⚠️  Note: $install_dir is not in your PATH."
  echo "   Add the following line to your shell rc (e.g. ~/.bashrc):"
  echo "     export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# 2. Fetch latest release download URL from GitHub API
echo "🔍  Determining latest Syncthing release..."
latest_url=$(curl -s \
  https://api.github.com/repos/syncthing/syncthing/releases/latest \
  | grep 'browser_download_url.*linux-amd64' \
  | head -n1 \
  | cut -d '"' -f 4)
if [[ -z "$latest_url" ]]; then
  echo "❌  Could not determine download URL."
  exit 1
fi
echo "✅  Latest tarball URL: $latest_url"

# 3. Download and extract only the 'syncthing' binary
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
echo "📦  Downloading..."
curl -L "$latest_url" -o "$tmpdir/syncthing.tar.gz"
echo "🔓  Extracting..."
tar -xzf "$tmpdir/syncthing.tar.gz" -C "$tmpdir"
# The tarball creates a folder like syncthing-linux-amd64-vX.Y.Z
bin_path=$(find "$tmpdir" -maxdepth 2 -type f -name syncthing | head -n1)
if [[ ! -x "$bin_path" ]]; then
  echo "❌  Extracted binary not found or not executable."
  exit 1
fi

# 4. Install into ~/.local/bin
echo "🚚  Installing to $install_dir..."
install -m 0755 "$bin_path" "$install_dir/syncthing"

# 5. Verify
echo "🔧  Verifying installation..."
if command -v syncthing >/dev/null; then
  echo "🎉  Syncthing installed successfully!"
  syncthing --version
else
  echo "❌  syncthing not found in PATH."
  exit 1
fi
