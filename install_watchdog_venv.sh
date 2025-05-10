#!/usr/bin/env bash
set -euo pipefail

# 1. Paths for venv tools
VENV_DIR="${HOME}/.local/venvs/pip-env"
VENV_PIP="${VENV_DIR}/bin/pip"
VENV_PYTHON="${VENV_DIR}/bin/python"

# 2. Check that the venv exists
if [[ ! -x "$VENV_PIP" || ! -x "$VENV_PYTHON" ]]; then
  echo "Error: Virtual environment not found or incomplete at $VENV_DIR" >&2
  echo "Make sure you have a venv with pip and python in $VENV_DIR/bin/" >&2
  exit 1
fi

# 3. (Optional) Source your PATH helper if needed
if [[ -f "${HOME}/profile_path.sh" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/profile_path.sh"
fi

# 4. Upgrade pip, setuptools, and wheel inside the venv
echo "Upgrading core packaging tools in the venv..."
"$VENV_PIP" install --upgrade pip setuptools wheel

# 5. Install Watchdog into the venv
echo "Installing Watchdog into the venv..."
"$VENV_PIP" install watchdog

# 6. Verify by importing with the venv’s Python
echo "Verifying Watchdog installation..."
if "$VENV_PYTHON" - <<'PYCODE'
import sys
try:
    import watchdog
    print("✔ watchdog imported successfully")
    sys.exit(0)
except Exception as e:
    print(f"✘ Import failed: {e}", file=sys.stderr)
    sys.exit(1)
PYCODE
then
    echo "Success: Watchdog is installed and importable in $VENV_DIR"
    echo "Activate with: source \"$VENV_DIR/bin/activate\""
else
    echo "Error: Watchdog import failed in the virtual environment." >&2
    exit 1
fi
