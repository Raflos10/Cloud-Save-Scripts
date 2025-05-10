#!/usr/bin/env bash
set -euo pipefail

# 1. Source your PATH helper
#    Ensure ~/.local/bin is on PATH so pip installs are available immediately :contentReference[oaicite:3]{index=3}
if [[ -f "profile_path.sh" ]]; then
  # shellcheck source=/dev/null
  source "profile_path.sh"
else
  echo "Warning: profile_path.sh not found; ensure ~/.local/bin is in your PATH manually." >&2
fi

# 2. Variables
PIP_URL="https://bootstrap.pypa.io/get-pip.py"
TMP_GET_PIP="/tmp/get-pip.py"
VENV_DIR="${HOME}/.local/venvs/pip-env"

# 3. Download get-pip.py
echo "Downloading get-pip.py..."
curl -sSL "${PIP_URL}" -o "${TMP_GET_PIP}" || {
  echo "Error: failed to download get-pip.py" >&2
  exit 1
}  # :contentReference[oaicite:1]{index=1}

# 4. Try user-level install of pip
echo "Attempting user-level pip install..."
if python3 "${TMP_GET_PIP}" --user; then
  echo "✔ pip installed in user site—no venv needed."
else
  # 5. Handle externally-managed-environment error by using a venv
  echo "Detected externally-managed environment. Creating a per-user venv…"
  python3 -m venv "${VENV_DIR}"                                             # :contentReference[oaicite:2]{index=2}
  source "${VENV_DIR}/bin/activate"
  echo "Installing pip inside venv at '${VENV_DIR}'…"
  python3 "${TMP_GET_PIP}"                                                    \
    --upgrade                                                               \
    --force-reinstall                                                        \
    --break-system-packages   # allow install inside venv despite PEP 668 :contentReference[oaicite:3]{index=3}
  deactivate
  echo "✔ pip installed in venv: ${VENV_DIR}/bin/pip"
fi

# 6. Cleanup
rm -f "${TMP_GET_PIP}"

# 7. Verify installation
if command -v pip3 &>/dev/null; then
  echo "Final pip location: $(command -v pip3)"
  pip3 --version
elif [[ -x "${VENV_DIR}/bin/pip" ]]; then
  echo "Activate your venv with:"
  echo "  source \"${VENV_DIR}/bin/activate\""
  echo "Then use 'pip' from there:"
  echo "  pip --version"
else
  echo "Error: pip installation not found!" >&2
  exit 1
fi
