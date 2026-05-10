#!/usr/bin/env bash
# Ensure pngquant is available, cross-platform, no sudo required.
#
# Strategy (in order):
#   1. If pngquant is already in PATH -> done
#   2. If tools/bin/pngquant already exists -> done
#   3. Detect OS:
#      - Windows (Git Bash / MSYS): download prebuilt from pngquant.org
#      - Linux / Mac: build from source via cargo (Rust 1.70+)
#
# pngquant >= 3.0 uses Cargo, not the old configure/make. Cargo must be
# installed (https://rustup.rs).
#
# The compiled binary lands in tools/bin/pngquant and is gitignored.

set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_BIN="$PROJECT_ROOT/tools/bin"
LOCAL_PNGQUANT="$TOOLS_BIN/pngquant"

# 1. Already in PATH
if command -v pngquant >/dev/null 2>&1; then
  echo "[ok] pngquant already in PATH: $(command -v pngquant) ($(pngquant --version 2>&1 | head -1))"
  exit 0
fi

# 2. Already in tools/bin
if [ -x "$LOCAL_PNGQUANT" ] || [ -x "$LOCAL_PNGQUANT.exe" ]; then
  echo "[ok] pngquant already in tools/bin/"
  echo "     Add to PATH: export PATH=\"$TOOLS_BIN:\$PATH\""
  exit 0
fi

mkdir -p "$TOOLS_BIN"
OS="$(uname -s)"
ARCH="$(uname -m)"

echo "[info] pngquant not found. Detected OS=$OS ARCH=$ARCH"
echo "[info] Will install to $LOCAL_PNGQUANT"

build_with_cargo() {
  # Check git
  if ! command -v git >/dev/null 2>&1; then
    echo "[error] git is required to clone the pngquant source"
    case "$OS" in
      Linux*)
        echo "        Install: sudo apt install git           (Debian / Ubuntu)"
        echo "                 sudo dnf install git           (Fedora)"
        echo "                 sudo pacman -S git             (Arch)"
        ;;
      Darwin*)
        echo "        Install: xcode-select --install          (Xcode CLI tools include git)"
        echo "                 OR: brew install git"
        ;;
    esac
    return 1
  fi

  # Check cargo
  if ! command -v cargo >/dev/null 2>&1; then
    echo "[error] cargo (Rust 1.70+) is required to build pngquant from source"
    echo "        Install Rust via rustup (no sudo, user-local):"
    echo "          curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    echo "          source \"\$HOME/.cargo/env\""
    echo "        Or check https://rustup.rs for OS-specific instructions."
    return 1
  fi

  local rust_version
  rust_version="$(cargo --version | awk '{print $2}')"
  echo "[info] using git $(git --version | awk '{print $3}') + cargo $rust_version"

  local src_dir
  src_dir="$(mktemp -d)"
  trap 'rm -rf "$src_dir"' RETURN

  echo "[step] Cloning kornelski/pngquant"
  if ! git clone --depth=1 --recurse-submodules https://github.com/kornelski/pngquant.git "$src_dir" >/dev/null 2>&1; then
    echo "[error] git clone failed. Possible causes:"
    echo "        - No network access"
    echo "        - GitHub is unreachable from this network"
    echo "        - Submodule clone failed (try: git clone --recurse-submodules ... manually)"
    return 1
  fi

  echo "[step] cargo build --release (this can take 1-3 min the first time)"
  (
    cd "$src_dir" &&
    cargo build --release
  ) || {
    echo "[error] cargo build failed. Run manually for details:"
    echo "        cd $src_dir && cargo build --release"
    return 1
  }

  if [ -x "$src_dir/target/release/pngquant" ]; then
    cp "$src_dir/target/release/pngquant" "$LOCAL_PNGQUANT"
    chmod +x "$LOCAL_PNGQUANT"
  elif [ -x "$src_dir/target/release/pngquant.exe" ]; then
    cp "$src_dir/target/release/pngquant.exe" "$LOCAL_PNGQUANT.exe"
  else
    echo "[error] cargo build succeeded but binary not found in target/release/"
    return 1
  fi
  return 0
}

download_windows_release() {
  echo "[step] Downloading pngquant for Windows from pngquant.org"
  local url="https://pngquant.org/pngquant-windows.zip"
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  curl -fsSL "$url" -o "$tmp/pngquant.zip" || return 1
  unzip -q "$tmp/pngquant.zip" -d "$tmp" || return 1
  local exe
  exe="$(find "$tmp" -name 'pngquant.exe' -print -quit)"
  [ -n "$exe" ] || return 1
  cp "$exe" "$LOCAL_PNGQUANT.exe"
  return 0
}

case "$OS" in
  Linux*|Darwin*)
    build_with_cargo || exit 1
    ;;
  MINGW*|CYGWIN*|MSYS*)
    download_windows_release || {
      echo "[fallback] Trying cargo build instead"
      build_with_cargo || exit 1
    }
    ;;
  *)
    echo "[error] unsupported OS: $OS"
    exit 1
    ;;
esac

if [ -x "$LOCAL_PNGQUANT" ] || [ -x "$LOCAL_PNGQUANT.exe" ]; then
  echo "[ok] pngquant installed to $LOCAL_PNGQUANT"
  echo "     Add to PATH for this shell: export PATH=\"$TOOLS_BIN:\$PATH\""
else
  echo "[error] installation finished but binary not found"
  exit 1
fi
