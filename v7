#!/bin/bash

# V7 macOS Development Environment Installer
# This script installs JDK, Node.js, Android SDK Command-line Tools, and Appium

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_color() { printf "${!1}%s${NC}\n" "$2"; }

check_version() {
    if command -v $1 &> /dev/null; then
        local version=$($1 --version 2>&1 | head -n 1)
        print_color "YELLOW" "$1 is already installed: $version"
        return 0
    fi
    return 1
}

download_file() {
    if [ ! -f "$2" ] || [ ! -s "$2" ]; then
        print_color "YELLOW" "Downloading $1..."
        curl -L "$1" -o "$2"
    else
        print_color "GREEN" "$2 already exists and is not empty. Skipping download."
    fi
}

add_to_path() {
    if ! grep -q "$1" ~/.zshrc; then
        echo "export PATH=\"$1:\$PATH\"" >> ~/.zshrc
        print_color "GREEN" "Added $1 to PATH in ~/.zshrc"
    else
        print_color "YELLOW" "$1 is already in PATH"
    fi
}

set_env_var() {
    if ! grep -q "export $1=" ~/.zshrc; then
        echo "export $1=$2" >> ~/.zshrc
        print_color "GREEN" "Added $1 environment variable to ~/.zshrc"
    else
        sed -i '' "s|export $1=.*|export $1=$2|" ~/.zshrc
        print_color "YELLOW" "Updated $1 environment variable in ~/.zshrc"
    fi
}

install_jdk() {
    if check_version java; then
        return 0
    fi
    
    JDK_VERSION="11.0.2"
    JDK_URL="https://download.java.net/java/GA/jdk11/${JDK_VERSION}/9/GPL/openjdk-${JDK_VERSION}_osx-x64_bin.tar.gz"
    JDK_TAR="openjdk-${JDK_VERSION}_osx-x64_bin.tar.gz"
    
    download_file "$JDK_URL" "$JDK_TAR"
    
    print_color "YELLOW" "Extracting JDK..."
    if ! tar -xzf "$JDK_TAR"; then
        print_color "RED" "Failed to extract JDK. The downloaded file may be corrupted."
        rm "$JDK_TAR"
        return 1
    fi
    sudo mv jdk-${JDK_VERSION}.jdk /Library/Java/JavaVirtualMachines/
    rm "$JDK_TAR"
    
    JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-${JDK_VERSION}.jdk/Contents/Home"
    add_to_path "$JAVA_HOME/bin"
    set_env_var "JAVA_HOME" "$JAVA_HOME"
    
    print_color "GREEN" "JDK 11 installed successfully"
    source ~/.zshrc
    java -version
}

install_nodejs() {
    if check_version node; then
        return 0
    fi
    
    NODE_VERSION="14.17.0"
    NODE_URL="https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-darwin-x64.tar.gz"
    NODE_TAR="node-v${NODE_VERSION}-darwin-x64.tar.gz"
    
    download_file "$NODE_URL" "$NODE_TAR"
    
    print_color "YELLOW" "Extracting Node.js..."
    if ! tar -xzf "$NODE_TAR"; then
        print_color "RED" "Failed to extract Node.js. The downloaded file may be corrupted."
        rm "$NODE_TAR"
        return 1
    fi
    sudo mv node-v${NODE_VERSION}-darwin-x64 /usr/local/lib/nodejs
    rm "$NODE_TAR"
    
    NODE_PATH="/usr/local/lib/nodejs/bin"
    add_to_path "$NODE_PATH"
    set_env_var "NODE_HOME" "/usr/local/lib/nodejs"
    
    print_color "GREEN" "Node.js installed successfully"
    source ~/.zshrc
    node --version
}

install_android_sdk() {
    if [ -d "$HOME/Library/Android/sdk" ]; then
        print_color "YELLOW" "Android SDK is already installed."
        return 0
    fi
    
    SDK_VERSION="8512546"
    SDK_URL="https://dl.google.com/android/repository/commandlinetools-mac-${SDK_VERSION}_latest.zip"
    SDK_ZIP="commandlinetools-mac-${SDK_VERSION}_latest.zip"
    
    download_file "$SDK_URL" "$SDK_ZIP"
    
    print_color "YELLOW" "Extracting Android SDK Command-line Tools..."
    mkdir -p "$HOME/Library/Android/sdk/cmdline-tools"
    if ! unzip -q "$SDK_ZIP" -d "$HOME/Library/Android/sdk/cmdline-tools"; then
        print_color "RED" "Failed to extract Android SDK. The downloaded file may be corrupted."
        rm "$SDK_ZIP"
        return 1
    fi
    mv "$HOME/Library/Android/sdk/cmdline-tools/cmdline-tools" "$HOME/Library/Android/sdk/cmdline-tools/latest"
    rm "$SDK_ZIP"
    
    ANDROID_HOME="$HOME/Library/Android/sdk"
    ANDROID_SDK_ROOT="$ANDROID_HOME"
    
    set_env_var "ANDROID_HOME" "$ANDROID_HOME"
    set_env_var "ANDROID_SDK_ROOT" "$ANDROID_SDK_ROOT"
    add_to_path "$ANDROID_HOME/cmdline-tools/latest/bin"
    add_to_path "$ANDROID_HOME/platform-tools"
    
    print_color "YELLOW" "Installing Android SDK packages..."
    source ~/.zshrc
    yes | sdkmanager --licenses > /dev/null 2>&1
    sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"
    
    print_color "GREEN" "Android SDK Command-line Tools installed successfully"
}

install_appium() {
    if check_version appium; then
        return 0
    fi
    
    if ! command -v npm &> /dev/null; then
        print_color "RED" "npm is not installed. Please install Node.js first."
        return 1
    fi
    
    print_color "YELLOW" "Installing Appium..."
    if ! npm install -g appium; then
        print_color "RED" "Failed to install Appium. There might be an issue with npm."
        return 1
    fi
    
    APPIUM_PATH=$(which appium)
    add_to_path "$(dirname "$APPIUM_PATH")"
    
    print_color "GREEN" "Appium installed successfully"
    source ~/.zshrc
    appium --version
}

main() {
    print_color "GREEN" "Starting V7 macOS Development Environment Installation"
    
    install_jdk
    install_nodejs
    install_android_sdk
    install_appium
    
    print_color "GREEN" "Installation complete. Please restart your terminal or run 'source ~/.zshrc' to apply all changes."
    print_color "YELLOW" "Installation paths:"
    echo "JDK: $JAVA_HOME"
    echo "Node.js: $NODE_HOME"
    echo "Android SDK: $ANDROID_HOME"
    echo "Appium: $APPIUM_PATH"
    
    print_color "BLUE" "To verify the installation, you can run the following commands:"
    echo "java -version"
    echo "node -v"
    echo "npm -v"
    echo "adb version"
    echo "appium -v"
}

main
