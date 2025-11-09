# Security Setup Guide

## ⚠️ Important: Handling API Keys Securely

**NEVER commit API keys or secrets to Git!**

## What Happened?

An Anthropic API key was accidentally committed to Git history. This has been:
- ✅ Removed from Git history
- ✅ Pushed to GitHub with cleaned history

## Actions Required

### 1. Revoke the Exposed API Key ⚠️
**IMMEDIATELY go to https://console.anthropic.com and:**
- Delete/revoke the old API key: `sk-ant-api03-z0YUD...` (if you haven't already)
- This key was exposed in Git history and must be considered compromised

### 2. Generate a New API Key
1. Go to https://console.anthropic.com
2. Create a new API key
3. Copy it securely (you'll only see it once!)

### 3. Configure the API Key Properly

#### Option A: Using Environment Variables (Recommended for Development)

Run Flutter with the API key as an environment variable:

```bash
flutter run --dart-define=CLAUDE_API_KEY=your_new_api_key_here
```

For iOS builds:
```bash
flutter build ios --dart-define=CLAUDE_API_KEY=your_new_api_key_here
```

For Android builds:
```bash
flutter build apk --dart-define=CLAUDE_API_KEY=your_new_api_key_here
```

#### Option B: Using flutter_dotenv Package (Alternative)

1. Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

2. Create a `.env` file (already gitignored):
```
CLAUDE_API_KEY=your_new_api_key_here
```

3. Update the code to load from .env file

#### Option C: Using Flutter Secure Storage (Best for Production)

Store sensitive data encrypted on the device:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
await storage.write(key: 'claude_api_key', value: 'your_key');
final apiKey = await storage.read(key: 'claude_api_key');
```

## Current Implementation

The code currently uses `String.fromEnvironment()`:

```dart
const apiKey = String.fromEnvironment(
  'CLAUDE_API_KEY',
  defaultValue: 'YOUR_CLAUDE_API_KEY',
);
```

This means you **must** pass the API key when running Flutter:
```bash
flutter run --dart-define=CLAUDE_API_KEY=your_actual_key
```

## Best Practices

1. ✅ Always use environment variables or secure storage
2. ✅ Never hardcode API keys in source code
3. ✅ Keep `.env` files in `.gitignore`
4. ✅ Use different API keys for development and production
5. ✅ Rotate API keys regularly
6. ✅ Monitor your API usage for suspicious activity

## Files Protected

The following patterns are now in `.gitignore`:
- `.env`
- `.env.*`
- `*.key`
- `**/secrets/`

## Need Help?

- Anthropic Console: https://console.anthropic.com
- Flutter Environment Variables: https://docs.flutter.dev/deployment/flavors

