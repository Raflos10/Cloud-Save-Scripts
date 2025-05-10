#!/usr/bin/env bash
set -euo pipefail

# 1. Determine OS and architecture
OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH_RAW=$(uname -m)
case "$ARCH_RAW" in
  x86_64) ARCH="amd64" ;;
  i386|i686) ARCH="386" ;;
  armv7*|armv6*) ARCH="arm-v7" ;;
  aarch64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH_RAW" >&2; exit 1 ;;
esac

ZIP_NAME="rclone-current-${OS}-${ARCH}.zip"
DOWNLOAD_URL="https://downloads.rclone.org/${ZIP_NAME}"

# 2. Download and unpack
TMPDIR=$(mktemp -d)
echo "Downloading ${ZIP_NAME}..."
curl -fsSL "$DOWNLOAD_URL" -o "$TMPDIR/${ZIP_NAME}"
unzip -q "$TMPDIR/${ZIP_NAME}" -d "$TMPDIR"

# 3. Find the extracted directory
EXTRACTED_DIR=$(find "$TMPDIR" -maxdepth 1 -type d -name "rclone-*-linux-${ARCH}" | head -n1)
if [[ -z "$EXTRACTED_DIR" ]]; then
  echo "Error: could not find extracted rclone directory in $TMPDIR" >&2
  exit 1
fi

# 4. Install to user directory
RC_DIR="$HOME/.local"
BIN_DIR="$RC_DIR/bin"
MAN_DIR="$RC_DIR/share/man/man1"
DOC_DIR="$RC_DIR/share/doc/rclone"

mkdir -p "$BIN_DIR" "$MAN_DIR" "$DOC_DIR"

# Copy the main binary
cp "$EXTRACTED_DIR/rclone" "$BIN_DIR/"
chmod u+x "$BIN_DIR/rclone"

# Copy the man page if present
if [[ -f "$EXTRACTED_DIR/rclone.1" ]]; then
  cp "$EXTRACTED_DIR/rclone.1" "$MAN_DIR/"
fi

# Copy additional docs only if they exist
if [[ -d "$EXTRACTED_DIR/doc" ]]; then
  cp -r "$EXTRACTED_DIR/doc/"* "$DOC_DIR/"
fi

# 5. Cleanup
rm -rf "$TMPDIR"

# 6. Run profile_path.sh if it exists and is executable
PROFILE_PATH_SCRIPT="$HOME/profile_path.sh"
if [[ -x "$PROFILE_PATH_SCRIPT" ]]; then
  echo "Running profile_path.sh to update PATH..."
  "$PROFILE_PATH_SCRIPT"
else
  echo "Warning: profile_path.sh not found or not executable at $PROFILE_PATH_SCRIPT"
fi

# 7. Completion message
echo
echo "Installation complete!"
echo "You can now run 'rclone version' to verify."
