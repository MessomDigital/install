#!/usr/bin/env bash
set -euo pipefail

REMOTE_DIR="monitoring"
DEST_DIR="scripts"

# If you prefer a branch instead of a pinned commit, change REF to e.g. "main".
BASE_URL="https://repo.messom.no/install/${REMOTE_DIR}"

FILES=(
  "azure_applicationinsights_template.json"
  "azure_applicationinsights.properties"
  "update-azure-applicationinsights.sh"
)

mkdir -p "${DEST_DIR}"

download() {
  local url="$1"
  local out="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$out"
  else
    echo "ERROR: Need either curl or wget installed." >&2
    exit 1
  fi
}

for f in "${FILES[@]}"; do
  echo "Downloading ${REMOTE_DIR}/${f} -> ${DEST_DIR}/${f}"
  download "${BASE_URL}/${f}" "${DEST_DIR}/${f}"
done

# Make shell scripts executable
chmod +x "${DEST_DIR}"/*.sh 2>/dev/null || true

mv "${DEST_DIR}/azure_applicationinsights_template.json" "./azure_applicationinsights_template.json"

echo "Done. Downloaded ${#FILES[@]} file(s) into ./${DEST_DIR}/"
echo "Please rename, and update the azure_applicationinsights_template.json file with \"connectionString\" and \"role.name\"."