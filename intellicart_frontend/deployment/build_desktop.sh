#!/bin/bash
# build_desktop.sh - Build script for Desktop platforms

echo "Building Windows..."
flutter build windows --release

echo "Building macOS..."
flutter build macos --release

echo "Building Linux..."
flutter build linux --release

echo "Desktop builds completed!"
echo "Windows location: build\\windows\\x64\\runner\\Release"
echo "macOS location: build/macos/Build/Products/Release"
echo "Linux location: build/linux/x64/release/bundle"