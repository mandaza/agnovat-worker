#!/bin/sh

echo "🔨 Xcode Cloud: Installing CocoaPods dependencies..."

# Navigate to iOS directory
cd "$CI_WORKSPACE/ios"

# Run pod install
pod install

echo "✅ CocoaPods installation complete!"
