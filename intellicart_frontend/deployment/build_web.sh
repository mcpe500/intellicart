#!/bin/bash
# build_web.sh - Build script for Web

echo "Building Web..."
flutter build web --release

echo "Web build completed!"
echo "Output location: build/web"