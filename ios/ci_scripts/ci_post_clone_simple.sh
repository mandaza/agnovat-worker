#!/bin/sh

# Simplified Xcode Cloud Post-Clone Script
# Alternative version that uses Flutter installation from environment

echo "======================================"
echo "Xcode Cloud Setup (Simplified)"
echo "======================================"

# Set Flutter channel and version
FLUTTER_VERSION="3.24.3"  # Update this to match your pubspec.yaml

# Try to use system Flutter first
if command -v flutter &> /dev/null; then
    echo "✅ Flutter found in system"
    flutter --version
else
    echo "📦 Installing Flutter..."

    # Use fvm (Flutter Version Manager) if available, or install Flutter directly
    cd $HOME
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$HOME/flutter/bin:$PATH"

    flutter --version
fi

# Navigate to project
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Install dependencies
echo "📦 Running flutter pub get..."
flutter pub get || {
    echo "❌ flutter pub get failed"
    exit 1
}

# Install CocoaPods
cd ios
echo "📦 Running pod install..."
pod install || {
    echo "❌ pod install failed"
    exit 1
}

echo "✅ Setup complete!"
