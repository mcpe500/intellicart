#!/bin/bash
# build_ios.sh - Build script for iOS

echo "Building iOS..."
flutter build ios --release

echo "iOS build completed!"
echo "IPA location: build/ios/iphoneos/Runner.app"