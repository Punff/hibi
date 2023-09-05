#!/bin/bash

# Determine the location of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Determine the script filename (assuming it's hibi.py)
PY_SCRIPT_FILENAME="hibi.py"

# Check if Python3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Python3 is required but not found. Please install Python3."
    exit 1
fi

# Check if figlet is installed
if ! command -v figlet &> /dev/null; then
    echo "Figlet is required but not found. Please install Figlet."
    exit 1
fi

# Create the shell script
cat > hibi.sh <<EOF
#!/bin/bash
python3 "$SCRIPT_DIR/$PY_SCRIPT_FILENAME" "\$@"
EOF

# Make the shell script executable
chmod +x hibi.sh

# Determine the target directory for the symbolic link (you can modify this)
TARGET_DIR="$HOME/bin"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Function to add $TARGET_DIR to PATH
add_to_path() {
    if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
        echo 'export PATH="$TARGET_DIR:$PATH"' >> "$HOME/.bashrc"
        source "$HOME/.bashrc"
    fi
}

# Check if $TARGET_DIR is in PATH, and add it if necessary
if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
    echo "\$TARGET_DIR is not in your PATH. Attempting to add it..."
    add_to_path
fi

# Create a symbolic link if the script file exists
if [ -f hibi.sh ]; then
    ln -s "$SCRIPT_DIR/hibi.sh" "$TARGET_DIR/hibi"
    echo "Symbolic link 'hibi' created in \$TARGET_DIR."
    echo "Installation completed. You can now run 'hibi <command>' to use your script."
else
    echo "The script file 'hibi.sh' is missing. Please make sure it exists in the current directory."
fi
