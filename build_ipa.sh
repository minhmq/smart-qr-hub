#!/bin/bash
# Build script for Smart QR Hub iOS IPA

set -e

echo "🚀 Building Smart QR Hub for iOS TestFlight..."

# Step 1: Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Step 2: Generate Hive adapters
echo "🔧 Generating Hive adapters..."
flutter pub run build_runner build --delete-conflicting-outputs

# Step 3: Analyze code
echo "🔍 Running code analysis..."
flutter analyze

# Step 4: Clean build
echo "🧹 Cleaning previous builds..."
flutter clean

# Step 5: Build IPA
echo "📱 Building IPA for release..."
flutter build ipa --release

echo "✅ Build complete!"
echo "📦 IPA location: build/ios/ipa/smart_qr_hub.ipa"
echo ""
echo "Next steps:"
echo "1. Open Transporter app (macOS)"
echo "2. Drag and drop the IPA file"
echo "3. Sign in with Apple Developer account"
echo "4. Click 'Deliver' to upload to App Store Connect"

