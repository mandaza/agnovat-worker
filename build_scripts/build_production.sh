#!/bin/bash

# Production Build Script for Agnovat
# Requires production Clerk credentials and proper keystore configuration

echo "🚀 Building Agnovat (PRODUCTION)..."
echo ""

# Check for required environment variables
if [ -z "$CLERK_PUBLISHABLE_KEY_PROD" ]; then
    echo "❌ Error: CLERK_PUBLISHABLE_KEY_PROD environment variable not set"
    echo "   Set it with: export CLERK_PUBLISHABLE_KEY_PROD=pk_live_xxx"
    exit 1
fi

if [ -z "$CLERK_FRONTEND_API_PROD" ]; then
    echo "❌ Error: CLERK_FRONTEND_API_PROD environment variable not set"
    echo "   Set it with: export CLERK_FRONTEND_API_PROD=https://your-production.clerk.accounts.dev"
    exit 1
fi


# Check Android keystore exists
if [ ! -f "android/key.properties" ]; then
    echo "❌ Error: android/key.properties not found"
    echo "   Run setup from KEYSTORE_SETUP.md first"
    exit 1
fi

echo "Environment: PRODUCTION"
echo "Clerk: ${CLERK_FRONTEND_API_PROD}"
echo ""

# Prompt for confirmation
read -p "⚠️  Building PRODUCTION release. Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Build cancelled."
    exit 1
fi

# iOS Release Build
echo ""
echo "📱 Building iOS Release..."
flutter build ios --release \
  --obfuscate \
  --split-debug-info=./debug-info/ios \
  --dart-define=CLERK_PUBLISHABLE_KEY="$CLERK_PUBLISHABLE_KEY_PROD" \
  --dart-define=CLERK_FRONTEND_API="$CLERK_FRONTEND_API_PROD"

if [ $? -eq 0 ]; then
    echo "✅ iOS build successful"
else
    echo "❌ iOS build failed"
    exit 1
fi

# Android Release Build (App Bundle)
echo ""
echo "🤖 Building Android Release (App Bundle)..."
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=./debug-info/android \
  --dart-define=CLERK_PUBLISHABLE_KEY="$CLERK_PUBLISHABLE_KEY_PROD" \
  --dart-define=CLERK_FRONTEND_API="$CLERK_FRONTEND_API_PROD"

if [ $? -eq 0 ]; then
    echo "✅ Android build successful"
    echo ""
    echo "📦 App Bundle location:"
    echo "   build/app/outputs/bundle/release/app-release.aab"
else
    echo "❌ Android build failed"
    exit 1
fi

echo ""
echo "🎉 PRODUCTION BUILD COMPLETE!"
echo ""
echo "Next steps:"
echo "1. iOS: Open ios/Runner.xcworkspace in Xcode"
echo "        Product > Archive > Upload to App Store Connect"
echo ""
echo "2. Android: Upload app-release.aab to Google Play Console"
echo "           build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "⚠️  IMPORTANT:"
echo "   - Test builds on physical devices before submission"
echo "   - Update version in pubspec.yaml for each release"
echo "   - Save debug symbols: debug-info/ios and debug-info/android"
echo "   - Verify privacy policy and terms URLs are live"
