#!/bin/bash
set -e

# Install Flutter SDK
FLUTTER_VERSION="3.27.4"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

echo ">>> Downloading Flutter ${FLUTTER_VERSION}..."
curl -sL "$FLUTTER_URL" | tar xJf - -C /tmp

export PATH="/tmp/flutter/bin:$PATH"

echo ">>> Flutter version:"
flutter --version

echo ">>> Enabling web..."
flutter config --enable-web

echo ">>> Getting dependencies..."
flutter pub get

echo ">>> Building Flutter web (release)..."
flutter build web --release --web-renderer html

echo ">>> Build complete! Output in build/web"
