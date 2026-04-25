# 🎥 Video Chat Roulette

A modern Qt 6-based video chat roulette application with real-time P2P communication using WebRTC and Node.js signaling server.

## ✨ Features

- **🎥 P2P Video Chat**: Direct WebRTC connection between users
- **🎲 Roulette Matching**: Random partner matching via signaling server  
- **🎨 Modern UI**: Dark theme with Material Design using Qt Quick (QML)
- **🌍 Global**: Works across different countries and platforms
- **🔐 Secure**: JWT-based authentication
- **💬 Text Chat**: Built-in text messaging alongside video
- **📱 Cross-platform**: Works on Windows, macOS, and Linux

## 🏗️ Architecture

### Client (Qt 6)
```
├── 📹 CameraHandler     - Video capture using QMediaCaptureSession
├── 📡 SignalingClient   - WebSocket communication with server
├── 🔗 WebRTCManager     - WebRTC peer connection (libdatachannel)
├── 🎮 VideoChatApp      - Main application logic and state
├── 🔐 AuthManager       - JWT authentication
└── 🎨 QML UI           - Modern Material Design interface
```

### Signaling Server (Node.js/FastAPI)
```
├── 🌐 WebSocket Server  - Real-time communication
├── 🎯 Matchmaking      - Random partner pairing
├── 📡 Signaling         - SDP/ICE candidate relay
├── 🔐 Authentication    - JWT token validation
└── 🗄️ Database         - User management (SQLite)
```

## 📋 Requirements

### Client
- **Qt 6.6+** with modules:
  - Qt6Core
  - Qt6Widgets  
  - Qt6Multimedia
  - Qt6Quick
  - Qt6WebSockets
- **CMake 3.20+**
- **C++17** compatible compiler
- **libdatachannel** (automatically fetched)

### Server
- **Node.js 14+**
- **Python 3.8+** (FastAPI backend)
- **npm** or **yarn**

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/video-chat-roulette.git
cd video-chat-roulette
```

### 2. Start Signaling Server
```bash
# Navigate to server directory
cd server

# Install dependencies
npm install

# Start server
npm start
```

### 3. Build and Run Client
```bash
# Navigate to project root
cd ..

# Build client
./build.sh

# Run application
./VideoChatRoulette
```

## 📖 Usage

1. **Start the signaling server** first
2. **Register** a new account or **login** with existing credentials
3. **Choose** between Video Chat or Text Chat
4. **Wait** for partner matching
5. **Start** chatting!

## 🌐 How It Works

### Connection Flow
```
User A ←→ WebSocket Server ←→ User B
   ↓              ↓              ↓
WebRTC ←→ Signaling ←→ WebRTC
   ↓              ↓              ↓
Direct P2P Connection Established
```

### Global Reach
- **No distance limitations** - works worldwide
- **Low latency** - direct P2P connection
- **High quality** - WebRTC video/audio streaming
- **Secure** - end-to-end encryption

## 🛠️ Development

### Project Structure
```
video-chat-roulette/
├── src/                    # C++ source files
│   ├── AuthManager.cpp     # Authentication logic
│   ├── CameraHandler.cpp   # Video capture
│   ├── SignalingClient.cpp # WebSocket client
│   ├── VideoChatApp.cpp    # Main application
│   └── WebRTCManager.cpp   # WebRTC wrapper
├── qml/                    # QML UI files
│   └── SimpleApp.qml       # Main interface
├── server/                 # Signaling server
│   ├── main.py            # FastAPI server
│   ├── models.py          # Data models
│   ├── auth.py            # Authentication
│   └── database.py        # Database operations
├── CMakeLists.txt          # Build configuration
└── README.md              # This file
```

### Build from Source
```bash
# Create build directory
mkdir build && cd build

# Configure with CMake
cmake ..

# Build
make -j$(nproc)

# Run
./VideoChatRoulette
```

## 🔧 Configuration

### Server Configuration
- **Port**: 8080 (default)
- **WebSocket**: `/ws` endpoint
- **Database**: SQLite (auto-created)

### Client Configuration  
- **Server URL**: `ws://localhost:8080/ws`
- **Theme**: Dark Material Design
- **Window Size**: 800x600

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Qt** for cross-platform framework
- **libdatachannel** for WebRTC implementation
- **FastAPI** for high-performance server
- **Material Design** for UI guidelines

## 📞 Support

If you have any questions or issues, please:
- Open an [Issue](https://github.com/yourusername/video-chat-roulette/issues)
- Check the [Wiki](https://github.com/yourusername/video-chat-roulette/wiki)
- Join our [Discussions](https://github.com/yourusername/video-chat-roulette/discussions)

---

**🎉 Made with ❤️ for global communication!**

## Features

- **P2P Video Chat**: Direct WebRTC connection between users
- **Roulette Matching**: Random partner matching via signaling server
- **Modern UI**: Dark theme with Qt Quick (QML)
- **Cross-platform**: Works on Windows, macOS, and Linux

## Architecture

### Client (Qt 6)
- **CameraHandler**: Manages video capture using QMediaCaptureSession
- **SignalingClient**: WebSocket communication with signaling server
- **WebRTCManager**: WebRTC peer connection wrapper using libdatachannel
- **VideoChatApp**: Main application logic and state management

### Signaling Server (Node.js)
- WebSocket-based signaling server
- Random partner matching
- SDP and ICE candidate relay
- Connection management

## Requirements

### Client
- Qt 6.6+ with modules:
  - Core
  - Widgets
  - Multimedia
  - Quick
  - WebSockets
- CMake 3.20+
- C++17 compatible compiler
- libdatachannel (automatically fetched by CMake)

### Server
- Node.js 14+
- npm

## Build Instructions

### 1. Clone and Build Client

```bash
# Navigate to project directory
cd VideoChatRoulette

# Create build directory
mkdir build
cd build

# Configure with CMake
cmake ..

# Build
make -j$(nproc)  # Linux/macOS
# or
cmake --build .  # Cross-platform
```

### 2. Setup and Start Signaling Server

```bash
# Navigate to server directory
cd server

# Install dependencies
npm install

# Start server
npm start
```

The server will start on `ws://localhost:8080` by default.

## Usage

1. **Start the signaling server** first:
   ```bash
   cd server && npm start
   ```

2. **Run the client application**:
   ```bash
   ./build/VideoChatRoulette
   ```

3. **Use the application**:
   - Click "Connect" to connect to the signaling server
   - Click "Start Chat" to search for a partner
   - Once connected, you'll see your partner's video
   - Click "Next" to find a new partner
   - Click "Stop" to end the current chat

## Configuration

### Server URL
The client connects to `ws://localhost:8080` by default. You can change this in the UI or modify the source code.

### STUN Server
The application uses Google's STUN server (`stun:stun.l.google.com:19302`) for NAT traversal. You can modify this in `WebRTCManager.cpp`.

## Signaling Protocol

### Client Messages

#### Search for Partner
```json
{
  "type": "search",
  "id": "client-id"
}
```

#### WebRTC Offer
```json
{
  "type": "offer",
  "to": "partner-id",
  "from": "my-id",
  "sdp": "offer-sdp"
}
```

#### WebRTC Answer
```json
{
  "type": "answer",
  "to": "partner-id",
  "from": "my-id",
  "sdp": "answer-sdp"
}
```

#### ICE Candidate
```json
{
  "type": "ice-candidate",
  "to": "partner-id",
  "from": "my-id",
  "candidate": "candidate-string",
  "sdpMid": "0",
  "sdpMLineIndex": 0
}
```

#### Next Partner
```json
{
  "type": "next",
  "id": "my-id",
  "partnerId": "current-partner-id"
}
```

### Server Messages

#### Client ID Assignment
```json
{
  "type": "id",
  "id": "generated-client-id"
}
```

#### Partner Found
```json
{
  "type": "partner-found",
  "partnerId": "partner-client-id"
}
```

#### Partner Disconnected
```json
{
  "type": "partner-disconnected"
}
```

## Troubleshooting

### Camera Not Working
- Ensure camera permissions are granted
- Check if camera is not being used by another application
- Verify Qt Multimedia backend is properly installed

### Connection Issues
- Ensure the signaling server is running
- Check firewall settings for WebSocket connections
- Verify STUN server accessibility

### Build Issues
- Ensure Qt 6.6+ is installed with all required modules
- Check CMake version (3.20+ required)
- Ensure C++17 compiler is available

## Development

### Project Structure
```
VideoChatRoulette/
├── src/                    # C++ source files
│   ├── CameraHandler.cpp/h
│   ├── SignalingClient.cpp/h
│   ├── WebRTCManager.cpp/h
│   ├── VideoChatApp.cpp/h
│   └── main.cpp
├── qml/                    # QML UI files
│   ├── main.qml
│   └── VideoChatWindow.qml
├── server/                 # Node.js signaling server
│   ├── package.json
│   └── server.js
├── CMakeLists.txt         # CMake configuration
└── README.md
```

### Adding Features
- Camera settings (resolution, framerate)
- Audio support
- Chat messaging
- User profiles
- Server statistics

## License

MIT License - see LICENSE file for details.
