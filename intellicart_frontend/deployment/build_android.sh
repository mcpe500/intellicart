#!/bin/bash
# build_android.sh - Build script for Android

echo "Building Android APK..."
flutter build apk --release

echo "Building Android App Bundle..."
flutter build appbundle

echo "Android builds completed!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
echo "App Bundle location: build/app/outputs/bundle/release/app-release.aab"