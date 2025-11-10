#!/bin/sh

# Xcode Cloud Post-Clone Script for Flutter App
# This script runs after Xcode Cloud clones your repository

set -e # Exit on any error

echo "======================================"
echo "Starting Xcode Cloud Post-Clone Setup"
echo "======================================"

# Navigate to project root
cd $CI_PRIMARY_REPOSITORY_PATH

# Install Flutter
echo "📦 Installing Flutter..."

# Download Flutter SDK
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$HOME/flutter/bin:$PATH"

# Verify Flutter installation
echo "Flutter version:"
flutter --version

# Configure Flutter
flutter config --no-analytics

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Navigate to iOS directory
cd ios

# Install CocoaPods dependencies
echo "📦 Installing CocoaPods dependencies..."
pod install

echo "✅ Xcode Cloud setup complete!"
echo "======================================"
