#!/bin/bash

# Enhanced macOS Development Environment Installer
# This script installs JDK, Node.js, Android SDK Command-line Tools, and Appium without using Homebrew

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${!1}%s${NC}\n" "$2"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt user for installation
prompt_install() {
    while true; do
        read -p "Do you want to install $1? (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to download file if not exists
download_file() {
    if [ ! -f "$2" ]; then
        print_color "YELLOW" "Downloading $1..."
        curl -L "$1" -o "$2"
    else
        print_color "GREEN" "$2 already exists. Skipping download."
    fi
}

# Function to add to PATH
add_to_path() {
    if ! grep -q "$1" ~/.zshrc; then
        echo "export PATH=\"$1:\$PATH\"" >> ~/.zshrc
        print_color "GREEN" "Added $1 to PATH in ~/.zshrc"
    else
        print_color "YELLOW" "$1 is already in PATH"
    fi
}

# Function to set environment variable
set_env_var() {
    if ! grep -q "export $1=" ~/.zshrc; then
        echo "export $1=$2" >> ~/.zshrc
        print_color "GREEN" "Added $1 environment variable to ~/.zshrc"
    else
        print_color "YELLOW" "$1 environment variable is already set"
    fi
}

# Install JDK
install_jdk() {
    if prompt_install "JDK 11"; then
        JDK_VERSION="11.0.2"
        JDK_URL="https://download.java.net/java/GA/jdk11/${JDK_VERSION}/9/GPL/openjdk-${JDK_VERSION}_osx-x64_bin.tar.gz"
        JDK_TAR="openjdk-${JDK_VERSION}_osx-x64_bin.tar.gz"
        
        download_file "$JDK_URL" "$JDK_TAR"
        
        print_color "YELLOW" "Extracting JDK..."
        tar -xzf "$JDK_TAR"
        sudo mv jdk-${JDK_VERSION}.jdk /Library/Java/JavaVirtualMachines/
        rm "$JDK_TAR"
        
        JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-${JDK_VERSION}.jdk/Contents/Home"
        add_to_path "$JAVA_HOME/bin"
        set_env_var "JAVA_HOME" "$JAVA_HOME"
        
        print_color "GREEN" "JDK 11 installed successfully"
    fi
}

# Install Node.js
install_nodejs() {
    if prompt_install "Node.js"; then
        NODE_VERSION="14.17.0"
        NODE_URL="https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-darwin-x64.tar.gz"
        NODE_TAR="node-v${NODE_VERSION}-darwin-x64.tar.gz"
        
        download_file "$NODE_URL" "$NODE_TAR"
        
        print_color "YELLOW" "Extracting Node.js..."
        tar -xzf "$NODE_TAR"
        sudo mv node-v${NODE_VERSION}-darwin-x64 /usr/local/lib/nodejs
        rm "$NODE_TAR"
        
        NODE_PATH="/usr/local/lib/nodejs/bin"
        add_to_path "$NODE_PATH"
        set_env_var "NODE_HOME" "/usr/local/lib/nodejs"
        
        print_color "GREEN" "Node.js installed successfully"
    fi
}

# Install Android SDK Command-line Tools
install_android_sdk() {
    if prompt_install "Android SDK Command-line Tools"; then
        SDK_VERSION="8512546"
        SDK_URL="https://dl.google.com/android/repository/commandlinetools-mac-${SDK_VERSION}_latest.zip"
        SDK_ZIP="commandlinetools-mac-${SDK_VERSION}_latest.zip"
        
        download_file "$SDK_URL" "$SDK_ZIP"
        
        print_color "YELLOW" "Extracting Android SDK Command-line Tools..."
        unzip -q "$SDK_ZIP" -d ~/Library/Android/sdk
        rm "$SDK_ZIP"
        
        ANDROID_HOME="$HOME/Library/Android/sdk"
        ANDROID_SDK_ROOT="$ANDROID_HOME"
        
        set_env_var "ANDROID_HOME" "$ANDROID_HOME"
        set_env_var "ANDROID_SDK_ROOT" "$ANDROID_SDK_ROOT"
        add_to_path "$ANDROID_HOME/cmdline-tools/latest/bin"
        add_to_path "$ANDROID_HOME/platform-tools"
        
        print_color "YELLOW" "Installing Android SDK packages..."
        yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses > /dev/null 2>&1
        $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"
        
        print_color "GREEN" "Android SDK Command-line Tools installed successfully"
    fi
}

# Install Appium
install_appium() {
    if prompt_install "Appium"; then
        if ! command_exists npm; then
            print_color "RED" "npm is not installed. Please install Node.js first."
            return 1
        fi
        
        print_color "YELLOW" "Installing Appium..."
        npm install -g appium
        npm install -g appium-doctor
        
        APPIUM_PATH=$(which appium)
        add_to_path "$(dirname "$APPIUM_PATH")"
        
        print_color "GREEN" "Appium installed successfully"
        print_color "YELLOW" "Running appium-doctor to check the setup..."
        appium-doctor
    fi
}

# Install additional tools
install_additional_tools() {
    if prompt_install "Additional tools (wget, tree)"; then
        print_color "YELLOW" "Installing wget..."
        curl -O https://ftp.gnu.org/gnu/wget/wget-1.21.1.tar.gz
        tar -xzf wget-1.21.1.tar.gz
        cd wget-1.21.1
        ./configure --with-ssl=openssl
        make
        sudo make install
        cd ..
        rm -rf wget-1.21.1 wget-1.21.1.tar.gz
        
        print_color "YELLOW" "Installing tree..."
        curl -O https://mama.indstate.edu/users/ice/tree/src/tree-1.8.0.tgz
        tar -xzf tree-1.8.0.tgz
        cd tree-1.8.0
        make
        sudo make install
        cd ..
        rm -rf tree-1.8.0 tree-1.8.0.tgz
        
        print_color "GREEN" "Additional tools installed successfully"
    fi
}

# Check system requirements
check_system_requirements() {
    print_color "BLUE" "Checking system requirements..."
    
    # Check macOS version
    OS_VERSION=$(sw_vers -productVersion)
    if [[ "${OS_VERSION}" < "10.15" ]]; then
        print_color "RED" "This script requires macOS Catalina (10.15) or later. Your version: ${OS_VERSION}"
        exit 1
    fi
    
    # Check available disk space
    AVAILABLE_SPACE=$(df -h / | awk 'NR==2 {print $4}' | sed 's/Gi//')
    if (( $(echo "${AVAILABLE_SPACE} < 10" | bc -l) )); then
        print_color "RED" "You need at least 10GB of free disk space. Available: ${AVAILABLE_SPACE}GB"
        exit 1
    fi
    
    # Check if Xcode Command Line Tools are installed
    if ! xcode-select -p &> /dev/null; then
        print_color "YELLOW" "Xcode Command Line Tools not found. Installing..."
        xcode-select --install
        read -p "Press enter after Xcode Command Line Tools installation is complete"
    fi
    
    print_color "GREEN" "System requirements met"
}

# Main installation process
main() {
    print_color "GREEN" "Starting Enhanced macOS Development Environment Installation"
    
    check_system_requirements
    install_jdk
    install_nodejs
    install_android_sdk
    install_appium
    install_additional_tools
    
    print_color "GREEN" "Installation complete. Please restart your terminal or run 'source ~/.zshrc' to apply changes."
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
    echo "wget --version"
    echo "tree --version"
}

main
