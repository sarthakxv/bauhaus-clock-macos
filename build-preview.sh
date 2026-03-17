#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
SDK_PATH="$(xcrun --show-sdk-path)"

mkdir -p "$BUILD_DIR"

echo "→ Building Bauhaus Clock Preview..."

swiftc \
  -sdk "$SDK_PATH" \
  -target arm64-apple-macos13.0 \
  -o "$BUILD_DIR/BauhausPreview" \
  -framework AppKit \
  -framework CoreText \
  -O \
  "$PROJECT_DIR/BauhausClock/Palettes.swift" \
  "$PROJECT_DIR/BauhausClock/ClockRenderer.swift" \
  "$PROJECT_DIR/preview.swift"

echo "✓ Built: $BUILD_DIR/BauhausPreview"
echo ""
echo "  Usage:"
echo "    ./build/BauhausPreview                     # Noir, default"
echo "    ./build/BauhausPreview --dial Turquoise     # Pick a dial"
echo "    ./build/BauhausPreview --night              # Night mode"
echo "    ./build/BauhausPreview --night --lume Amber # Night + lume"
echo "    ./build/BauhausPreview --compact            # 360px size"
echo "    ./build/BauhausPreview --no-seconds         # Hide second hand"
