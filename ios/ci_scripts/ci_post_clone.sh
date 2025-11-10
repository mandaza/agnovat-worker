#!/bin/sh

set -e

echo "======================================"
echo "Xcode Cloud Post-Clone Setup"
echo "======================================"

# Determine repository path
if [ -z "$CI_PRIMARY_REPOSITORY_PATH" ]; then
    REPO_PATH="${CI_WORKSPACE:-$(pwd)}"
else
    REPO_PATH="$CI_PRIMARY_REPOSITORY_PATH"
fi

echo "Working directory: $REPO_PATH"

# Install Flutter if not available
if ! command -v flutter &> /dev/null; then
    echo "📦 Installing Flutter..."
    cd $HOME
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$HOME/flutter/bin:$PATH"
    echo "✅ Flutter installed"
else
    echo "✅ Flutter found in system"
fi

# Show Flutter version
echo "Flutter version:"
flutter --version

# Navigate to project root
cd "$REPO_PATH"

# Get Flutter dependencies
echo "📦 Running flutter pub get..."
flutter pub get || {
    echo "❌ flutter pub get failed"
    exit 1
}

# Install CocoaPods dependencies
echo "📦 Running pod install..."
cd ios
pod install || {
    echo "❌ pod install failed"
    exit 1
}

echo "✅ Setup complete!"
