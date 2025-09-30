# Deployment Scripts

This directory contains scripts for building and deploying the Intellicart application to various platforms.

## Android

- `build_android.sh` - Build script for Unix-like systems (macOS, Linux)
- `build_android.bat` - Build script for Windows

These scripts will build both APK and App Bundle formats for Android.

## iOS

- `build_ios.sh` - Build script for iOS

This script builds the iOS application.

## Web

- `build_web.sh` - Build script for Web

This script builds the web version of the application.

## Desktop

- `build_desktop.sh` - Build script for all desktop platforms (Windows, macOS, Linux)

This script builds the application for all supported desktop platforms.

## Usage

Make sure to run these scripts from the root directory of the project:

```bash
# For Android (Unix-like systems)
./deployment/build_android.sh

# For Android (Windows)
deployment\build_android.bat

# For iOS
./deployment/build_ios.sh

# For Web
./deployment/build_web.sh

# For Desktop
./deployment/build_desktop.sh
```