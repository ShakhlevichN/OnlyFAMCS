cmake_minimum_required(VERSION 3.20)
project(VideoChatRoulette VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Qt6 components
find_package(Qt6 REQUIRED COMPONENTS Core Widgets Multimedia Quick WebSockets)

# Include FetchContent for libdatachannel
include(FetchContent)

# Fetch libdatachannel
FetchContent_Declare(
    libdatachannel
    GIT_REPOSITORY https://github.com/paullouisageneau/libdatachannel.git
    GIT_TAG        v0.20.0
    GIT_SHALLOW    TRUE
)
FetchContent_MakeAvailable(libdatachannel)

# Enable Qt's MOC, UIC, and RCC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Source files
set(SOURCES
    src/main.cpp
    src/VideoChatApp.cpp
    src/AuthManager.cpp
    src/CameraHandler.cpp
    src/SignalingClient.cpp
    src/WebRTCManager.cpp
)

set(HEADERS
    src/AuthManager.h
    src/CameraHandler.h
    src/SignalingClient.h
    src/WebRTCManager.h
    src/VideoChatApp.h
)

# QML files
set(QML_FILES
    qml/SimpleApp.qml
)

# Create executable
qt6_add_executable(VideoChatRoulette ${SOURCES} ${HEADERS})

# Link Qt6 libraries
target_link_libraries(VideoChatRoulette PRIVATE
    Qt6::Core
    Qt6::Widgets
    Qt6::Multimedia
    Qt6::Quick
    Qt6::WebSockets
    Qt6::Network
    LibDataChannel::LibDataChannel
    pthread
)

# Add QML resource
qt6_add_resources(VideoChatRoulette "qml"
    PREFIX "/"
    FILES ${QML_FILES}
)

# Set include directories
target_include_directories(VideoChatRoulette PRIVATE src)
