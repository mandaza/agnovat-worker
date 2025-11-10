#!/bin/bash

# Development Build Script for Agnovat
# Uses test/development Clerk environment

echo "🔨 Building Agnovat (Development Environment)..."
echo ""

# Development Clerk credentials (test environment)
CLERK_KEY="pk_test_dmVyaWZpZWQtc3RpbmdyYXktODEuY2xlcmsuYWNjb3VudHMuZGV2JA"
CLERK_API="https://verified-stingray-81.accounts.dev"

# Claude API key (load from environment or use placeholder)
CLAUDE_KEY="${CLAUDE_API_KEY:-YOUR_CLAUDE_API_KEY}"

echo "Environment: DEVELOPMENT"
echo "Clerk: Test Environment"
echo "Claude API: ${CLAUDE_KEY:0:20}..."
echo ""

# Build for iOS
echo "Building iOS (Debug)..."
flutter build ios --debug \
  --dart-define=CLERK_PUBLISHABLE_KEY="$CLERK_KEY" \
  --dart-define=CLERK_FRONTEND_API="$CLERK_API" \
  --dart-define=CLAUDE_API_KEY="$CLAUDE_KEY"

echo ""
echo "✅ Development build complete!"
echo ""
echo "To run on simulator:"
echo "  flutter run --dart-define=CLERK_PUBLISHABLE_KEY=$CLERK_KEY \\"
echo "             --dart-define=CLERK_FRONTEND_API=$CLERK_API \\"
echo "             --dart-define=CLAUDE_API_KEY=$CLAUDE_KEY"
