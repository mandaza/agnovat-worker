#!/bin/bash

echo "🔍 Testing Deep Link Configuration..."
echo ""

# Check if ADB is available (Android)
if command -v adb &> /dev/null; then
    echo "📱 Testing Android Deep Link..."
    echo "Command: adb shell am start -a android.intent.action.VIEW -d 'agnovat://oauth?test=true&status=success'"
    adb shell am start -a android.intent.action.VIEW -d "agnovat://oauth?test=true&status=success"
    echo ""
    echo "✅ Deep link sent to Android device/emulator"
    echo "👀 Check your Flutter logs for 'Deep link received' message"
else
    echo "⚠️  ADB not found - skipping Android test"
fi

echo ""
echo "📋 What to look for in Flutter logs:"
echo "   - 'Deep link received: agnovat://oauth?test=true&status=success'"
echo "   - 'Callback params: test, status'"
echo ""
echo "If you see these logs, deep links work! ✅"
echo "If not, we need to fix the configuration. ❌"

