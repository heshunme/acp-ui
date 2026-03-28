#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_TRIPLE="${TARGET_TRIPLE:-x86_64-pc-windows-gnu}"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT/artifacts/windows-x64-exe}"
NPM_CACHE_DIR="${NPM_CACHE_DIR:-/tmp/.npm}"
EXE_NAME="acp-ui.exe"
DLL_NAME="WebView2Loader.dll"

log() {
  printf '[build-windows-exe] %s\n' "$*"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

if [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1090
  . "$HOME/.cargo/env"
fi

require_cmd npm
require_cmd cargo
require_cmd rustup
require_cmd x86_64-w64-mingw32-gcc
require_cmd x86_64-w64-mingw32-g++

mkdir -p "$NPM_CACHE_DIR"
cd "$REPO_ROOT"

if [[ ! -d node_modules ]]; then
  log "Installing npm dependencies"
  env npm_config_cache="$NPM_CACHE_DIR" npm install
fi

if ! rustup target list --installed | grep -qx "$TARGET_TRIPLE"; then
  log "Installing Rust target $TARGET_TRIPLE"
  rustup target add "$TARGET_TRIPLE"
fi

log "Building Windows executable for $TARGET_TRIPLE"
export CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc
export CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc
export CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++
env npm_config_cache="$NPM_CACHE_DIR" npm exec tauri build -- --target "$TARGET_TRIPLE" --no-bundle --ignore-version-mismatches

RELEASE_DIR="$REPO_ROOT/src-tauri/target/$TARGET_TRIPLE/release"
EXE_PATH="$RELEASE_DIR/$EXE_NAME"
DLL_PATH="$RELEASE_DIR/$DLL_NAME"

if [[ ! -f "$EXE_PATH" ]]; then
  printf 'Expected executable not found: %s\n' "$EXE_PATH" >&2
  exit 1
fi

if [[ ! -f "$DLL_PATH" ]]; then
  printf 'Expected WebView2 loader not found: %s\n' "$DLL_PATH" >&2
  exit 1
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cp "$EXE_PATH" "$OUTPUT_DIR/"
cp "$DLL_PATH" "$OUTPUT_DIR/"

cat >"$OUTPUT_DIR/README.txt" <<'EOF'
Run acp-ui.exe and keep WebView2Loader.dll in the same directory.

This package contains:
- acp-ui.exe
- WebView2Loader.dll

If the app fails to start because WebView2 runtime is missing, install:
https://developer.microsoft.com/microsoft-edge/webview2/
EOF

if command -v zip >/dev/null 2>&1; then
  (
    cd "$OUTPUT_DIR/.."
    rm -f windows-x64-exe.zip
    zip -rq windows-x64-exe.zip "$(basename "$OUTPUT_DIR")"
  )
  log "Created zip archive at $OUTPUT_DIR/../windows-x64-exe.zip"
fi

log "Build complete"
log "Executable: $OUTPUT_DIR/$EXE_NAME"
log "Support DLL: $OUTPUT_DIR/$DLL_NAME"
