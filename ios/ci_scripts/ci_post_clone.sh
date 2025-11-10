#!/bin/sh

# Xcode Cloud Post-Clone Script for Flutter App
# This script runs after Xcode Cloud clones your repository

echo "======================================"
echo "Starting Xcode Cloud Post-Clone Setup"
echo "======================================"
echo "Workspace: $CI_WORKSPACE"
echo "Repository Path: $CI_PRIMARY_REPOSITORY_PATH"
echo "Branch: $CI_BRANCH"
echo ""

# Function to check command success
check_error() {
    if [ $? -ne 0 ]; then
        echo "❌ Error: $1 failed"
        exit 1
    fi
}

# Navigate to project root
cd "$CI_PRIMARY_REPOSITORY_PATH" || exit 1
echo "✅ Changed to repository directory"

# Install Flutter
echo ""
echo "📦 Installing Flutter SDK..."
FLUTTER_DIR="$HOME/flutter"

if [ -d "$FLUTTER_DIR" ]; then
    echo "Flutter directory already exists, removing..."
    rm -rf "$FLUTTER_DIR"
fi

# Clone Flutter with retry logic
MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "Cloning Flutter (attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)..."
    if git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_DIR"; then
        echo "✅ Flutter cloned successfully"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "⚠️  Clone failed, retrying in 5 seconds..."
            sleep 5
        else
            echo "❌ Failed to clone Flutter after $MAX_RETRIES attempts"
            exit 1
        fi
    fi
done

# Add Flutter to PATH
export PATH="$FLUTTER_DIR/bin:$PATH"
echo "✅ Flutter added to PATH"

# Verify Flutter installation
echo ""
echo "Flutter installation info:"
which flutter
flutter --version
check_error "Flutter version check"

# Disable analytics
flutter config --no-analytics
echo "✅ Flutter analytics disabled"

# Get Flutter dependencies
echo ""
echo "📦 Getting Flutter dependencies..."
flutter pub get
check_error "flutter pub get"
echo "✅ Flutter dependencies installed"

# Navigate to iOS directory
cd ios || exit 1
echo "✅ Changed to iOS directory"

# Update CocoaPods repo (optional, uncomment if needed)
# echo ""
# echo "📦 Updating CocoaPods repo..."
# pod repo update

# Install CocoaPods dependencies
echo ""
echo "📦 Installing CocoaPods dependencies..."
pod install
check_error "pod install"
echo "✅ CocoaPods dependencies installed"

# Verify Generated.xcconfig exists
if [ -f "Flutter/Generated.xcconfig" ]; then
    echo "✅ Generated.xcconfig file created"
else
    echo "⚠️  Warning: Generated.xcconfig not found"
fi

# List Pods directory to verify
if [ -d "Pods/Target Support Files/Pods-Runner" ]; then
    echo "✅ Pods target support files created"
else
    echo "⚠️  Warning: Pods target support files not found"
fi

echo ""
echo "======================================"
echo "✅ Xcode Cloud setup complete!"
echo "======================================"
