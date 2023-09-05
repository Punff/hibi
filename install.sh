#!/bin/bash

# Determine the location of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Determine the GitHub repository URL
REPO_URL="$(git -C "$SCRIPT_DIR" config --get remote.origin.url)"

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

# Function to add $HOME/bin to PATH
add_to_path() {
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
        source "$HOME/.bashrc"
    fi
}

# Check if $HOME/bin is in PATH, and add it if necessary
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo "\$HOME/bin is not in your PATH. Attempting to add it..."
    mkdir -p "$HOME/bin"
    add_to_path
fi

# Create a symbolic link if the script file exists
if [ -f hibi.sh ]; then
    ln -s "$SCRIPT_DIR/hibi.sh" "$HOME/bin/hibi"
    echo "Symbolic link 'hibi' created in \$HOME/bin."
    echo "Installation completed. You can now run 'hibi <command>' to use your script."
else
    echo "The script file 'hibi.sh' is missing. Please make sure it exists in the current directory."
fi
