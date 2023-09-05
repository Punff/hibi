#!/bin/bash

# Specify the script name (assuming it's 'hibi.py')
SCRIPT_NAME="hibi.py"

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

# Locate the path to the user's home directory
USER_HOME="$HOME"

# Specify the full path to the script
PY_SCRIPT_PATH="$USER_HOME/$SCRIPT_NAME"

# Check if the script file exists
if [ ! -f "$PY_SCRIPT_PATH" ]; then
    echo "The script file '$SCRIPT_NAME' does not exist in the user's home directory."
    exit 1
fi

# Create the shell script
cat > hibi.sh <<EOF
#!/bin/bash
python3 "$PY_SCRIPT_PATH" "\$@"
EOF

# Make the shell script executable
chmod +x hibi.sh

# Function to add $HOME/bin to PATH
add_to_path() {
    if [[ ":$PATH:" != *":$USER_HOME/bin:"* ]]; then
        echo 'export PATH="$USER_HOME/bin:$PATH"' >> "$USER_HOME/.bashrc"
        source "$USER_HOME/.bashrc"
    fi
}

# Check if $USER_HOME/bin is in PATH, and add it if necessary
if [[ ":$PATH:" != *":$USER_HOME/bin:"* ]]; then
    echo "\$USER_HOME/bin is not in your PATH. Attempting to add it..."
    mkdir -p "$USER_HOME/bin"
    add_to_path
fi

# Create a symbolic link if the script file exists
if [ -f hibi.sh ]; then
    ln -s "$(pwd)/hibi.sh" "$USER_HOME/bin/hibi"
    echo "Symbolic link 'hibi' created in \$USER_HOME/bin."
    echo "Installation completed. You can now run 'hibi <command>' to use your script."
else
    echo "The script file 'hibi.sh' is missing. Please make sure it exists in the current directory."
fi
