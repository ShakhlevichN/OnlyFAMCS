#!/bin/bash

# Video Chat Roulette Build Script

set -e

echo "🎥 Building Video Chat Roulette..."

# Check if Qt 6 is available
if ! command -v qmake6 &> /dev/null && ! command -v qmake &> /dev/null; then
    echo "❌ Qt 6 not found. Please install Qt 6.6+ with required modules."
    exit 1
fi

# Check if CMake is available
if ! command -v cmake &> /dev/null; then
    echo "❌ CMake not found. Please install CMake 3.20+."
    exit 1
fi

# Create build directory
echo "📁 Creating build directory..."
mkdir -p build
cd build

# Configure with CMake
echo "⚙️  Configuring with CMake..."
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build
echo "🔨 Building..."
make -j$(nproc) 2>/dev/null || cmake --build . --config Release

echo "✅ Build completed successfully!"
echo ""
echo "🚀 To run the application:"
echo "   ./VideoChatRoulette"
echo ""
echo "🌐 Don't forget to start the signaling server first:"
echo "   cd ../server && npm install && npm start"
