#!/bin/sh

# Xcode Cloud Post-Clone Script for Flutter
# Simplified version that uses pre-generated Flutter files

set -ex  # Exit on error and print commands

echo "======================================"
echo "Xcode Cloud Post-Clone Setup"
echo "======================================"

# Navigate to iOS directory
cd "${CI_WORKSPACE}/ios" || cd "${CI_PRIMARY_REPOSITORY_PATH}/ios" || exit 1

echo "Current directory: $(pwd)"
echo "Contents:"
ls -la

# Simply install CocoaPods dependencies
echo "Installing CocoaPods dependencies..."
pod install

echo "✅ Setup complete!"
