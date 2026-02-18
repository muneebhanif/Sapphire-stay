#!/bin/bash
set -e

# Install Flutter SDK
FLUTTER_VERSION="3.27.4"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

echo ">>> Downloading Flutter ${FLUTTER_VERSION}..."
curl -sL "$FLUTTER_URL" | tar xJf - -C /tmp

# Fix git dubious ownership error (Vercel runs as root)
git config --global --add safe.directory /tmp/flutter
git config --global --add safe.directory "$(pwd)"

export PATH="/tmp/flutter/bin:/tmp/flutter/bin/cache/dart-sdk/bin:$PATH"
export FLUTTER_ROOT="/tmp/flutter"

# Suppress analytics and first-run prompts
flutter config --no-analytics --no-cli-animations 2>/dev/null || true

echo ">>> Flutter version:"
flutter --version

echo ">>> Getting dependencies..."
flutter pub get

echo ">>> Building Flutter web (release)..."
flutter build web --release

echo ">>> Build complete! Output in build/web"
