#!/bin/sh

# Minimal Xcode Cloud Post-Clone Script
# Use this if the full script is failing

set -e

echo "Starting minimal setup..."

# Ensure we're in the right directory
if [ -z "$CI_PRIMARY_REPOSITORY_PATH" ]; then
    # Fallback: use CI_WORKSPACE or current directory
    REPO_PATH="${CI_WORKSPACE:-$(pwd)}"
else
    REPO_PATH="$CI_PRIMARY_REPOSITORY_PATH"
fi

echo "Working directory: $REPO_PATH"
cd "$REPO_PATH"

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "Installing Flutter..."
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
    export PATH="$HOME/flutter/bin:$PATH"
fi

echo "Flutter version:"
flutter --version

# Get Flutter packages
echo "Getting Flutter packages..."
flutter pub get

# Install pods
echo "Installing CocoaPods..."
cd ios
pod install

echo "Setup complete!"
