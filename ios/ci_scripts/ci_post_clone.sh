#!/bin/sh
set -euxo pipefail

echo "======================================"
echo "Xcode Cloud Post-Clone Setup (Flutter)"
echo "======================================"

# Determine repository path
if [ -n "${CI_PRIMARY_REPOSITORY_PATH:-}" ]; then
  REPO_PATH="$CI_PRIMARY_REPOSITORY_PATH"
elif [ -n "${CI_WORKSPACE:-}" ]; then
  REPO_PATH="$CI_WORKSPACE"
else
  REPO_PATH="$(pwd)"
fi

echo "Working directory: $REPO_PATH"
ls -la "$REPO_PATH"

# --------------------------------------
# Install Flutter if not available
# --------------------------------------
if ! command -v flutter >/dev/null 2>&1; then
  echo "📦 Installing Flutter (stable) ..."
  cd "$HOME"

  # Clean any previous install
  rm -rf flutter

  git clone https://github.com/flutter/flutter.git -b stable --depth 1
  export PATH="$HOME/flutter/bin:$PATH"
  echo "✅ Flutter installed at $HOME/flutter"
else
  echo "✅ Flutter already available"
  # Make sure bin directory is on PATH
  export PATH="$HOME/flutter/bin:$PATH"
fi

echo "🔍 Flutter version:"
flutter --version

# --------------------------------------
# Flutter dependencies
# --------------------------------------
cd "$REPO_PATH"

echo "📦 Running flutter pub get..."
flutter pub get

echo "📦 Pre-caching iOS artifacts..."
flutter precache --ios

echo "📦 Running flutter clean to ensure fresh build..."
flutter clean

echo "📦 Running flutter pub get again after clean..."
flutter pub get

echo "🔍 Checking iOS plugin symlinks..."
ls -la "$REPO_PATH/ios/.symlinks/plugins/" || echo "⚠️  Plugin symlinks not yet created"

# --------------------------------------
# CocoaPods
# --------------------------------------
if ! command -v pod >/dev/null 2>&1; then
  echo "❌ CocoaPods (pod) command not found on this image."
  exit 1
fi

echo "📦 Running pod install..."
cd "$REPO_PATH/ios"

# Remove old Pods and regenerate
rm -rf Pods Podfile.lock

# Update pod repo for latest specs
pod repo update

# Install with verbose output
pod install --verbose

echo "🔍 Verifying flutter_secure_storage pod..."
ls -la Pods/flutter_secure_storage/ || echo "⚠️  flutter_secure_storage pod not found"

echo "✅ ci_post_clone.sh setup complete!"
