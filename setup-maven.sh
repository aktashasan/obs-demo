#!/bin/bash

# Maven Setup Script for macOS
# This script helps you configure Maven on your system

echo "====================================="
echo "Maven Configuration Helper"
echo "====================================="
echo ""

# Check if Maven is already installed
if command -v mvn &> /dev/null; then
    echo "✅ Maven is already installed!"
    mvn --version
    exit 0
fi

echo "Maven is not found. Let's install it."
echo ""

# Check if Homebrew is installed
if command -v brew &> /dev/null; then
    echo "✅ Homebrew detected. Installing Maven via Homebrew..."
    echo ""
    brew install maven
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Maven installed successfully!"
        mvn --version
        exit 0
    else
        echo "❌ Failed to install Maven via Homebrew"
        exit 1
    fi
else
    echo "❌ Homebrew not found."
    echo ""
    echo "Please choose an installation method:"
    echo ""
    echo "Option 1: Install Homebrew first, then Maven"
    echo "  Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "  Then: brew install maven"
    echo ""
    echo "Option 2: Manual installation"
    echo "  1. Download Maven from: https://maven.apache.org/download.cgi"
    echo "  2. Extract: tar -xzf apache-maven-*-bin.tar.gz"
    echo "  3. Move: sudo mv apache-maven-* /opt/maven"
    echo "  4. Add to ~/.zshrc:"
    echo "     export M2_HOME=/opt/maven"
    echo "     export PATH=\$M2_HOME/bin:\$PATH"
    echo "  5. Run: source ~/.zshrc"
    echo ""
    exit 1
fi

