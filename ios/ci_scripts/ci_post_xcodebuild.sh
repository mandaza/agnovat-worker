#!/bin/sh
set -euxo pipefail

echo "======================================"
echo "Xcode Cloud Build Script (Flutter)"
echo "======================================"

# Make sure Flutter is on PATH again
export PATH="$HOME/flutter/bin:$PATH"

# Determine repository path
if [ -n "${CI_PRIMARY_REPOSITORY_PATH:-}" ]; then
  REPO_PATH="$CI_PRIMARY_REPOSITORY_PATH"
elif [ -n "${CI_WORKSPACE:-}" ]; then
  REPO_PATH="$CI_WORKSPACE"
else
  REPO_PATH="$(pwd)"
fi

cd "$REPO_PATH"

echo "🔍 Flutter version:"
flutter --version

echo "📦 Running flutter pub get..."
flutter pub get

echo "🏗️ Building Flutter iOS release..."
flutter build ipa --release --no-tree-shake-icons

echo "✅ ci_post_xcodebuild.sh complete!"
