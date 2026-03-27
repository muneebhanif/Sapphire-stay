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

echo ">>> Preparing environment variables..."
if [ -z "$FLUTTER_CONVEX_URL" ] && [ -n "$CONVEX_URL" ]; then
  export FLUTTER_CONVEX_URL="$CONVEX_URL"
fi
if [ -z "$FLUTTER_CONVEX_HTTP_URL" ] && [ -n "$CONVEX_SITE_URL" ]; then
  export FLUTTER_CONVEX_HTTP_URL="$CONVEX_SITE_URL"
fi

if [ -n "$FLUTTER_CONVEX_URL" ]; then
  echo ">>> Generating .env file..."
  cat <<EOF > .env
FLUTTER_CONVEX_URL=$FLUTTER_CONVEX_URL
FLUTTER_CONVEX_HTTP_URL=$FLUTTER_CONVEX_HTTP_URL
EOF
fi

echo ">>> Building Flutter web (release)..."
if [ -f .env ]; then
  flutter build web --release --dart-define-from-file=.env
else
  flutter build web --release
fi

echo ">>> Build complete! Output in build/web"
